import 'dart:async';
import 'dart:io';
import "package:http/http.dart" as http;
import "dart:convert";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFList extends StatefulWidget {
  @override
  _PDFList createState() => _PDFList();
}

class _PDFList extends State<PDFList> {
  List<Map<String, String>> documents = [];
  String searchKeyword = ""; // Từ khóa tìm kiếm

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
    final uri =
        Uri.parse("http://10.0.149.216:8080/localconnect/documents.php");
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data
              .map<Map<String, String>>((item) => {
                    'namedocument': item['namedocument'].toString(),
                    'linkdocument': item['linkdocument'].toString(),
                  })
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
                return ListTile(
                  title: Text(
                    document['namedocument'] ?? 'Tên tài liệu',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.green,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ViewPDF(
                          documentLink: document['linkdocument'],
                          documentName: document['namedocument'],
                        ),
                      ),
                    );
                  },
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
  final String? documentLink;
  final String? documentName;
  ViewPDF({this.documentLink, this.documentName});

  @override
  _ViewPDF createState() => _ViewPDF();
}

class _ViewPDF extends State<ViewPDF> {
  String pathPDF = "";

  @override
  void initState() {
    super.initState();
    final documentLink = widget.documentLink;
    if (documentLink != null) {
      fromAsset(documentLink, 'downloaded.pdf').then((f) {
        setState(() {
          pathPDF = f.path;
          if (pathPDF.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PDFScreen(
                  path: pathPDF,
                  documentName: widget.documentName,
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

  const PDFScreen({Key? key, this.path, this.documentName}) : super(key: key);

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
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
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
}
