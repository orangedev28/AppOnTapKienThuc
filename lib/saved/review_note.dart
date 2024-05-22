import 'package:app_ontapkienthuc/saved/review_score.dart';
import 'package:app_ontapkienthuc/url/api_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_ontapkienthuc/main.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:app_ontapkienthuc/ui/background/background.dart';

class MenuSaved extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Nội dung đã lưu",
          style: TextStyle(fontSize: 22),
        ),
      ),
      body: Stack(
        children: [
          Background(),
          SafeArea(
            child: Container(
              padding: EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RowButton(
                    label: "Xem điểm",
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UserScoresWidget(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16.0),
                  RowButton(
                    label: "Ghi chú",
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UserNoteList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RowButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  static const Color mySkyBlueColor = Color.fromRGBO(135, 206, 235, 1);

  const RowButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 300.0,
          height: 120.0,
          child: ElevatedButton(
            child: Text(
              label,
              style: TextStyle(fontSize: 22),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: mySkyBlueColor,
            ),
            onPressed: onPressed,
          ),
        ),
      ],
    );
  }
}

class UserNoteList extends StatefulWidget {
  @override
  _UserNoteListState createState() => _UserNoteListState();
}

class _UserNoteListState extends State<UserNoteList> {
  List<Map<String, dynamic>> notes = [];
  late Future<List<Map<String, dynamic>>?> futureNotes;

  @override
  void initState() {
    super.initState();
    futureNotes = fetchUserNotes();
  }

  Future<List<Map<String, dynamic>>?> fetchUserNotes() async {
    try {
      int loggedInUserId =
          Provider.of<AuthProvider>(context, listen: false).userId;
      final url = Uri.parse(ApiUrls.getNoteUrl);
      final response = await http.post(
        url,
        body: {'user_id': loggedInUserId.toString()},
      );

      print('Raw response data: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        if (data['notes'] is List) {
          List<Map<String, dynamic>> notesList =
              (data['notes'] as List).map<Map<String, dynamic>>((item) {
            DateTime dateAdd = DateTime.parse(item['dateadd']);

            return {
              'id': item['id'],
              'notecontent': item['notecontent'],
              'dateadd': dateAdd,
              'user_id': item['user_id'],
              'document_id': item['document_id'],
              'namedocument': item['namedocument'] ?? 'N/A',
            };
          }).toList();

          print('Number of notes: ${notesList.length}');
          return notesList;
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception(
            'Failed to connect to the server. HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user notes: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Danh sách ghi chú của bạn', style: TextStyle(fontSize: 22)),
      ),
      body: FutureBuilder(
        future: futureNotes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            notes = [...?snapshot.data] ?? [];
            print('Number of notes: ${notes.length}');
            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                final formattedDate = DateFormat('dd/MM/yyyy HH:mm')
                    .format(note['dateadd'] as DateTime);

                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      'Ghi chú ${note['id']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ngày thêm: $formattedDate',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          'Tài liệu: ${note['namedocument']}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => NoteDetailScreen(note: note),
                        ),
                      );
                    },
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

class NoteDetailScreen extends StatelessWidget {
  final Map<String, dynamic> note;

  NoteDetailScreen({required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nội dung ghi chú',
          style: TextStyle(fontSize: 22),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              note['notecontent'] ?? 'Nội dung ghi chú',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
