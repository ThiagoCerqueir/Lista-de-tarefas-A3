import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:listadetarefas/database/database.dart';
import 'package:listadetarefas/models/note_model.dart';
import 'package:listadetarefas/screens/add_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Note>> _noteList;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _updateNoteList();
  }

  
  _updateNoteList() {
    setState(() {
      _noteList =
          _databaseHelper.getNoteList(); 
    });
  }

  
  Widget _controlTarefa(Note note) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Card(
        elevation: 5.0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          title: Text(
            note.titulo!,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              decoration: note.status == 0
                  ? TextDecoration.none
                  : TextDecoration
                      .lineThrough, 
            ),
          ),
          subtitle: Text(
            '${_dateFormat.format(note.data!)} - ${note.prioridade}',
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.grey[600],
              decoration: note.status == 0
                  ? TextDecoration.none
                  : TextDecoration.lineThrough,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) =>
                    AddNoteScreen(note: note), 
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) =>
                    const AddNoteScreen()), 
          );
        },
        child: const Icon(Icons.add, size: 30),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text("Lista de Tarefas", style: TextStyle(fontSize: 24)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Note>>(
        future: _noteList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar tarefas'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma tarefa encontrada'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            itemCount: snapshot.data!.length,
            itemBuilder: (BuildContext context, int index) {
              return _controlTarefa(snapshot.data![index]); 
            },
          );
        },
      ),
    );
  }
}
