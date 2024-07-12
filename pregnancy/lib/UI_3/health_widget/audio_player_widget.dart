import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;

  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setUrl(widget.audioUrl);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<Duration?>(
          stream: _audioPlayer.positionStream,
          builder: (context, snapshot) {
            final duration = snapshot.data ?? Duration.zero;
            return Slider(
              value: duration.inSeconds.toDouble(),
              onChanged: (value) {
                _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
              min: 0.0,
              max: _audioPlayer.duration?.inSeconds.toDouble() ?? 1.0,
            );
          },
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () {
                _audioPlayer.play();
              },
            ),
            IconButton(
              icon: Icon(Icons.pause),
              onPressed: () {
                _audioPlayer.pause();
              },
            ),
            IconButton(
              icon: Icon(Icons.stop),
              onPressed: () {
                _audioPlayer.stop();
              },
            ),
          ],
        ),
      ],
    );
  }
}
