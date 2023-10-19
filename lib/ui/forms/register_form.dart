import "package:app_ontapkienthuc/account/my_account.dart";
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

  Future register(BuildContext cont) async {
    if (username.text == "" ||
        password.text == "" ||
        repeatpassword.text == "") {
      Fluttertoast.showToast(
        msg: "All fields cannot be blank!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
    } else {
      if (password.text == repeatpassword.text) {
        final uri =
            Uri.parse("http://10.0.149.216:8080/localconnect/register.php");
        http.Response response = await http.post(uri, body: {
          "username": username.text,
          "password": password.text,
        });

        var data = json.decode(response.body);
        if (data == "success") {
          Fluttertoast.showToast(
            msg: "Registration success!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            fontSize: 16.0,
          );
          Navigator.push(
            cont,
            MaterialPageRoute(builder: (BuildContext context) => MyAccount()),
          );
        } else {
          Fluttertoast.showToast(
            msg: "Registration failed!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            fontSize: 16.0,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Both password have to be the same!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          height: 150,
          child: Stack(
            children: [
              Container(
                height: 150,
                margin: const EdgeInsets.only(
                  right: 70,
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
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(right: 15),
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
                    icon: Icon(
                      Icons.arrow_forward,
                    ),
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MyAccount(),
                    ),
                  );
                },
                child: const Text("Đăng nhập"),
              ),
            ),
          ],
        )
      ],
    );
  }
}
