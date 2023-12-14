import 'package:app_ontapkienthuc/url/api_url.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import "package:fluttertoast/fluttertoast.dart";

class TopicSelectionScreen extends StatefulWidget {
  @override
  _TopicSelectionScreenState createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  String? selectedSubject;
  List<Map<String, dynamic>> subjects = [];

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    final apiUrl = ApiUrls.subjectforautoquizUrl;
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        if (data is List) {
          subjects = data.cast<Map<String, dynamic>>().toList();
          setState(() {});
        } else {
          print("Invalid data format from API");
        }
      } catch (e) {
        print("Error parsing JSON: $e");
      }
    } else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tạo đề tự động'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Lựa chọn môn học:'),
            DropdownButton<Map<String, dynamic>>(
              value: selectedSubject != null
                  ? subjects.firstWhere(
                      (subject) => subject['id'].toString() == selectedSubject)
                  : null,
              items: [
                DropdownMenuItem<Map<String, dynamic>>(
                  value: null,
                  child: Text('Chọn 1 môn học trong danh sách'),
                ),
                ...subjects.map((Map<String, dynamic> subject) {
                  return DropdownMenuItem<Map<String, dynamic>>(
                    value: subject,
                    child: Text(subject['namesubject'].toString()),
                  );
                }).toList(),
              ],
              onChanged: (Map<String, dynamic>? value) {
                setState(() {
                  selectedSubject =
                      value?['id']?.toString(); // Convert int? to String?
                });
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (selectedSubject != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AutoQuiz(subjectId: selectedSubject!),
                    ),
                  );
                } else {
                  Fluttertoast.showToast(
                    msg: "Vui lòng chọn 1 môn học để tạo đề!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    fontSize: 16.0,
                  );
                }
              },
              child: Text('Tạo đề'),
            ),
          ],
        ),
      ),
    );
  }
}

class AutoQuiz extends StatefulWidget {
  final String subjectId;

  AutoQuiz({required this.subjectId});

  @override
  _AutoQuizState createState() => _AutoQuizState();
}

class _AutoQuizState extends State<AutoQuiz> {
  List<Map<String, dynamic>> autoQuestions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool quizCompleted = false;

  @override
  void initState() {
    super.initState();
    fetchRandomQuestions();
  }

  Future<void> fetchRandomQuestions() async {
    final uri = Uri.parse(
        '${ApiUrls.autoquizUrl}?subject=${widget.subjectId.toString()}&limit=2&hotquestion=1');
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        if (data is List) {
          autoQuestions = data.cast<Map<String, dynamic>>().toList();
          setState(() {});
        } else {
          print("Invalid data format from API");
        }
      } catch (e) {
        print("Error parsing JSON: $e");
      }
    } else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  void checkAnswer(String selectedAnswer) {
    if (!quizCompleted) {
      String correctAnswer =
          autoQuestions[currentQuestionIndex]['correctanswer'];
      bool isCorrect = selectedAnswer == correctAnswer;

      setState(() {
        autoQuestions[currentQuestionIndex]['selectedanswer'] = selectedAnswer;
        autoQuestions[currentQuestionIndex]['iscorrect'] = isCorrect;

        if (isCorrect) {
          // Update score by distributing 10 points equally among questions
          score = ((currentQuestionIndex + 1) * 10) ~/ autoQuestions.length;
        }
      });

      // Delay for a moment to show correct/incorrect feedback
      Future.delayed(Duration(seconds: 1), () {
        if (currentQuestionIndex < autoQuestions.length - 1) {
          goToNextQuestion();
        } else {
          // Quiz completed
          setState(() {
            quizCompleted = true;
          });
        }
      });
    }
  }

  void goToNextQuestion() {
    if (currentQuestionIndex < autoQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void resetQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      quizCompleted = false;

      for (var question in autoQuestions) {
        question['selectedanswer'] = '';
        question['iscorrect'] = false;
      }
    });

    fetchRandomQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Bài kiểm tra tự động'),
                  content: Text('Câu hỏi tự động từ cơ sở dữ liệu'),
                );
              },
            );
          },
          child: Text(
            'Bài kiểm tra tự động',
            style: TextStyle(fontSize: 22),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!quizCompleted)
              Text(
                'Câu ${currentQuestionIndex + 1}/${autoQuestions.length}',
                style: TextStyle(fontSize: 18.0),
              ),
            SizedBox(height: 16.0),
            if (autoQuestions.isNotEmpty &&
                currentQuestionIndex < autoQuestions.length)
              Text(
                'Câu ${currentQuestionIndex + 1}: ${autoQuestions[currentQuestionIndex]['question']}',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 16.0),
            if (autoQuestions.isNotEmpty &&
                currentQuestionIndex < autoQuestions.length)
              Column(
                children: [
                  for (String option in autoQuestions[currentQuestionIndex]
                      ['options'])
                    Column(
                      children: [
                        buildAnswerButton(option),
                        SizedBox(
                          height: 8.0,
                        ),
                      ],
                    ),
                ],
              ),
            SizedBox(height: 16.0),
            if (quizCompleted)
              Text(
                'Điểm của bạn: $score/10',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 16.0),
            if (quizCompleted)
              ElevatedButton(
                child: Text('Xem đáp án'),
                onPressed: () {
                  // Show correct/incorrect answers
                  _showAnswersDialog();
                },
              ),
            SizedBox(height: 16.0),
            if (quizCompleted)
              ElevatedButton(
                child: Text('Tạo đề mới'),
                onPressed: resetQuiz,
              ),
          ],
        ),
      ),
    );
  }

  ElevatedButton buildAnswerButton(String answerText) {
    bool isSelected =
        answerText == autoQuestions[currentQuestionIndex]['selectedanswer'];
    bool isCorrect = autoQuestions[currentQuestionIndex]['iscorrect'] == true;

    Color backgroundColor;
    if (quizCompleted) {
      if (isSelected && isCorrect) {
        backgroundColor = Colors.green;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red;
      } else {
        backgroundColor = Colors.blue;
      }
    } else {
      backgroundColor = isSelected ? Colors.grey : Colors.blue;
    }

    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color?>(backgroundColor),
      ),
      onPressed: () {
        if (!quizCompleted) {
          checkAnswer(answerText);
        }
      },
      child: Container(
        height: 60,
        alignment: Alignment.center,
        child: Text(
          answerText,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showAnswersDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Đáp án'),
          content: Column(
            children: [
              for (int i = 0; i < autoQuestions.length; i++)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Câu ${i + 1}: ${autoQuestions[i]['question']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (autoQuestions[i]['iscorrect'] == true)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đáp án đúng: ${autoQuestions[i]['correctanswer']}',
                            style: TextStyle(color: Colors.green),
                          ),
                          SizedBox(height: 8.0),
                        ],
                      ),
                    if (autoQuestions[i]['iscorrect'] == false)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đáp án đúng: ${autoQuestions[i]['correctanswer']}',
                            style: TextStyle(color: Colors.green),
                          ),
                          Text(
                            'Đáp án bạn chọn: ${autoQuestions[i]['selectedanswer']}',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 8.0),
                        ],
                      ),
                  ],
                ),
              Text(
                'Điểm của bạn: $score/10',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}
