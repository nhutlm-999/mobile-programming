class Task {
  String id;
  String title;
  bool isDone;

  Task({required this.id, required this.title, this.isDone = false});

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'isDone': isDone};

  factory Task.fromJson(Map<String, dynamic> json) =>
      Task(id: json['id'], title: json['title'], isDone: json['isDone']);
}
