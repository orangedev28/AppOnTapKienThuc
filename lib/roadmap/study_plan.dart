import 'dart:convert';
import 'package:app_ontapkienthuc/ui/background/background.dart';
import 'package:app_ontapkienthuc/url/api_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SubjectData {
  final dynamic id; // Change the type to dynamic
  final String name;
  final List<Map<String, dynamic>> documents;
  final List<Map<String, dynamic>> videos;
  final List<Map<String, dynamic>> quizzes;

  SubjectData({
    required this.id,
    required this.name,
    required this.documents,
    required this.videos,
    required this.quizzes,
  });
}

class SubjectListForPlan extends StatefulWidget {
  @override
  _SubjectListState createState() => _SubjectListState();
}

class _SubjectListState extends State<SubjectListForPlan> {
  List<SubjectData> subjectsData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final uri = Uri.parse(ApiUrls.getStudyPlan);
    http.Response response = await http.get(uri);

    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      try {
        final Map<String, dynamic> responseData = json.decode(response.body);

        setState(() {
          subjectsData = (responseData['subjects'] as List<dynamic>)
              .map(
                (data) => SubjectData(
                  id: data['id'],
                  name: data['name'],
                  quizzes: (responseData['quizzes'] as List<dynamic>)
                      .where((quiz) => quiz['subject_id'] == data['id'])
                      .map<Map<String, dynamic>>(
                          (quiz) => quiz as Map<String, dynamic>)
                      .toList(),
                  documents: (responseData['documents'] as List<dynamic>)
                      .where((document) => document['subject_id'] == data['id'])
                      .map<Map<String, dynamic>>(
                          (document) => document as Map<String, dynamic>)
                      .toList(),
                  videos: (responseData['videos'] as List<dynamic>)
                      .where((video) => video['subject_id'] == data['id'])
                      .map<Map<String, dynamic>>(
                          (video) => video as Map<String, dynamic>)
                      .toList(),
                ),
              )
              .toList();
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
          "Chọn môn học tạo lộ trình",
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
                    subjectsData[index].name,
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(16.0),
                    backgroundColor: mySkyBlueColor,
                  ),
                  onPressed: () {
                    SubjectData selectedSubject = subjectsData[index];
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StudyPlanWidget(
                          documents: selectedSubject.documents,
                          videos: selectedSubject.videos,
                          quizzes: selectedSubject.quizzes,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            itemCount: subjectsData.length,
          ),
        ],
      ),
    );
  }
}

class StudyPlanWidget extends StatefulWidget {
  final List<Map<String, dynamic>> documents;
  final List<Map<String, dynamic>> videos;
  final List<Map<String, dynamic>> quizzes;

  StudyPlanWidget({
    required this.documents,
    required this.videos,
    required this.quizzes,
  });

  @override
  _StudyPlanWidgetState createState() => _StudyPlanWidgetState();
}

class _StudyPlanWidgetState extends State<StudyPlanWidget> {
  List<Map<String, dynamic>> documents = [];
  List<Map<String, dynamic>> videos = [];
  List<Map<String, dynamic>> quizzes = [];

  @override
  void initState() {
    super.initState();
    // Initialize the state with the provided data or an empty list as fallback
    documents = widget.documents ?? [];
    videos = widget.videos ?? [];
    quizzes = widget.quizzes ?? [];
  }

  @override
  void didUpdateWidget(covariant StudyPlanWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the state when the widget properties change
    documents = widget.documents ?? [];
    videos = widget.videos ?? [];
    quizzes = widget.quizzes ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lộ trình Ôn tập'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildDocumentsSection(documents),
          _buildVideosSection(videos),
          _buildQuizzesSection(quizzes),
        ],
      ),
    );
  }

  Widget _buildDocumentsSection(List<Map<String, dynamic>> documents) {
    return _buildSection('Documents', documents, (item) {
      return _buildDocumentItem(item);
    });
  }

  Widget _buildVideosSection(List<Map<String, dynamic>> videos) {
    return _buildSection('Videos', videos, (item) {
      return _buildVideoItem(item);
    });
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> items,
      Widget Function(Map<String, dynamic>? item) itemBuilder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        if (items.isNotEmpty)
          Column(
            children: items.map((item) => itemBuilder(item)).toList(),
          )
        else
          Text('No $title available.'),
        SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildVideoItem(Map<String, dynamic>? video) {
    if (video == null) {
      // Handle the case where the video is null
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(video['namevideo'] ?? 'Untitled Video'),
        // Implement onTap as needed
      ),
    );
  }

  Widget _buildDocumentItem(Map<String, dynamic>? item) {
    if (item == null) {
      // Handle the case where the item is null
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(item['namedocument'] ?? 'Untitled Document'),
        // Implement onTap as needed
      ),
    );
  }

  Widget _buildQuizzesSection(List<Map<String, dynamic>> quizzes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quizzes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        if (quizzes.isNotEmpty)
          Column(
            children: quizzes.map((quiz) => _buildQuizItem(quiz)).toList(),
          )
        else
          Text('No quizzes available.'),
        SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildQuizItem(Map<String, dynamic>? quiz) {
    if (quiz == null) {
      // Handle the case where the quiz is null
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(quiz['namequiz'] ?? 'Untitled Quiz'),
        // Implement onTap as needed
      ),
    );
  }
}
