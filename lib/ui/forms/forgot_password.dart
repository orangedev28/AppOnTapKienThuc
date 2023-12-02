import 'package:app_ontapkienthuc/ui/background/background.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_ontapkienthuc/url/api_url.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({Key? key}) : super(key: key);

  @override
  _ForgotPasswordFormState createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  TextEditingController emailController = TextEditingController();

  Future<void> resetPassword(BuildContext context) async {
    if (emailController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Vui lòng nhập địa chỉ email!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
    } else {
      final uri = Uri.parse(ApiUrls.forgotpasswordUrl);

      try {
        http.Response response = await http.post(uri, body: {
          "email": emailController.text,
        });

        if (response.statusCode == 200) {
          Map<String, dynamic> data = json.decode(response.body);

          // Kiểm tra xem response có thuộc tính "status" không
          if (data.containsKey("status")) {
            if (data["status"] == "success") {
              Fluttertoast.showToast(
                msg: "Một mật khẩu mới đã được gửi đến email của bạn!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                fontSize: 16.0,
              );
              Navigator.of(context).pop();
              return;
            }
          }
          Fluttertoast.showToast(
            msg: "Địa chỉ email không tồn tại!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            fontSize: 16.0,
          );
        } else {
          Fluttertoast.showToast(
            msg: "Lỗi kết nối đến server!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        print("Error: $e");
        Fluttertoast.showToast(
          msg: "Đã xảy ra lỗi!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quên Mật Khẩu"),
      ),
      body: Stack(
        children: [
          Background(), // Hiển thị background
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 60),
                  child: const Text(
                    "Quên Mật Khẩu",
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 16, right: 32),
                  child: TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(fontSize: 20),
                      border: InputBorder.none,
                      icon: Icon(Icons.email),
                      hintText: "Nhập địa chỉ Email của tài khoản",
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    resetPassword(context);
                  },
                  child: Text("Gửi Mật Khẩu Mới"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
