import 'package:flutter/material.dart';
import '../Controller/db.dart';
import '../Model/note.dart';
import 'note_card.dart';
import 'note_detail.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  List<Note> notes = [];
  List<Note> filteredNotes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }


  Future<void> _loadNotes() async {
    final data = await DB().fetchNotes();
    setState(() {
      notes = data.map((e) => Note.fromMap(e)).toList();
      filteredNotes = notes;
    });
  }


  void _openNoteDetail(Note? note) async {
    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetail(note: note)),
    );


    if (result == true) {
      _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MySimpleNote'),
        actions: [

          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NotesSearchDelegate(notes, _openNoteDetail),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _openNoteDetail(null);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          final note = filteredNotes[index];
          return NoteCard(
            note: note,
            onTap: () {
              _openNoteDetail(note);
            },
            onDelete: () async {
              await DB().deleteNote(note.id!);
              _loadNotes();
            },
          );
        },
      ),
    );
  }
}

// Custom Search Delegate for notes
class NotesSearchDelegate extends SearchDelegate {
  final List<Note> notes;
  final Function(Note?) openNoteDetail;

  NotesSearchDelegate(this.notes, this.openNoteDetail);

  @override
  String get searchFieldLabel => "Search Notes";

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context); // Show suggestions again after clearing
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Filter notes based on the search query
    final searchResults = notes
        .where((note) => note.title.toLowerCase().contains(query.toLowerCase()) ||
        note.content.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final note = searchResults[index];
        return ListTile(
          title: Text(note.title),
          subtitle: Text(note.content),
          onTap: () {
            openNoteDetail(note);  // Open the detail page for editing
            close(context, null);  // Close the search page
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? notes
        : notes
        .where((note) => note.title.toLowerCase().contains(query.toLowerCase()) ||
        note.content.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final note = suggestionList[index];
        return ListTile(
          title: Text(note.title),
          subtitle: Text(note.content),
          onTap: () {
            query = note.title;  // Set the query to the selected note
            openNoteDetail(note);  // Open the detail page for editing
            close(context, null);  // Close the search page
          },
        );
      },
    );
  }
}
