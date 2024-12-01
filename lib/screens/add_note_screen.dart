import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:listadetarefas/database/database.dart';
import 'package:listadetarefas/models/note_model.dart';
import 'package:listadetarefas/screens/home_screen.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? note; 

  const AddNoteScreen({super.key, this.note});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  String _titulo = "";
  String _prioridade = 'Baixa';
  DateTime _data = DateTime.now();
  String btnText = 'Adicionar Tarefa';
  String titleText = 'Adicionar';

  final TextEditingController _dataController = TextEditingController();

  final DateFormat _dataFormato = DateFormat('MMM dd, yyyy');
  final List<String> _prioridades = ['Baixa', 'Média', 'Alta'];

  @override
  void initState() {
    super.initState();
   
    if (widget.note != null) {
      _titulo = widget.note!.titulo!;
      _prioridade = widget.note!.prioridade!;
      _data = widget.note!.data!;
      btnText = 'Atualizar Tarefa';
      titleText = 'Editar Tarefa';
      _dataController.text = _dataFormato.format(_data);
    }
  }

  _seletorData() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && date != _data) {
      setState(() {
        _data = date;
      });
      _dataController.text = _dataFormato.format(date);
    }
  }

  _salvarNota() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final note = widget.note != null
          ? Note.withId(
              id: widget.note?.id,
              titulo: _titulo,
              data: _data,
              prioridade: _prioridade,
              status: widget.note?.status ?? 0,
            )
          : Note(
              titulo: _titulo,
              data: _data,
              prioridade: _prioridade,
              status: 0, 
            );

      if (widget.note != null) {
        
        DatabaseHelper.instance.updateNote(note);
      } else {
        
        DatabaseHelper.instance.insertNote(note);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  _excluirNota() {
    if (widget.note != null) {
      DatabaseHelper.instance.deleteNote(widget.note!.id!);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 40.0, vertical: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    size: 30.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 20.0),
                Text(
                  titleText,
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          initialValue: _titulo,
                          style: const TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Título',
                            labelStyle: const TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira um título';
                            }
                            return null;
                          },
                          onSaved: (value) => _titulo = value!,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: _dataController,
                          style: const TextStyle(fontSize: 18.0),
                          onTap: _seletorData,
                          decoration: InputDecoration(
                            labelText: 'Data',
                            labelStyle: const TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: DropdownButtonFormField(
                          items: _prioridades.map((String priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(
                                priority,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18.0,
                                ),
                              ),
                            );
                          }).toList(),
                          style: const TextStyle(fontSize: 18.0),
                          decoration: InputDecoration(
                            labelText: 'Prioridade',
                            labelStyle: const TextStyle(fontSize: 18.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _prioridade = value.toString();
                            });
                          },
                          value: _prioridade,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20.0),
                        height: 60.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: ElevatedButton(
                          onPressed: _salvarNota,
                          child: Text(
                            btnText,
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                      ),
                      if (widget.note != null)
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
                          height: 60.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: ElevatedButton(
                            onPressed: _excluirNota,
                            child: const Text(
                              'Excluir Tarefa',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
