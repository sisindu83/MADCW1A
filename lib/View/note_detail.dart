import 'package:flutter/material.dart';
import '../Controller/db.dart';
import '../Model/note.dart';

class NoteDetail extends StatefulWidget {
  final Note? note;

  NoteDetail({this.note});

  @override
  _NoteDetailState createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contentController,
              style: TextStyle(color: Colors.white),
              maxLines: 10,
              decoration: InputDecoration(
                labelText: 'Content',
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final title = _titleController.text;
                final content = _contentController.text;


                if (widget.note == null) {
                  // Create new note
                  await DB().createNote(title, content);
                } else {
                  // Update existing note
                  await DB().updateNote(
                    widget.note!.id!,
                    title,
                    content,
                  );
                }

                Navigator.pop(context, true);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
