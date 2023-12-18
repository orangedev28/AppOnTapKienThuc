import 'package:app_ontapkienthuc/autoquiz/auto_createquiz.dart';
import 'package:app_ontapkienthuc/ui/background/background.dart';
import 'package:flutter/material.dart';
import 'package:app_ontapkienthuc/document/viewpdf.dart';
import 'package:app_ontapkienthuc/subject/subject_list.dart';
import 'package:app_ontapkienthuc/video/watch_video.dart';

class MenuHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Trang Chủ",
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
                  Expanded(
                    child: RowButton(
                      label: "Kiểm Tra",
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SubjectList(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Expanded(
                    child: RowButton(
                      label: "Tài Liệu PDF",
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SubjectListForPDFs(),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Expanded(
                    child: RowButton(
                      label: "Video Bài Giảng",
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SubjectListForVideos(),
                          ),
                        );
                      },
                    ),
                  ),
                  /*
                  SizedBox(height: 16.0),
                  Expanded(
                    child: RowButton(
                      label: "Bài Viết",
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PDFList(),
                          ),
                        );
                      },
                    ),
                  ),
                  */
                  SizedBox(height: 16.0),
                  Expanded(
                    child: RowButton(
                      label: "Tạo Đề Tự Động",
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TopicSelectionScreen(),
                          ),
                        );
                      },
                    ),
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
              style: TextStyle(fontSize: 20),
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
