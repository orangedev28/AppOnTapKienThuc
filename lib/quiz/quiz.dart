import 'package:flutter/material.dart';

class QuizListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Danh sách bài kiểm tra',
          style: TextStyle(fontSize: 22),
        ),
      ),
      body: ListView(
        children: [
          // List of _createQuizRoute()
          // Example:
          ListTile(
            title: Text(
              'Bài Test 1',
              style: TextStyle(
                fontSize: 20.0, // Set the desired font size
                color: Colors.green, // Set the desired color
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => QuizApp(),
                ),
              );
            },
          ),
          ListTile(
            title: Text(
              'Bài Test 2',
              style: TextStyle(
                fontSize: 20.0, // Set the desired font size
                color: Colors.green, // Set the desired color
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => QuizApp(),
                ),
              );
            },
          ),
          // Add more ListTiles for each quiz
        ],
      ),
    );
  }
}

class QuizApp extends StatefulWidget {
  @override
  _QuizAppState createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  int currentQuestionIndex = 0;
  int score = 0;
  bool showResult = false;

  List<Map<String, dynamic>> questions = [
    {
      'question': 'Question 1: What is Flutter?',
      'answers': [
        'A. Mobile app development framework',
        'B. Programming language',
        'C. IDE for app development',
        'D. Database'
      ],
      'correctAnswer': 'A. Mobile app development framework',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question': 'Question 2: Flutter is developed by which company?',
      'answers': ['A. Google', 'B. Facebook', 'C. Microsoft', 'D. Apple'],
      'correctAnswer': 'A. Google',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question':
          'Question 3: Widget là khái niệm quan trọng trong Flutter, nó được sử dụng để làm gì?',
      'answers': [
        'A. Xây dựng giao diện người dùng',
        'B. Quản lý trạng thái ứng dụng',
        'C. Thực hiện các hiệu ứng tinh tế',
        'D. Tối ưu hóa hiệu suất ứng dụng'
      ],
      'correctAnswer': 'A. Xây dựng giao diện người dùng',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question': 'Question 4: 1 + 1 =?',
      'answers': ['A. 2', 'B. 4', 'C. 5', 'D. 11'],
      'correctAnswer': 'A. 2',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question': 'Question 5: Flutter viết bằng ngôn ngữ gì?',
      'answers': ['A. C++', 'B. Java', 'C. C#', 'D. Dart'],
      'correctAnswer': 'D. Dart',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question': 'Question 6: Flutter viết bằng ngôn ngữ gì?',
      'answers': ['A. C++', 'B. Java', 'C. C#', 'D. Dart'],
      'correctAnswer': 'D. Dart',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question': 'Question 7: Flutter viết bằng ngôn ngữ gì?',
      'answers': ['A. C++', 'B. Java', 'C. C#', 'D. Dart'],
      'correctAnswer': 'D. Dart',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question': 'Question 8: Flutter viết bằng ngôn ngữ gì?',
      'answers': ['A. C++', 'B. Java', 'C. C#', 'D. Dart'],
      'correctAnswer': 'D. Dart',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question': 'Question 9: Flutter viết bằng ngôn ngữ gì?',
      'answers': ['A. C++', 'B. Java', 'C. C#', 'D. Dart'],
      'correctAnswer': 'D. Dart',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question': 'Question 10: Flutter viết bằng ngôn ngữ gì?',
      'answers': ['A. C++', 'B. Java', 'C. C#', 'D. Dart'],
      'correctAnswer': 'D. Dart',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question': 'Question 11: Flutter viết bằng ngôn ngữ gì?',
      'answers': ['A. C++', 'B. Java', 'C. C#', 'D. Dart'],
      'correctAnswer': 'D. Dart',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question': 'Question 12: Flutter viết bằng ngôn ngữ gì?',
      'answers': ['A. C++', 'B. Java', 'C. C#', 'D. Dart'],
      'correctAnswer': 'D. Dart',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question': 'Question 13: Flutter viết bằng ngôn ngữ gì?',
      'answers': ['A. C++', 'B. Java', 'C. C#', 'D. Dart'],
      'correctAnswer': 'D. Dart',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question': 'Question 14: Flutter viết bằng ngôn ngữ gì?',
      'answers': ['A. C++', 'B. Java', 'C. C#', 'D. Dart'],
      'correctAnswer': 'D. Dart',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question': 'Question 15: Flutter viết bằng ngôn ngữ gì?',
      'answers': ['A. C++', 'B. Java', 'C. C#', 'D. Dart'],
      'correctAnswer': 'D. Dart',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question': 'Question 16: Flutter viết bằng ngôn ngữ gì?',
      'answers': ['A. C++', 'B. Java', 'C. C#', 'D. Dart'],
      'correctAnswer': 'D. Dart',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question': 'Question 17: Flutter viết bằng ngôn ngữ gì?',
      'answers': ['A. C++', 'B. Java', 'C. C#', 'D. Dart'],
      'correctAnswer': 'D. Dart',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question': 'Question 18: Flutter viết bằng ngôn ngữ gì?',
      'answers': ['A. C++', 'B. Java', 'C. C#', 'D. Dart'],
      'correctAnswer': 'D. Dart',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question': 'Question 19: Flutter viết bằng ngôn ngữ gì?',
      'answers': ['A. C++', 'B. Java', 'C. C#', 'D. Dart'],
      'correctAnswer': 'D. Dart',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    {
      'question': 'Question 20: Flutter viết bằng ngôn ngữ gì?',
      'answers': ['A. C++', 'B. Java', 'C. C#', 'D. Dart'],
      'correctAnswer': 'D. Dart',
      'selectedAnswer': '',
      'isCorrect': false,
    },
    // Add more questions here
  ];

  void checkAnswer(String selectedAnswer) {
    String correctAnswer = questions[currentQuestionIndex]['correctAnswer'];
    bool isCorrect = selectedAnswer == correctAnswer;

    setState(() {
      questions[currentQuestionIndex]['selectedAnswer'] = selectedAnswer;
      questions[currentQuestionIndex]['isCorrect'] = isCorrect;

      if (isCorrect) {
        score++;
      }
    });

    goToNextQuestion();
  }

  void goToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      showResult = true;
    }
  }

  void resetQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      score = 0;
      showResult = false;

      for (var question in questions) {
        question['selectedAnswer'] = '';
        question['isCorrect'] = false;
      }
    });
  }

  double calculateAverageScore() {
    return (score / questions.length) * 10;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Bài Test 1',
            style: TextStyle(fontSize: 22),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  questions[currentQuestionIndex]['question'],
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                ...questions[currentQuestionIndex]['answers'].map((answer) {
                  bool isSelected = answer ==
                      questions[currentQuestionIndex]['selectedAnswer'];

                  return ElevatedButton(
                    child: Text(answer),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color?>(
                        isSelected
                            ? (isSelected &&
                                    questions[currentQuestionIndex]['isCorrect']
                                ? Colors.green
                                : Colors.red)
                            : null,
                      ),
                    ),
                    onPressed: () {
                      if (!showResult) {
                        checkAnswer(answer);
                      }
                    },
                  );
                }).toList(),
                SizedBox(height: 16.0),
                if (showResult)
                  Text(
                    'Điểm của bạn: ${calculateAverageScore().toStringAsFixed(1)}/10',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                SizedBox(height: 16.0),
                if (showResult)
                  ElevatedButton(
                    child: Text('Làm lại'),
                    onPressed: resetQuiz,
                  ),
                if (showResult) SizedBox(height: 16.0),
                if (showResult)
                  Text(
                    'Đáp án:',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                if (showResult) SizedBox(height: 8.0),
                if (showResult)
                  SingleChildScrollView(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        String selectedAnswer =
                            questions[index]['selectedAnswer'];
                        String correctAnswer =
                            questions[index]['correctAnswer'];

                        String answerText;
                        Color answerColor;

                        if (correctAnswer != selectedAnswer) {
                          answerText =
                              'Câu trả lời sai: $selectedAnswer\nĐáp án đúng: $correctAnswer';
                          answerColor = Colors.red;
                        } else {
                          answerText = 'Đúng: $correctAnswer';
                          answerColor = Colors.green;
                        }

                        return ListTile(
                          title: Text(
                            questions[index]['question'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            answerText,
                            style: TextStyle(color: answerColor),
                          ),
                        );
                      },
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
