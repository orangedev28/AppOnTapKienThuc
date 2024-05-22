import 'package:app_ontapkienthuc/url/api_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_ontapkienthuc/main.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class UserScoresWidget extends StatefulWidget {
  @override
  _UserScoresWidgetState createState() => _UserScoresWidgetState();
}

class _UserScoresWidgetState extends State<UserScoresWidget> {
  List<Map<String, dynamic>> scores = [];
  late Future<List<Map<String, dynamic>>?> futureScores;

  @override
  void initState() {
    super.initState();
    futureScores = fetchUserScores();
  }

  Future<List<Map<String, dynamic>>?> fetchUserScores() async {
    try {
      int loggedInUserId =
          Provider.of<AuthProvider>(context, listen: false).userId;
      final url = Uri.parse(ApiUrls.getScoreUrl);
      final response = await http.post(
        url,
        body: {'user_id': loggedInUserId.toString()},
      );

      print('Raw response data: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        if (data['scores'] is List) {
          List<Map<String, dynamic>> scoresList =
              (data['scores'] as List).map<Map<String, dynamic>>((item) {
            DateTime dateAdd = DateTime.parse(item['dateadd']);

            return {
              'score': item['score'],
              'quiz_id': item['quiz_id'],
              'dateadd': dateAdd,
              'namequiz': item['namequiz'] ?? 'N/A',
            };
          }).toList();

          return scoresList;
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
            'Failed to connect to the server. HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user scores: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách điểm của bạn', style: TextStyle(fontSize: 22)),
      ),
      body: FutureBuilder(
        future: futureScores,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            scores = [...?snapshot.data] ?? [];
            print('Number of scores: ${scores.length}');
            return ListView.builder(
              itemCount: scores.length,
              itemBuilder: (context, index) {
                final score = scores[index];
                final formattedDate = DateFormat('dd/MM/yyyy HH:mm')
                    .format(score['dateadd'] as DateTime);

                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      'Điểm: ${score['score'].toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngày lưu: $formattedDate',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Bài kiểm tra: ${score['namequiz']}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
