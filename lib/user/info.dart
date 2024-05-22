import 'package:app_ontapkienthuc/ui/background/background.dart';
import 'package:app_ontapkienthuc/url/api_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:app_ontapkienthuc/main.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

class UserInfoWidget extends StatefulWidget {
  @override
  _UserInfoWidgetState createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
  late String profileImage = "";
  String username = '';
  String fullName = '';
  String email = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    int userId = Provider.of<AuthProvider>(context, listen: false).userId;
    fetchUserInfo(userId);
  }

  Future<void> fetchUserInfo(int userId) async {
    final response =
        await http.get(Uri.parse(ApiUrls.infoUserUrl + "?id=$userId"));

    if (response.statusCode == 200) {
      dynamic responseData = json.decode(response.body);

      if (responseData is Map<String, dynamic>) {
        setState(() {
          username = responseData['username'];
          fullName = responseData['fullname'];
          email = responseData['email'];
          if (responseData.containsKey('image')) {
            profileImage = responseData['image'];
          }
        });
      } else {
        print('Response data is not in the expected format.');
      }
    } else {
      print('Failed to load user information');
    }
  }

  void logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận đăng xuất'),
          content: Text('Có chắc bạn muốn đăng xuất khỏi tài khoản không?'),
          actions: <Widget>[
            TextButton(
              child: Text('Có'),
              onPressed: () {
                performLogout(context);
              },
            ),
            TextButton(
              child: Text('Không'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void performLogout(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false).setLoggedIn(0);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => MyApp(),
      ),
      (route) => false,
    );
  }

  void _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        profileImage = pickedFile.path;
        print(pickedFile.path);
      });

      await updateProfileImageInDatabase(pickedFile.path);
    }
  }

  Future<void> updateProfileImageInDatabase(String imagePath) async {
    var url = Uri.parse(ApiUrls.updateImageUrl);

    int loggedInUserId =
        Provider.of<AuthProvider>(context, listen: false).userId;

    if (loggedInUserId != 0) {
      var body = json.encode({
        'image': imagePath,
        'id': loggedInUserId,
      });

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        print('Ảnh thay đổi đã được lưu vào cơ sở dữ liệu!');
        Fluttertoast.showToast(
          msg: "Đổi ảnh đại diện thành công!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
        );
      } else {
        print('Lỗi: ${response.statusCode}');
      }
    }
  }

  void _showChangePasswordDialog() {
    TextEditingController _currentPasswordController = TextEditingController();
    TextEditingController _newPasswordController = TextEditingController();
    TextEditingController _confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: AlertDialog(
                title: Text('Đổi Mật Khẩu'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _currentPasswordController,
                      obscureText: true,
                      decoration:
                          InputDecoration(labelText: 'Mật Khẩu Hiện Tại'),
                    ),
                    TextField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Mật Khẩu Mới'),
                    ),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration:
                          InputDecoration(labelText: 'Xác Nhận Mật Khẩu Mới'),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Hủy'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Đổi Mật Khẩu'),
                    onPressed: () {
                      _changePassword(
                        _currentPasswordController.text,
                        _newPasswordController.text,
                        _confirmPasswordController.text,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _changePassword(String currentPassword, String newPassword,
      String confirmPassword) async {
    int userId = Provider.of<AuthProvider>(context, listen: false).userId;

    if (currentPassword == "" || newPassword == "" || confirmPassword == "") {
      Fluttertoast.showToast(
        msg: "Các trường không được bỏ trống!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
      return;
    }

    if (newPassword == currentPassword) {
      Fluttertoast.showToast(
        msg: "Mật khẩu mới bị trùng mật khẩu cũ!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Fluttertoast.showToast(
        msg: "Xác nhận mật khẩu mới thất bại!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
      return;
    }

    String errorMessage = "";

    if (newPassword.length < 8) {
      errorMessage = "Mật khẩu cần ít nhất 8 ký tự, ";
    }

    RegExp upperCaseRegex = RegExp(r'[A-Z]');
    if (!upperCaseRegex.hasMatch(newPassword)) {
      errorMessage += "1 chữ hoa, ";
    }

    RegExp digitRegex = RegExp(r'[0-9]');
    if (!digitRegex.hasMatch(newPassword)) {
      errorMessage += "1 số, ";
    }

    RegExp specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    if (!specialCharRegex.hasMatch(newPassword)) {
      errorMessage += "1 ký tự đặc biệt, ";
    }

    if (errorMessage.isNotEmpty) {
      errorMessage = errorMessage.substring(
          0, errorMessage.length - 2); // Remove the last comma and space
      Fluttertoast.showToast(
        msg: "Mật khẩu cần $errorMessage!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        fontSize: 16.0,
      );
      return;
    }

    try {
      var url = Uri.parse(ApiUrls.changePasswordUrl);
      var body = jsonEncode({
        'id': userId,
        'current_password': currentPassword,
        'new_password': newPassword,
      });

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          Fluttertoast.showToast(
            msg: "Đổi mật khẩu thành công!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            fontSize: 16.0,
          );
          Navigator.of(context).pop();
        } else if (responseData['status'] == 'incorrect_current_password') {
          Fluttertoast.showToast(
            msg: "Mật khẩu hiện tại không chính xác!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            fontSize: 16.0,
          );
        } else {
          Fluttertoast.showToast(
            msg: "Đổi mật khẩu thất bại!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            fontSize: 16.0,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Lỗi Server!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
        );
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Thông tin tài khoản',
          style: TextStyle(fontSize: 22),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Background(),
          Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 40.0),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage: profileImage.isNotEmpty
                            ? FileImage(File(profileImage))
                            : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    FloatingActionButton(
                      onPressed: _pickImage,
                      tooltip: 'Thay đổi ảnh',
                      child: Icon(Icons.add_a_photo),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Username: $username',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Họ tên: $fullName',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Email: $email',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _showChangePasswordDialog,
                      child: Text('Đổi mật khẩu'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
