import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import "package:fluttertoast/fluttertoast.dart";
import "dart:convert";

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterForm();
}

class _RegisterForm extends State<RegisterForm> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController repeatpassword = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController fullname = TextEditingController();

  Future<bool> validatePassword(String password) async {
    String errorMessage = "";

    // Kiểm tra xem mật khẩu có ít nhất 8 ký tự không
    if (password.length < 8) {
      errorMessage = "Mật khẩu cần ít nhất 8 ký tự, ";
    }

    // Kiểm tra mật khẩu có ít nhất 1 chữ hoa không
    RegExp upperCaseRegex = RegExp(r'[A-Z]');
    if (!upperCaseRegex.hasMatch(password)) {
      errorMessage += "1 chữ hoa, ";
    }

    // Kiểm tra mật khẩu có ít nhất 1 số không
    RegExp digitRegex = RegExp(r'[0-9]');
    if (!digitRegex.hasMatch(password)) {
      errorMessage += "1 số, ";
    }

    // Kiểm tra mật khẩu có ít nhất 1 ký tự đặc biệt không
    RegExp specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    if (!specialCharRegex.hasMatch(password)) {
      errorMessage += "1 ký tự đặc biệt, ";
    }

    if (errorMessage.isNotEmpty) {
      errorMessage = errorMessage.substring(
          0, errorMessage.length - 2); // Xóa dấu phẩy cuối cùng và khoảng trắng
      Fluttertoast.showToast(
        msg: "Mật khẩu cần $errorMessage!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
      return false;
    }

    return true;
  }

// Function to register user
  Future<void> register(BuildContext cont) async {
    if (username.text == "" ||
        password.text == "" ||
        repeatpassword.text == "" ||
        email.text == "" ||
        fullname.text == "") {
      Fluttertoast.showToast(
        msg: "Các trường không được để trống!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
    } else {
      RegExp emailRegex = RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'); // Kiểm tra định dạng email

      if (!emailRegex.hasMatch(email.text)) {
        Fluttertoast.showToast(
          msg: "Địa chỉ email không hợp lệ!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
        );
        return;
      } else {
        if (password.text == repeatpassword.text) {
          bool isValidPassword = await validatePassword(password.text);
          if (isValidPassword) {
            final registerUri =
                Uri.parse("http://10.0.149.216:8080/localconnect/register.php");
            http.Response registerResponse =
                await http.post(registerUri, body: {
              "username": username.text,
              "password": password.text,
              "email": email.text,
              "fullname": fullname.text,
            });

            var registerData = json.decode(registerResponse.body);
            switch (registerData) {
              case "success":
                Fluttertoast.showToast(
                  msg: "Đăng ký tài khoản thành công!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  fontSize: 16.0,
                );
                Navigator.of(cont).pop();
                break;
              case "exists":
                Fluttertoast.showToast(
                  msg: "Username đã tồn tại!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  fontSize: 16.0,
                );
                break;
              default:
                Fluttertoast.showToast(
                  msg: "Đăng ký thất bại!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  fontSize: 16.0,
                );
            }
          }
        } else {
          Fluttertoast.showToast(
            msg: "Xác nhận mật khẩu thất bại!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            fontSize: 16.0,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height *
              0.12), // 5% chiều cao màn hình
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 60),
              child: const Text(
                "Đăng Ký Tài Khoản",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 500, // Điều chỉnh độ cao của phần Stack
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                      left: 20,
                      right: 70,
                      top: 20,
                      bottom: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(100),
                        bottomRight: Radius.circular(100),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 16, right: 32),
                          child: TextField(
                            controller: username,
                            decoration: InputDecoration(
                              hintStyle: TextStyle(fontSize: 20),
                              border: InputBorder.none,
                              icon: Icon(Icons.account_circle_rounded),
                              hintText: "Tên đăng nhập",
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 16, right: 32),
                          child: TextField(
                            controller: password,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintStyle: TextStyle(fontSize: 22),
                              border: InputBorder.none,
                              icon: Icon(Icons.account_circle_rounded),
                              hintText: "********",
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 16, right: 32),
                          child: TextField(
                            controller: repeatpassword,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintStyle: TextStyle(fontSize: 22),
                              border: InputBorder.none,
                              icon: Icon(Icons.account_circle_rounded),
                              hintText: "Xác nhận mật khẩu",
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 16, right: 32),
                          child: TextField(
                            controller: email,
                            decoration: InputDecoration(
                              hintStyle: TextStyle(fontSize: 20),
                              border: InputBorder.none,
                              icon: Icon(Icons.account_circle_rounded),
                              hintText: "Email",
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 16, right: 32),
                          child: TextField(
                            controller: fullname,
                            decoration: InputDecoration(
                              hintStyle: TextStyle(fontSize: 20),
                              border: InputBorder.none,
                              icon: Icon(Icons.account_circle_rounded),
                              hintText: "Họ tên",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 220, // Điều chỉnh vị trí của nút đăng ký
                    right: 20,
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green[200]!.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xff1bccba),
                            Color(0xff22e2ab),
                          ],
                        ),
                      ),
                      child: IconButton(
                        color: Colors.white,
                        onPressed: () {
                          register(context);
                        },
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 16, top: 24),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xffe98f60),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(); // Quay trở lại màn hình trước đó
                    },
                    child: const Text("Đăng nhập"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
