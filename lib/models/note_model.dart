class Note {
  int? id;
  String? titulo;
  DateTime? data;
  String? prioridade;
  int status;  

 
  Note({this.titulo, this.data, this.prioridade, this.status = 0});

  
  Note.withId({this.id, this.titulo, this.data, this.prioridade, this.status = 0});


  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {};

   
    if (id != null) {
      map['id'] = id;
    }

    map['Titulo'] = titulo;
    map['Data'] = data?.toIso8601String();
    map['Prioridade'] = prioridade;
    map['Status'] = status;  
    return map;
  }


  factory Note.fromMap(Map<String, dynamic> map) {
    return Note.withId(
      id: map['id'],
      titulo: map['Titulo'],
      data: map['Data'] != null ? DateTime.parse(map['Data']) : null,
      prioridade: map['Prioridade'],
      status: map['Status'] ?? 0,  
    );
  }
}
