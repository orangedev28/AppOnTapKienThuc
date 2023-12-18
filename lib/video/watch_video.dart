import 'dart:async';
import 'dart:convert';
import 'package:app_ontapkienthuc/url/api_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:app_ontapkienthuc/ui/background/background.dart';

class SubjectListForVideos extends StatefulWidget {
  @override
  _SubjectListState createState() => _SubjectListState();
}

class _SubjectListState extends State<SubjectListForVideos> {
  List<Map<String, dynamic>> subjects = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final uri = Uri.parse(ApiUrls.subjectsUrl);
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      try {
        final List<dynamic> subjectData = json.decode(response.body);

        setState(() {
          subjects = List<Map<String, dynamic>>.from(subjectData);
        });
      } catch (e) {
        print("Error parsing JSON: $e");
      }
    } else {
      print("HTTP error: ${response.statusCode}");
    }
  }

  Color mySkyBlueColor = Color.fromRGBO(135, 206, 235, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Danh sách môn học",
          style: TextStyle(fontSize: 22),
        ),
      ),
      body: Stack(
        children: [
          Background(),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Số cột
              crossAxisSpacing: 8.0, // Khoảng cách giữa các ô theo chiều ngang
              mainAxisSpacing: 8.0, // Khoảng cách giữa các ô theo chiều dọc
            ),
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.all(8.0), // Add padding around the button
                child: ElevatedButton(
                  child: Text(
                    subjects[index]['namesubject'],
                    style: TextStyle(fontSize: 18), // Reduce the font size
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(16.0), // Increase the padding
                    backgroundColor: mySkyBlueColor,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => VideoList(
                          subjectId: subjects[index]['id'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            itemCount: subjects.length,
          ),
        ],
      ),
    );
  }
}

class VideoList extends StatefulWidget {
  final String subjectId;

  VideoList({required this.subjectId});

  @override
  _VideoListState createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  List<Map<String, String>> videos = [];
  String searchKeyword = "";

  @override
  void initState() {
    super.initState();
    fetchVideos().then((data) {
      setState(() {
        videos = data ?? [];
      });
    });
  }

  Future<List<Map<String, String>>?> fetchVideos() async {
    final uri = Uri.parse(ApiUrls.videossUrl);
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data
              .map<Map<String, String>>((item) => {
                    'namevideo': item['namevideo'].toString(),
                    'linkvideo': item['linkvideo'].toString(),
                    'subject_id': item['subject_id'].toString()
                  })
              .where((video) => video['subject_id'] == widget.subjectId)
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

  List<Map<String, String>> getFilteredVideos() {
    if (searchKeyword.isEmpty) {
      return videos;
    } else {
      return videos.where((video) {
        final name = video['namevideo'] ?? '';
        return name.toLowerCase().contains(searchKeyword.toLowerCase());
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredVideos = getFilteredVideos();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Danh sách video',
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
                labelText: 'Tìm kiếm theo tên video',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredVideos.length,
              itemBuilder: (context, index) {
                final video = filteredVideos[index];
                return Card(
                  elevation: 2, // Add some elevation for a shadow effect
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(
                      video['namevideo'] ?? 'Tên video',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.blue,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayVideo(
                            videoLink: video['linkvideo'],
                            videoName: video['namevideo'],
                          ),
                        ),
                      ).then((value) {
                        setState(() {});
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PlayVideo extends StatefulWidget {
  final String? videoLink;
  final String? videoName;

  PlayVideo({this.videoLink, this.videoName});

  @override
  _PlayVideoState createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _showControls = true;
  bool _isFullScreen = false;
  GlobalKey _videoPlayerKey = GlobalKey();
  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget.videoLink!,
    );
    _initializeVideoPlayerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      _showAppBar =
          !_isFullScreen; // Ẩn AppBar khi chuyển sang chế độ fullscreen
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    SystemChrome.setPreferredOrientations([
      _isFullScreen
          ? DeviceOrientation.landscapeLeft
          : DeviceOrientation.portraitUp,
    ]);

    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        _controller.pause();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      builder: (BuildContext context, Widget? child) {
        return WillPopScope(
          onWillPop: () async {
            if (_isFullScreen) {
              _toggleFullScreen();
              return false;
            }
            return true;
          },
          child: Scaffold(
            appBar: _showAppBar
                ? AppBar(
                    title: Text(
                      widget.videoName ?? 'Tên video',
                      style: TextStyle(fontSize: 22),
                    ),
                  )
                : null, // Ẩn AppBar nếu _showAppBar là false
            body: GestureDetector(
              onTap: _toggleControlsVisibility,
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return OrientationBuilder(
                      builder: (context, orientation) {
                        return _buildVideoPlayer(orientation);
                      },
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoPlayer(Orientation orientation) {
    double videoWidth = _controller.value.size.width;
    double videoHeight = _controller.value.size.height;

    if (orientation == Orientation.portrait && !_isFullScreen) {
      videoWidth = MediaQuery.of(context).size.width;
      videoHeight = videoWidth * 9 / 16;
    }

    return Container(
      key: _videoPlayerKey,
      width: videoWidth,
      height: videoHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller),
          if (_showControls)
            _ControlsOverlay(
              controller: _controller,
              isFullScreen: _isFullScreen,
              onToggleFullScreen: _toggleFullScreen,
            ),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isFullScreen;
  final VoidCallback onToggleFullScreen;

  const _ControlsOverlay({
    required this.controller,
    required this.isFullScreen,
    required this.onToggleFullScreen,
  });

  @override
  _ControlsOverlayState createState() => _ControlsOverlayState();
}

class _ControlsOverlayState extends State<_ControlsOverlay> {
  bool _showControls = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (widget.controller.value.isPlaying) {
        _hideControls();
      }
    });
  }

  void _hideControls() {
    setState(() {
      _showControls = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
        if (_showControls) {
          _startTimer();
        }
      },
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _showControls ? _buildControls() : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                onPressed: () {
                  if (widget.controller.value.isPlaying) {
                    widget.controller.pause();
                  } else {
                    widget.controller.play();
                  }
                },
                icon: Icon(
                  widget.controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              ),
              _buildControlButton(
                onPressed: () {
                  final position =
                      widget.controller.value.position - Duration(seconds: 10);
                  widget.controller.seekTo(position);
                },
                icon: Icon(Icons.replay_10),
              ),
              _buildControlButton(
                onPressed: () {
                  final position =
                      widget.controller.value.position + Duration(seconds: 10);
                  widget.controller.seekTo(position);
                },
                icon: Icon(Icons.forward_10),
              ),
            ],
          ),
          VideoProgressIndicator(
            widget.controller,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: Colors.orange,
              bufferedColor: Colors.grey,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(
                onPressed: widget.onToggleFullScreen,
                icon: Icon(
                  widget.isFullScreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback onPressed,
    required Icon icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: Colors.orange,
        splashColor: Colors.blue,
        highlightColor: Colors.transparent,
      ),
    );
  }
}
