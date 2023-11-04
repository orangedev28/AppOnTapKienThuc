import 'package:app_ontapkienthuc/ui/background/background.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:app_ontapkienthuc/main.dart';

class UserInfoWidget extends StatefulWidget {
  @override
  _UserInfoWidgetState createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
  late String profileImage = "";
  String username = '';
  String fullName = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    int userId = Provider.of<AuthProvider>(context, listen: false).userId;
    fetchUserInfo(userId);
  }

  Future<void> fetchUserInfo(int userId) async {
    final response = await http.get(
        Uri.parse("http://10.0.149.216:8080/localconnect/user.php?id=$userId"));

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
    Provider.of<AuthProvider>(context, listen: false).setLoggedIn(0);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => MyApp(),
      ),
      (route) => false,
    );
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
