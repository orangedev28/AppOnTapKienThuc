import 'dart:async';
import 'dart:convert';
import 'package:app_ontapkienthuc/url/api_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

class VideoList extends StatefulWidget {
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
    final uri = Uri.parse(ApiUrls.videossUrl); // Set the API URL for videos
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        if (data is List) {
          return data
              .map<Map<String, String>>((item) => {
                    'namevideo': item['namevideo'].toString(),
                    'linkvideo': item['linkvideo'].toString(),
                  })
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
                return ListTile(
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
                      setState(() {
                        // Refresh the list if needed
                      });
                    });
                  },
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

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
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
    });

    SystemChrome.setPreferredOrientations([
      _isFullScreen
          ? DeviceOrientation.landscapeLeft
          : DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(360, 690),
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.videoName ?? 'Tên video',
              style: TextStyle(fontSize: 22),
            ),
          ),
          body: GestureDetector(
            onTap: _toggleControlsVisibility,
            child: FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
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
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        );
      },
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

  void _showControlsIfNeeded() {
    if (!widget.controller.value.isPlaying) {
      setState(() {
        _showControls = true;
      });
    }
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
              IconButton(
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
                color: Colors.white,
              ),
              IconButton(
                onPressed: () {
                  final position =
                      widget.controller.value.position - Duration(seconds: 10);
                  widget.controller.seekTo(position);
                },
                icon: Icon(Icons.replay_10),
                color: Colors.white,
              ),
              IconButton(
                onPressed: () {
                  final position =
                      widget.controller.value.position + Duration(seconds: 10);
                  widget.controller.seekTo(position);
                },
                icon: Icon(Icons.forward_10),
                color: Colors.white,
              ),
            ],
          ),
          VideoProgressIndicator(
            widget.controller,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: Colors.amber,
              bufferedColor: Colors.grey,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: widget.onToggleFullScreen,
                icon: Icon(
                  widget.isFullScreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                ),
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
