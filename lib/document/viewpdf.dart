import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class Document {
  String name;
  String path;

  Document({required this.name, required this.path});
}

List<Document> documents = [
  Document(
    name: 'Test1',
    path: 'D:\flutterapp\appvscode\app_ontapkienthuc\assets\documents.pdf',
  ),
  Document(
      name: 'Test2',
      path:
          'D:\flutterapp\appvscode\app_ontapkienthuc\assets\thuhoachkhang.pdf'),
  // Add other documents to the list here
];

class PagePDF extends StatelessWidget {
  void openPDF(BuildContext context, String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFView(
          filePath: path,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trang làm bài kiểm tra"),
      ),
      body: ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(documents[index].name),
            onTap: () {
              openPDF(context, documents[index].path);
            },
          );
        },
      ),
    );
  }
}
