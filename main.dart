/**
 * README
 * Flutter: 2.5.3
 * Dart: 2.14.4
 * Lib: https://pub.dev/packages/video_player
 */

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(
    MaterialApp(
      home: VideoPlayerDemo(),
    ),
  );
}

class VideoPlayerDemo extends StatefulWidget {
  @override
  _VideoPlayerDemoState createState() => _VideoPlayerDemoState();
}

class _VideoPlayerDemoState extends State<VideoPlayerDemo> {
  int _index = 0;
  final bool _isLooping = true;
  final Map<String, VideoPlayerController> _controllers = {};
  final Map<int, VoidCallback> _listeners = {};
  final List<String> _urls = [
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
  ];

  @override
  void initState() {
    super.initState();

    _initVideoPlayer();
  }

  void _initVideoPlayer() {
    _index = 0;
    _controllers.clear();
    _listeners.clear();

    if (_urls.length > 0) {
      _initController(0).then((_) {
        _playController(0);
      });
    }

    if (_urls.length > 1) {
      _initController(1);
    }
  }

  Future<void> _initController(int index) async {
    final controller = VideoPlayerController.network(_urls[index]);
    _controllers[_urls[index]] = controller;
    await controller.initialize();
  }

  void _playController(int index) async {
    if (!_listeners.keys.contains(index)) {
      _listeners[index] = _listenerVideoPlayer(index);
    }
    _controller(index).addListener(_listeners[index] as Function());
    await _controller(index).play();
    setState(() {});
  }

  VideoPlayerController _controller(int index) {
    return _controllers[_urls[index]] as VideoPlayerController;
  }

  VoidCallback _listenerVideoPlayer(index) {
    return () {
      final int dur = _controller(index).value.duration.inMilliseconds;
      final int pos = _controller(index).value.position.inMilliseconds;

      if (dur - pos > 1) {
        return;
      }

      if (index < _urls.length - 1) {
        return _nextVideo();
      }

      if (_isLooping) {
        _stopController(index);
        _removeController(index);
        _initVideoPlayer();
      }
    };
  }

  void _nextVideo() async {
    if (_index == _urls.length - 1) {
      return;
    }

    _stopController(_index);

    _removeController(_index);

    _playController(++_index);

    if (_index + 1 > _urls.length - 1) {
      return;
    }

    _initController(_index + 1);
  }

  void _stopController(int index) {
    _controller(index).removeListener(_listeners[index] as Function());
    _controller(index).pause();
    _controller(index).seekTo(const Duration(milliseconds: 0));
  }

  void _removeController(int index) {
    _controller(index).dispose();
    _controllers.remove(_urls[index]);
    _listeners.remove(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Playing ${_index + 1} of ${_urls.length}"),
      ),
      body: Center(child: VideoPlayer(_controller(_index))),
    );
  }
}
