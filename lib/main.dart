import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MultiNotepadApp());
}

class MultiNotepadApp extends StatelessWidget {
  const MultiNotepadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NotesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, String>> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notes');
    if (data != null) {
      setState(() {
        notes = List<Map<String, String>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notes', jsonEncode(notes));
  }

  void addNote() {
    notes.add({"title": "New Note", "content": ""});
    saveNotes();
    setState(() {});
  }

  void editNote(int index) async {
    final titleController =
        TextEditingController(text: notes[index]["title"]);
    final contentController =
        TextEditingController(text: notes[index]["content"]);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Note"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: "Content"),
                maxLines: 10,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                notes.removeAt(index);
                saveNotes();
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text("Delete")),
          TextButton(
              onPressed: () {
                notes[index] = {
                  "title": titleController.text,
                  "content": contentController.text
                };
                saveNotes();
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text("Save")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Multi Notepad"),
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (_, index) {
          return ListTile(
            title: Text(notes[index]["title"]!),
            subtitle: Text(
              notes[index]["content"]!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => editNote(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNote,
        child: const Icon(Icons.add),
      ),
    );
  }
}
