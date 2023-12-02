import 'package:app_ontapkienthuc/autoquiz/auto_createquiz.dart';
import 'package:app_ontapkienthuc/document/viewpdf.dart';
import 'package:app_ontapkienthuc/subject/subject_list.dart';
import 'package:app_ontapkienthuc/video/watch_video.dart';
import 'package:flutter/material.dart';

Color mySkyBlueColor = Color.fromRGBO(135, 206, 235, 1);

class MenuHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Thêm dòng này để ẩn dấu điều hướng trở về
        title: Text(
          "Trang Chủ",
          style: TextStyle(fontSize: 22),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 16.0,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      width: 100.0,
                      height: 110.0,
                      child: ElevatedButton(
                        child: Text(
                          "Kiểm Tra",
                          style: TextStyle(fontSize: 20),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mySkyBlueColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SubjectList(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      width: 100.0,
                      height: 100.0,
                      child: ElevatedButton(
                        child: Text(
                          "Tài liệu",
                          style: TextStyle(fontSize: 22),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mySkyBlueColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PDFList(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      width: 100.0,
                      height: 100.0,
                      child: ElevatedButton(
                        child: Text(
                          "Video Bài Giảng",
                          style: TextStyle(fontSize: 20),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mySkyBlueColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => VideoList(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      width: 100.0,
                      height: 100.0,
                      child: ElevatedButton(
                        child: Text(
                          "Bài Viết",
                          style: TextStyle(fontSize: 20),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mySkyBlueColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PDFList(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      width: 100.0,
                      height: 90.0,
                      child: ElevatedButton(
                        child: Text(
                          "Tạo đề tự động",
                          style: TextStyle(fontSize: 20),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: mySkyBlueColor,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TopicSelectionScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
