import 'package:flutter/material.dart';

class ReviewQuiz extends StatelessWidget {
  final List<Map<String, dynamic>> questions;

  ReviewQuiz({required this.questions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Xem lại bài kiểm tra',
          style: TextStyle(fontSize: 22),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: questions.length,
          itemBuilder: (context, index) {
            String selectedAnswer = questions[index]['selectedanswer'];
            String correctAnswer = questions[index]['correctanswer'];
            bool isCorrect = questions[index]['iscorrect'] == true;

            return ListTile(
              title: Text(
                'Câu ${index + 1}: ${questions[index]['question']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildAnswerTile(
                    'Lựa chọn của bạn: $selectedAnswer',
                    backgroundColor: isCorrect ? Colors.green : Colors.red,
                  ),
                  buildAnswerTile(
                    'Đáp án đúng: $correctAnswer',
                    backgroundColor: Colors.green,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildAnswerTile(String text, {Color? backgroundColor}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      padding: EdgeInsets.all(8.0),
      color: backgroundColor,
      child: Text(
        text,
        style: TextStyle(fontSize: 16.0, color: Colors.white),
      ),
    );
  }
}
