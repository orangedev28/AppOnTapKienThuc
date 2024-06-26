import 'package:app_ontapkienthuc/url/api_url.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import "package:fluttertoast/fluttertoast.dart";
import 'dart:async';

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
    final apiUrl = ApiUrls.subjectsUrl;
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        subjects = data.cast<Map<String, dynamic>>().toList();
        setState(() {});
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
                  selectedSubject = value?['id']?.toString();
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
  int timerSeconds = 10; // Thời gian đếm ngược, đơn vị là giây
  late Timer timer;

  @override
  void initState() {
    super.initState();
    fetchRandomQuestions();
    startTimer();
  }

  Future<void> fetchRandomQuestions() async {
    final uri = Uri.parse(
        '${ApiUrls.autoquizUrl}?subject=${widget.subjectId.toString()}&limit=2&hotquestion=1');
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        autoQuestions = data.cast<Map<String, dynamic>>().toList();
        setState(() {});
      } catch (e) {
        print("Error parsing JSON: $e");
      }
    } else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  void checkAnswer(String selectedanswer) {
    if (!quizCompleted) {
      String correctAnswer =
          autoQuestions[currentQuestionIndex]['correctanswer'];
      bool iscorrect = selectedanswer == correctAnswer;

      setState(() {
        autoQuestions[currentQuestionIndex]['selectedanswer'] = selectedanswer;
        autoQuestions[currentQuestionIndex]['iscorrect'] = iscorrect;

        if (iscorrect) {
          score++;
        }
      });

      goToNextQuestion();
    }
  }

  void checkQuizCompletion() {
    if (currentQuestionIndex == autoQuestions.length) {
      setState(() {
        quizCompleted = true;
      });
    }
  }

  void goToNextQuestion() {
    if (currentQuestionIndex < autoQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
      checkQuizCompletion();
    } else {
      quizCompleted = true;
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

      // Reset thời gian đếm ngược về giá trị ban đầu (5 giây)
    });
    timerSeconds = 10;
    // Bắt đầu đếm ngược lại
    startTimer();

    // Lấy câu hỏi mới
    fetchRandomQuestions();
  }

  double calculateAverageScore() {
    return (score / autoQuestions.length) * 10;
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (timerSeconds > 0 && !quizCompleted) {
        setState(() {
          timerSeconds--;
        });

        // Show toast when timer is at 3 seconds
        if (timerSeconds == 8) {
          checkUnansweredQuestions();
        }
        if (timerSeconds == 3) {
          checkUnansweredQuestions();
        }
      } else if (quizCompleted) {
        timer.cancel();
        _showAnswersDialog();
      } else if (!quizCompleted) {
        timer.cancel();

        // Bài kiểm tra chưa hoàn thành, hãy hoàn thành và hiển thị đáp án
        finishQuiz();
      }
    });
  }

  void checkUnansweredQuestions() {
    if (containsUnansweredQuestion()) {
      Fluttertoast.showToast(
        msg: "Bạn còn câu hỏi chưa chọn đáp án!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
    }
  }

  void finishQuiz() {
    setState(() {
      quizCompleted = true;
    });

    int totalCorrectAnswers = 0;

    for (var question in autoQuestions) {
      if (question['selectedanswer'] != null) {
        // Câu đã chọn
        if (question['selectedanswer'] == question['correctanswer']) {
          // Nếu câu đã chọn đúng
          question['iscorrect'] = true;
          totalCorrectAnswers += 1;
        } else {
          // Nếu câu đã chọn sai
          question['iscorrect'] = false;
        }
      } else {
        // Câu không được chọn (null)
        question['iscorrect'] = false;
      }
    }

    score = (totalCorrectAnswers / autoQuestions.length * 10).toInt();

    _showAnswersAndScoreDialog();
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
            Text(
              'Thời gian còn lại: ${timerSeconds ~/ 60}:${(timerSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 18.0, color: Colors.red),
            ),
            SizedBox(height: 16.0),
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
            if (quizCompleted) SizedBox(height: 16.0),
            if (quizCompleted)
              ElevatedButton(
                child: Text('Xem kết quả'),
                onPressed: () {
                  _showAnswersDialog();
                },
              ),
            SizedBox(height: 16.0),
            if (quizCompleted)
              ElevatedButton(
                child: Text('Tạo đề mới'),
                onPressed: resetQuiz,
              ),
            SizedBox(height: 16.0),
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
                if (currentQuestionIndex < autoQuestions.length - 1)
                  Container(
                    //margin: EdgeInsets.only(
                    // margin bot cách bên dưới 10
                    //bottom: 10 * MediaQuery.of(context).devicePixelRatio),
                    child: ElevatedButton(
                      child: Text('Câu tiếp theo'),
                      onPressed: () {
                        // Check if the selected answer is null or empty
                        if (autoQuestions[currentQuestionIndex]
                                    ['selectedanswer'] ==
                                null ||
                            autoQuestions[currentQuestionIndex]
                                    ['selectedanswer']
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
        height: 75,
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

  bool containsUnansweredQuestion() {
    return autoQuestions.any((question) =>
        question['selectedanswer'] == null ||
        question['selectedanswer'].isEmpty);
  }

  void _showAnswersDialog() {
    if (containsUnansweredQuestion()) {
      _showAnswersAndScoreDialog();
    } else {
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
                  'Điểm của bạn: ${calculateAverageScore().toStringAsFixed(1)}/10',
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

  void _showAnswersAndScoreDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Kết quả và Đáp án'),
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
                'Điểm của bạn: ${score.toStringAsFixed(1)}/10',
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
