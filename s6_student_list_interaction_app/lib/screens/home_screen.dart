import 'package:flutter/material.dart';
import 'package:s6_student_list_interaction_app/models/student.dart';
import 'package:s6_student_list_interaction_app/widgets/student_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Student> students = [
    Student(id: 'SV01', name: 'Nguyễn Văn A'),
    Student(id: 'SV02', name: 'Trần Thị B'),
    Student(id: 'SV03', name: 'Lê Văn C'),
    Student(id: 'SV04', name: 'Phạm Văn D'),
    Student(id: 'SV05', name: 'Hoàng Thị E'),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student List'), centerTitle: true),
      // Xây dựng ListView.builder
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          return StudentCard(
            student: student,
            onTap: () {
              setState(() {
                student.isSelected = !student.isSelected;
              });
            },
          );
        },
      ),
    );
  }
}
