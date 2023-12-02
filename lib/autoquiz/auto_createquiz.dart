import 'package:app_ontapkienthuc/url/api_url.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TopicSelectionScreen extends StatefulWidget {
  @override
  _TopicSelectionScreenState createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  List<String> selectedTopics = [];
  List<String> allTopics = [
    'Tin học cơ bản',
    'Khang',
    'Lập trình C',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Topic Selection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Choose up to 3 topics:'),
            Expanded(
              child: ListView.builder(
                itemCount: allTopics.length,
                itemBuilder: (context, index) {
                  final topic = allTopics[index];
                  return CheckboxListTile(
                    title: Text(topic),
                    value: selectedTopics.contains(topic),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null) {
                          if (value) {
                            // If selected, add the topic to the list
                            if (selectedTopics.length < 3) {
                              selectedTopics.add(topic);
                            }
                          } else {
                            // If unselected, remove the topic from the list
                            selectedTopics.remove(topic);
                          }
                        }
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Navigate to the quiz screen and pass selectedTopics
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AutoQuiz(selectedTopics: selectedTopics),
                  ),
                );
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class AutoQuiz extends StatefulWidget {
  final List<String> selectedTopics;

  // Add the type for the parameter
  AutoQuiz({required this.selectedTopics});

  @override
  _AutoQuizState createState() => _AutoQuizState();
}

class _AutoQuizState extends State<AutoQuiz> {
  List<Map<String, dynamic>> autoQuestions = [];
  int currentQuestionIndex = 0;
  int score = 0;

  @override
  void initState() {
    super.initState();
    // Fetch questions based on selected topics
    createAutoQuestions();
  }

  Future<void> createAutoQuestions() async {
    final uri = Uri.parse(
        '${ApiUrls.autoquizUrl}?topics=${widget.selectedTopics.join(',')}');
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = json.decode(response.body);
        if (data is List) {
          autoQuestions = data.cast<Map<String, dynamic>>();
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
    String correctAnswer = autoQuestions[currentQuestionIndex]['correctanswer'];
    bool isCorrect = selectedAnswer == correctAnswer;

    setState(() {
      autoQuestions[currentQuestionIndex]['selectedanswer'] = selectedAnswer;
      autoQuestions[currentQuestionIndex]['iscorrect'] = isCorrect;

      if (isCorrect) {
        score++;
      }
    });

    goToNextQuestion();
  }

  void goToNextQuestion() {
    if (currentQuestionIndex < autoQuestions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      // Display the final score or any other action after completing the quiz.
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
                  title: Text('Bài kiểm tra tự động'),
                  content: Text('Câu hỏi tự động từ cơ sở dữ liệu'),
                );
              },
            );
          },
          child: Text(
            'Automatic Quiz',
            style: TextStyle(fontSize: 22),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Topic Selection
            Text('Choose up to 3 topics:'),
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedTopics.length,
                itemBuilder: (context, index) {
                  final topic = widget.selectedTopics[index];
                  return CheckboxListTile(
                    title: Text(topic),
                    value: true,
                    onChanged: null, // Disable checkbox interaction
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),

            // Question display
            if (autoQuestions.isNotEmpty &&
                currentQuestionIndex < autoQuestions.length)
              Text(
                'Question ${currentQuestionIndex + 1}: ${autoQuestions[currentQuestionIndex]['question']}',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 16.0),

            // Answer buttons
            if (autoQuestions.isNotEmpty &&
                currentQuestionIndex < autoQuestions.length)
              Column(
                children: [
                  for (String option in autoQuestions[currentQuestionIndex]
                      ['options'])
                    buildAnswerButton(option),
                ],
              ),
            SizedBox(height: 16.0),

            // Next Question Button
            ElevatedButton(
              child: Text('Next Question'),
              onPressed: () {
                if (currentQuestionIndex < autoQuestions.length - 1) {
                  goToNextQuestion();
                } else {
                  // Quiz completed, show the final score or perform any action.
                }
              },
            ),
            SizedBox(height: 16.0),

            // Score display
            Text(
              'Score: $score/${autoQuestions.length}',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton buildAnswerButton(String answerText) {
    bool isSelected =
        answerText == autoQuestions[currentQuestionIndex]['selectedanswer'];

    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color?>(
          isSelected
              ? (isSelected && autoQuestions[currentQuestionIndex]['iscorrect']
                  ? Colors.green
                  : Colors.red)
              : null,
        ),
      ),
      onPressed: () {
        if (!isSelected) {
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
}
