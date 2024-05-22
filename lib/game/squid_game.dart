import 'package:flutter/material.dart';

class SquidGameWidget extends StatefulWidget {
  @override
  _SquidGameWidgetState createState() => _SquidGameWidgetState();
}

class _SquidGameWidgetState extends State<SquidGameWidget> {
  int jumps = 0;
  final List<Question> questions = [
    Question(
      text: "Câu hỏi 1: Flutter là gì?",
      options: ["Ngôn ngữ lập trình", "Framework", "Dart Compiler"],
      correctAnswer: 1,
    ),
    Question(
      text: "Câu hỏi 2: Dart là ngôn ngữ lập trình gì?",
      options: ["Java", "JavaScript", "C-style"],
      correctAnswer: 2,
    ),
    Question(
      text: "Câu hỏi 3: MaterialApp là gì?",
      options: ["Widget", "Package", "Class"],
      correctAnswer: 0,
    ),
  ];

  bool gameOver = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trò Chơi Nhảy Cầu"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Chọn lựa để nhảy cầu:",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            if (!gameOver)
              JumpingPlatform(
                question: questions[jumps],
                onJumped: (isCorrect) {
                  if (isCorrect) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bạn đã chọn đúng! Nhảy tiếp!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bạn đã rơi xuống!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    setState(() {
                      gameOver = true;
                    });
                  }
                  if (!gameOver) {
                    setState(() {
                      jumps++;
                    });
                  }
                  // Check if all questions have been answered correctly
                  if (jumps == questions.length && !gameOver) {
                    setState(() {
                      gameOver = true;
                    });
                  }
                },
              ),
            if (gameOver)
              Column(
                children: [
                  Text(
                    gameOver ? "Chúc mừng bạn an toàn!" : "Bạn đã rơi xuống!",
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Reset the game state
                      setState(() {
                        jumps = 0;
                        gameOver = false;
                      });
                    },
                    child: Text('Chơi lại'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate back to the previous screen
                      Navigator.pop(context);
                    },
                    child: Text('Thoát'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class Question {
  final String text;
  final List<String> options;
  final int correctAnswer;

  Question({
    required this.text, // Add 'required' here
    required this.options,
    required this.correctAnswer,
  });
}

class JumpingPlatform extends StatelessWidget {
  final Question question;
  final Function(bool) onJumped;

  const JumpingPlatform({required this.question, required this.onJumped});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 180,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            question.text,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
            onPressed: () {
              onJumped(false); // Pass 'false' for the incorrect answer
            },
            child: Text(
              question.options[0],
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              onJumped(true); // Pass 'true' for the correct answer
            },
            child: Text(
              question.options[1],
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              onJumped(false); // Pass 'false' for the incorrect answer
            },
            child: Text(
              question.options[2],
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
