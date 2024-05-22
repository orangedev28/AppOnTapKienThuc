import 'package:app_ontapkienthuc/ui/background/background.dart';
import 'package:app_ontapkienthuc/url/api_url.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_ontapkienthuc/main.dart';
import 'package:provider/provider.dart';
import "package:fluttertoast/fluttertoast.dart";

class SubjectListForQuizzes extends StatefulWidget {
  @override
  _SubjectListState createState() => _SubjectListState();
}

class _SubjectListState extends State<SubjectListForQuizzes> {
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
          Background(),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: Text(
                    subjects[index]['namesubject'],
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(16.0),
                    backgroundColor: mySkyBlueColor,
                  ),
                  onPressed: () {
                    print(
                        "Button Pressed"); // Add this line to check if the button is pressed
                    showDifficultyDialog(context, subjects[index]['id']);
                  },
                ),
              );
            },
            itemCount: subjects.length,
          ),
        ],
      ),
    );
  }

  void showDifficultyDialog(BuildContext context, String subjectId) {
    Map<String, String> difficultyMapping = {
      'Dễ': 'easy',
      'Trung Bình': 'medium',
      'Khó': 'hard',
    };

    String selectedDifficulty = difficultyMapping.keys.first;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn mức độ bài kiểm tra'),
          content: SingleChildScrollView(
            child: Column(
              children: difficultyMapping.keys.map((level) {
                return ListTile(
                  title: Text(level),
                  onTap: () {
                    setState(() {
                      selectedDifficulty = difficultyMapping[level]!;
                    });
                    Navigator.pop(context);

                    // Chắc chắn rằng subjectId được truyền đúng
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizListApp(
                          subjectId: subjectId, // Thêm subjectId vào đây
                          difficulty: selectedDifficulty,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class QuizListApp extends StatefulWidget {
  final String subjectId;
  final String difficulty;

  QuizListApp({required this.subjectId, required this.difficulty});

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
    final uri = Uri.parse(
        '${ApiUrls.quizzesUrl}?difficulty=${widget.difficulty}&subject_id=${widget.subjectId}');
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> quizList =
            data.cast<Map<String, dynamic>>();

        setState(() {
          quizzes = quizList;
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
            elevation: 2,
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
                      subjectId: widget.subjectId,
                      difficulty: widget.difficulty,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class QuizApp extends StatefulWidget {
  final int quizId; // Thay đổi kiểu dữ liệu từ String sang int
  final String nameQuiz;
  final String subjectId;
  final String difficulty;

  QuizApp({
    required this.quizId,
    required this.nameQuiz,
    required this.subjectId,
    required this.difficulty,
  });

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
    final uri = Uri.parse(
        '${ApiUrls.questionsUrl}?quiz_id=${widget.quizId}&difficulty=${widget.difficulty}');
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        final List<Map<String, dynamic>> questionsList =
            data.cast<Map<String, dynamic>>();

        final filteredQuestions = questionsList
            .where((question) =>
                question['quiz_id'] ==
                widget.quizId.toString()) // Chuyển đổi sang String
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

  Future<String> getChatbotResponse(
      String question, String correctAnswer) async {
    //
    final String openaiApiEndpoint =
        'https://api.openai.com/v1/chat/completions';

    final Map<String, dynamic> requestData = {
      'model': 'gpt-3.5-turbo-0613',
      'messages': [
        {
          'role': 'user',
          'content':
              '$correctAnswer Đây là đáp án đúng cho câu hỏi: $question Hãy giải thích thêm giúp tôi để có thể hiểu rõ hơn về câu này, nhưng giải thích ngắn gọn thôi nhé!'
        }
      ],
      'max_tokens': 1000, // Số lượng token tối đa trong câu trả lời
    };

    final response = await http.post(
      Uri.parse(openaiApiEndpoint),
      headers: {
        'Content-Type': 'application/json',
        //
        'Accept-Charset': 'UTF-8', // Thêm header Accept-Charset
      },
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData =
          json.decode(utf8.decode(response.bodyBytes));

      // Kiểm tra nếu có thông tin trả lời từ ChatGPT
      if (responseData.containsKey('choices') &&
          responseData['choices'].isNotEmpty &&
          responseData['choices'][0].containsKey('message') &&
          responseData['choices'][0]['message'].containsKey('content')) {
        // Lấy nội dung của câu trả lời từ phản hồi
        final String chatbotResponse =
            responseData['choices'][0]['message']['content'];
        return chatbotResponse;
      } else {
        throw Exception('No response content found');
      }
    } else {
      throw Exception('Failed to communicate with OpenAI');
    }
  }

  void showExplanationDialog(
      BuildContext context, String question, String correctAnswer) async {
    try {
      // Gửi yêu cầu đến chatbot và nhận phản hồi
      final response = await getChatbotResponse(question, correctAnswer);

      // Hiển thị hộp thoại với câu trả lời từ chatbot
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Giải thích chi tiết từ Chatbot AI',
                style:
                    TextStyle(fontFamily: 'CustomFont')), // Sử dụng font ở đây
            content: SingleChildScrollView(
              child: Text(
                response,
                textAlign: TextAlign
                    .left, // Đảm bảo văn bản hiển thị từ trái sang phải
                style:
                    TextStyle(fontFamily: 'CustomFont'), // Sử dụng font ở đây
              ),
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
    } catch (e) {
      // Xử lý nếu có lỗi xảy ra trong quá trình gửi yêu cầu hoặc nhận phản hồi từ chatbot
      print('Error: $e');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Lỗi'),
            content:
                Text('Đã xảy ra lỗi khi lấy giải thích. Vui lòng thử lại sau.'),
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

                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              'Câu ${index + 1}: ${questions[index]['question']}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16.0),
                            ),
                            subtitle: Text(
                              answerText,
                              style:
                                  TextStyle(color: answerColor, fontSize: 16.0),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                showExplanationDialog(
                                  context,
                                  questions[index]['question'],
                                  questions[index]['correctanswer'],
                                );
                              },
                              child: Text('Giải thích chi tiết'),
                            ),
                          ),
                          Divider(),
                        ],
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
                      margin: EdgeInsets.only(
                          bottom: 10 * MediaQuery.of(context).devicePixelRatio),
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
                      margin: EdgeInsets.only(
                          bottom: 10 * MediaQuery.of(context).devicePixelRatio),
                      child: ElevatedButton(
                        child: Text('Câu tiếp theo'),
                        onPressed: () {
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

  Future<void> saveScore(int quizId, double score, BuildContext context) async {
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
