import 'package:app_ontapkienthuc/ui/background/background.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:app_ontapkienthuc/main.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
    final response = await http.get(Uri.parse(
        "http://172.20.149.208:8080/localconnect/user.php?id=$userId"));

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
                Navigator.of(context).pop(); // Đóng hộp thoại cảnh báo
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
      // Thay đổi UI hiển thị hình ảnh đã chọn
      setState(() {
        profileImage = pickedFile.path;
        print(pickedFile.path);
      });

      // Lưu đường dẫn ảnh vào cơ sở dữ liệu
      await updateProfileImageInDatabase(pickedFile.path);
    }
  }

  Future<void> updateProfileImageInDatabase(String imagePath) async {
    var url =
        Uri.parse('http://172.20.149.208:8080/localconnect/update_image.php');

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
      } else {
        print('Lỗi: ${response.statusCode}');
      }
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
          Background(), // Display background
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage: profileImage.isNotEmpty
                        ? AssetImage(profileImage)
                        : null,
                  ),
                ),
                SizedBox(width: 20),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
