import 'package:app_ontapkienthuc/url/api_url.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_ontapkienthuc/main.dart';
import 'package:provider/provider.dart';
import "package:fluttertoast/fluttertoast.dart";

class QuizListApp extends StatefulWidget {
  final String subjectId;

  QuizListApp({required this.subjectId});

  @override
  _QuizListAppState createState() => _QuizListAppState();
}

class _QuizListAppState extends State<QuizListApp> {
  List<Map<String, dynamic>> quizzes = [];
  @override
  void initState() {
    super.initState();
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    final uri = Uri.parse(ApiUrls.quizzesUrl);
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> quizList =
            data.cast<Map<String, dynamic>>();

        final filteredQuizzes = quizList
            .where((quizzes) => quizzes['subject_id'] == widget.subjectId)
            .toList();

        setState(() {
          quizzes = filteredQuizzes;
        });
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
          title: Text(
            'Danh sách bài kiểm tra',
            style: TextStyle(fontSize: 22),
          ),
        ),
        body: ListView.builder(
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 2, // Add some elevation for a shadow effect
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(
                  quizzes[index]['namequiz'],
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.green,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => QuizApp(
                        quizId: quizzes[index]['id'],
                        nameQuiz: quizzes[index]['namequiz'],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ));
  }
}

class QuizApp extends StatefulWidget {
  final String quizId; // Đổi từ int thành String
  final String nameQuiz;

  QuizApp({required this.quizId, required this.nameQuiz});

  @override
  _QuizAppState createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool showResult = false;
  bool quizCompleted = false;

  Color mySkyBlueColor = Color.fromRGBO(135, 206, 235, 1);

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final uri = Uri.parse(ApiUrls.questionsUrl);
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> questionsList =
            data.cast<Map<String, dynamic>>();

        // Lọc danh sách câu hỏi theo quizId
        final filteredQuestions = questionsList
            .where((question) =>
                question['quiz_id'] == widget.quizId) // Sử dụng widget.quizId
            .toList();

        setState(() {
          questions = filteredQuestions;
        });
      } catch (e) {
        print("Error parsing JSON: $e");
      }
    } else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  void checkAnswer(String selectedanswer) {
    if (!quizCompleted) {
      String correctAnswer = questions[currentQuestionIndex]['correctanswer'];
      bool iscorrect = selectedanswer == correctAnswer;

      setState(() {
        questions[currentQuestionIndex]['selectedanswer'] = selectedanswer;
        questions[currentQuestionIndex]['iscorrect'] = iscorrect;

        if (iscorrect) {
          score++;
        }
      });

      goToNextQuestion();
    }
  }

  void checkQuizCompletion() {
    if (currentQuestionIndex == questions.length) {
      setState(() {
        quizCompleted = true;
      });
    }
  }

  void goToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
      checkQuizCompletion();
    } else {
      showResult = true;
      quizCompleted = true;
    }
  }

  void resetQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      showResult = false;
      quizCompleted = false;

      for (var question in questions) {
        question['selectedanswer'] = '';
        question['iscorrect'] = false;
      }
    });
  }

  double calculateAverageScore() {
    return (score / questions.length) * 10;
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
                  title: Text('Tên Bài kiểm tra'),
                  content: Text(widget.nameQuiz),
                );
              },
            );
          },
          child: Text(
            widget.nameQuiz,
            style: TextStyle(fontSize: 22),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Câu ${currentQuestionIndex + 1}/${questions.length}',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 16.0),
              if (questions.isNotEmpty &&
                  currentQuestionIndex < questions.length)
                Text(
                  'Câu ${currentQuestionIndex + 1}: ${questions[currentQuestionIndex]['question']}',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 16.0),
              if (questions.isNotEmpty &&
                  currentQuestionIndex < questions.length)
                Column(
                  children: [
                    // Inside your Widget's build method
                    if (questions.isNotEmpty &&
                        currentQuestionIndex < questions.length)
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            buildAnswerButton(
                                questions[currentQuestionIndex]['answer1']),
                            SizedBox(height: 8.0),
                            buildAnswerButton(
                                questions[currentQuestionIndex]['answer2']),
                            SizedBox(height: 8.0),
                            buildAnswerButton(
                                questions[currentQuestionIndex]['answer3']),
                            SizedBox(height: 8.0),
                            buildAnswerButton(
                                questions[currentQuestionIndex]['answer4']),
                          ],
                        ),
                      ),
                  ],
                ),
              SizedBox(height: 16.0),
              if (showResult)
                Text(
                  'Điểm của bạn: ${calculateAverageScore().toStringAsFixed(1)}/10',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 16.0),
              if (showResult)
                ElevatedButton(
                  child: Text('Làm lại'),
                  onPressed: resetQuiz,
                ),
              if (showResult) SizedBox(height: 16.0),
              if (showResult)
                ElevatedButton(
                  child: Text('Lưu điểm'),
                  onPressed: () {
                    saveScore(widget.quizId, calculateAverageScore(), context);
                  },
                ),
              if (showResult) SizedBox(height: 16.0),
              if (showResult)
                Text(
                  'Đáp án:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              if (showResult) SizedBox(height: 8.0),
              if (showResult)
                SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      String selectedanswer =
                          questions[index]['selectedanswer'];
                      String correctAnswer = questions[index]['correctanswer'];

                      String answerText;
                      Color answerColor;

                      if (correctAnswer != selectedanswer) {
                        answerText =
                            'Câu trả lời sai: $selectedanswer\nĐáp án đúng: $correctAnswer';
                        answerColor = Colors.red;
                      } else {
                        answerText = 'Đúng: $correctAnswer';
                        answerColor = Colors.green;
                      }

                      return ListTile(
                        title: Text(
                          'Câu ${index + 1}: ${questions[index]['question']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.0),
                        ),
                        subtitle: Text(
                          answerText,
                          style: TextStyle(color: answerColor, fontSize: 16.0),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 0.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentQuestionIndex > 0)
                    Container(
                      //margin: EdgeInsets.only(
                      //ottom: 10 * MediaQuery.of(context).devicePixelRatio),
                      child: ElevatedButton(
                        child: Text('Câu trước'),
                        onPressed: () {
                          setState(() {
                            currentQuestionIndex--;
                          });
                        },
                      ),
                    ),
                  if (currentQuestionIndex < questions.length - 1)
                    Container(
                      //margin: EdgeInsets.only(
                      // margin bot cách bên dưới 10
                      //bottom: 10 * MediaQuery.of(context).devicePixelRatio),
                      child: ElevatedButton(
                        child: Text('Câu tiếp theo'),
                        onPressed: () {
                          // Check if the selected answer is null or empty
                          if (questions[currentQuestionIndex]
                                      ['selectedanswer'] ==
                                  null ||
                              questions[currentQuestionIndex]['selectedanswer']
                                  .isEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Hãy chọn đáp án!'),
                                  actions: [
                                    ElevatedButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            setState(() {
                              currentQuestionIndex++;
                            });
                          }
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton buildAnswerButton(String answerText) {
    bool isSelected =
        answerText == questions[currentQuestionIndex]['selectedanswer'];
    bool isCorrect = questions[currentQuestionIndex]['iscorrect'] == true;

    Color backgroundColor;
    if (quizCompleted) {
      if (isSelected && isCorrect) {
        backgroundColor = Colors.green;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red;
      } else {
        backgroundColor = mySkyBlueColor;
      }
    } else {
      backgroundColor = isSelected ? Colors.grey : mySkyBlueColor;
    }

    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color?>(backgroundColor),
      ),
      onPressed: () {
        if (!showResult) {
          checkAnswer(answerText);
        }
      },
      child: Container(
        height: 70,
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

  Future<void> saveScore(
      String quizId, double score, BuildContext context) async {
    int loggedInUserId =
        Provider.of<AuthProvider>(context, listen: false).userId;

    if (loggedInUserId != 0) {
      var body = json.encode({
        'score': score,
        'quiz_id': quizId,
        'user_id': loggedInUserId,
      });

      var saveScoreUrl = Uri.parse(ApiUrls.checkScoreExistAndSaveUrl);

      try {
        var saveScoreResponse = await http.post(
          saveScoreUrl,
          headers: {"Content-Type": "application/json"},
          body: body,
        );

        if (saveScoreResponse.statusCode == 200) {
          var saveScoreData = json.decode(saveScoreResponse.body);

          if (saveScoreData['message'] == 'success') {
            showToast(context, "Điểm đã được lưu vào cơ sở dữ liệu!");
          } else {
            showToast(context, "Điểm đã tồn tại cho lần lưu trước!");
          }
        } else {
          print('Error: ${saveScoreResponse.statusCode}');
        }
      } catch (error) {
        print('Error: $error');
      }
    }
  }

  void showToast(BuildContext context, String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      fontSize: 16.0,
    );
  }
}
