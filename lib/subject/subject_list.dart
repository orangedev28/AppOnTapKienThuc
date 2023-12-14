import 'package:app_ontapkienthuc/quiz/quiz.dart';
import 'package:app_ontapkienthuc/ui/background/background.dart';
import 'package:app_ontapkienthuc/url/api_url.dart';
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
    final uri = Uri.parse(ApiUrls.subjectsUrl);
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
      body: Stack(
        children: [
          // Add your Background widget as the first child
          Background(),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Số cột
              crossAxisSpacing: 8.0, // Khoảng cách giữa các ô theo chiều ngang
              mainAxisSpacing: 8.0, // Khoảng cách giữa các ô theo chiều dọc
            ),
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.all(8.0), // Add padding around the button
                child: ElevatedButton(
                  child: Text(
                    subjects[index]['namesubject'],
                    style: TextStyle(fontSize: 18), // Reduce the font size
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(16.0), // Increase the padding
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
                ),
              );
            },
            itemCount: subjects.length,
          ),
        ], // Close the list of Stack children here
      ),
    );
  }
}
