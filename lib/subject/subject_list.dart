import 'package:app_ontapkienthuc/quiz/quiz.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SubjectList extends StatefulWidget {
  @override
  _SubjectListState createState() => _SubjectListState();
}

class _SubjectListState extends State<SubjectList> {
  List<Map<String, dynamic>> subjects = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final uri = Uri.parse("http://10.0.149.216:8080/localconnect/subjects.php");
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> subjectData = json.decode(response.body);

        setState(() {
          subjects = List<Map<String, dynamic>>.from(subjectData);
        });
      } catch (e) {
        print("Error parsing JSON: $e");
      }
    } else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  Color mySkyBlueColor = Color.fromRGBO(135, 206, 235, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Danh sách môn học",
          style: TextStyle(fontSize: 22),
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Số cột
          crossAxisSpacing: 8.0, // Khoảng cách giữa các ô theo chiều ngang
          mainAxisSpacing: 8.0, // Khoảng cách giữa các ô theo chiều dọc
        ),
        itemBuilder: (context, index) {
          return ElevatedButton(
            child: Text(
              subjects[index]['namesubject'],
              style: TextStyle(fontSize: 20),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: mySkyBlueColor,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => QuizListApp(
                    subjectId: subjects[index]['id'],
                  ),
                ),
              );
            },
          );
        },
        itemCount: subjects.length,
      ),
    );
  }
}
