import 'dart:async';
import 'dart:io';
import 'package:app_ontapkienthuc/url/api_url.dart';
import "package:http/http.dart" as http;
import "dart:convert";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:app_ontapkienthuc/ui/background/background.dart';
import 'package:app_ontapkienthuc/main.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SubjectListForPDFs extends StatefulWidget {
  @override
  _SubjectListState createState() => _SubjectListState();
}

class _SubjectListState extends State<SubjectListForPDFs> {
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
              crossAxisCount: 2, // Số cột
              crossAxisSpacing: 8.0, // Khoảng cách giữa các ô theo chiều ngang
              mainAxisSpacing: 8.0, // Khoảng cách giữa các ô theo chiều dọc
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PDFList(
                          subjectId: subjects[index]['id'],
                        ),
                      ),
                    );
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
}

class PDFList extends StatefulWidget {
  final String subjectId;

  PDFList({required this.subjectId});

  @override
  _PDFList createState() => _PDFList();
}

class _PDFList extends State<PDFList> {
  List<Map<String, String>> documents = [];
  String searchKeyword = "";

  @override
  void initState() {
    super.initState();
    fetchDocuments().then((data) {
      setState(() {
        documents = data ?? [];
      });
    });
  }

  Future<List<Map<String, String>>?> fetchDocuments() async {
    final uri = Uri.parse(ApiUrls.documentsUrl);
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data
              .map<Map<String, String>>((item) => {
                    'id': item['id'].toString(),
                    'namedocument': item['namedocument'].toString(),
                    'linkdocument': item['linkdocument'].toString(),
                    'subject_id': item['subject_id'].toString()
                  })
              .where((document) => document['subject_id'] == widget.subjectId)
              .toList();
        } else {
          throw Exception('Response is not a list');
        }
      } catch (e) {
        throw Exception('Failed to parse JSON');
      }
    } else {
      throw Exception('Failed to connect to the server');
    }
  }

  List<Map<String, String>> getFilteredDocuments() {
    if (searchKeyword.isEmpty) {
      return documents;
    } else {
      return documents.where((document) {
        final name = document['namedocument'] ?? '';
        return name.toLowerCase().contains(searchKeyword.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDocuments = getFilteredDocuments();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Danh sách tài liệu',
          style: TextStyle(fontSize: 22),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchKeyword = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Tìm kiếm theo tên tài liệu',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredDocuments.length,
              itemBuilder: (context, index) {
                final document = filteredDocuments[index];
                return Card(
                  elevation: 2, // Add some elevation for a shadow effect
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      document['namedocument'] ?? 'Tên tài liệu',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.green,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewPDF(
                            documentLink: document['linkdocument'],
                            documentName: document['namedocument'],
                            documentId: document['id'],
                          ),
                        ),
                      ).then((value) {
                        setState(() {});
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ViewPDF extends StatefulWidget {
  final String? documentId;
  final String? documentLink;
  final String? documentName;
  ViewPDF({this.documentId, this.documentLink, this.documentName});

  @override
  _ViewPDF createState() => _ViewPDF();
}

class _ViewPDF extends State<ViewPDF> {
  String pathPDF = "";

  @override
  void initState() {
    super.initState();
    final documentLink = widget.documentLink;
    final documentId = widget.documentId;
    if (documentLink != null) {
      fromAsset(documentLink, 'downloaded.pdf').then((f) {
        setState(() {
          pathPDF = f.path;
          if (pathPDF.isNotEmpty) {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PDFScreen(
                  path: pathPDF,
                  documentName: widget.documentName,
                  documentId: documentId,
                ),
              ),
            );
          }
        });
      });
    }
  }

  Future<File> fromAsset(String asset, String filename) async {
    Completer<File> completer = Completer();
    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");

      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error loading the asset file: $e');
    }

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            PDFView(
              filePath: pathPDF,
              onRender: (_pages) {},
              onError: (error) {
                print(error.toString());
              },
              onPageError: (page, error) {
                print('$page: ${error.toString()}');
              },
              onViewCreated: (PDFViewController pdfViewController) {},
            ),
          ],
        ),
      ),
    );
  }
}

class PDFScreen extends StatefulWidget {
  final String? path;
  final String? documentName;
  final String? documentId;

  const PDFScreen({Key? key, this.path, this.documentName, this.documentId})
      : super(key: key);

  @override
  _PDFScreen createState() => _PDFScreen();
}

class _PDFScreen extends State<PDFScreen> with WidgetsBindingObserver {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.documentName ?? 'Tên tài liệu',
          style: TextStyle(fontSize: 22),
        ),
        actions: <Widget>[
          //IconButton(
          //icon: const Icon(Icons.share),
          //onPressed: () {},
          //),
          IconButton(
            icon: const Icon(Icons.note_add),
            onPressed: () {
              _showNoteDialog();
            },
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.path,
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()
              : Center(
                  child: Text(errorMessage),
                )
        ],
      ),
    );
  }

  void _showNoteDialog() {
    TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ghi chú"),
          content: Container(
            width: double.maxFinite,
            child: TextField(
              controller: noteController,
              maxLines: null, // Cho phép nhiều dòng
              decoration: InputDecoration(
                hintText: "Nhập ghi chú của bạn",
                contentPadding: EdgeInsets.all(16.0),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _saveNoteToDatabase(noteController.text);
                Navigator.of(context).pop();
              },
              child: Text("Lưu"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Hủy"),
            ),
          ],
        );
      },
    );
  }

  void _saveNoteToDatabase(String note) async {
    int loggedInUserId =
        Provider.of<AuthProvider>(context, listen: false).userId;

    if (widget.documentId != null) {
      final url = Uri.parse(ApiUrls.saveNoteUrl);
      final response = await http.post(
        url,
        body: {
          'user_id': loggedInUserId.toString(),
          'document_id': widget.documentId!,
          'note': note,
        },
      );

      if (response.statusCode == 200) {
        print('Note saved successfully');
        Fluttertoast.showToast(
          msg: "Đã lưu ghi chú!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
        );
      } else {
        print('Failed to save note. HTTP error: ${response.statusCode}');
      }
    } else {
      print('Document ID is null');
    }
  }
}
