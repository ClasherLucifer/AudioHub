import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'globalvariables.dart' as g;

MediaControl playCtrl = MediaControl(
    androidIcon: 'drawable/play_arrow',
    label: 'Play',
    action: MediaAction.play);

MediaControl pauseCtrl = MediaControl(
    androidIcon: 'drawable/pause', label: 'Pause', action: MediaAction.pause);

MediaControl skipToNextCtrl = MediaControl(
    androidIcon: 'drawable/skip_to_next',
    label: 'Next',
    action: MediaAction.skipToNext);

MediaControl skipToPrevCtrl = MediaControl(
    androidIcon: 'drawable/skip_to_prev',
    label: 'Previous',
    action: MediaAction.skipToPrevious);

MediaControl stopCtrl = MediaControl(
    androidIcon: 'drawable/stop', label: 'Stop', action: MediaAction.stop);

class BackgroundAudio extends BackgroundAudioTask {
  final queue = <MediaItem>[
    MediaItem(
        id: g.currentFile.data()['audio_url'],
        album: g.currentFile.data()['artist'],
        artist: null,
        artUri: g.currentFile.data()['cover'],
        title: g.currentFile.data()['title']),
  ];
  int qindex = -1;
  AudioPlayer player = g.player;
  AudioProcessingState audioProcessingState;
  bool isPlaying;

  bool get hasNext => qindex + 1 < queue.length;
  bool get hasPrev => qindex > 0;

  MediaItem get mediaItem => queue[qindex];

  @override
  Future<void> onStart(Map<String, dynamic> params) {
    super.onStart(params);
  }

  @override
  Future<void> onPlay() {
    if (null == audioProcessingState) {
      //
      isPlaying = true;
      player.play();
    }
  }

  @override
  Future<void> onPause() {
    isPlaying = false;
    player.pause();
  }

  @override
  Future<void> onSkipToPrevious() {
    skip(-1);
  }

  void skip(int offset) async {
    int newpos = qindex + offset;
    if (!(newpos >= 0 && newpos < queue.length)) {
      return;
    }
    if (null == isPlaying) {
      isPlaying = true;
    } else if (isPlaying) {
      await player.stop();
    }
    qindex = newpos;
    audioProcessingState = offset > 0
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;

    AudioServiceBackground.setMediaItem(mediaItem);
    await player.setUrl(mediaItem.id);
    audioProcessingState = null;
    if (isPlaying) {
      onPlay();
    } else {
      setState(
        processingState: AudioProcessingState.ready,
      );
    }
  }

  @override
  Future<void> onSkipToNext() {
    return super.onSkipToNext();
  }

  @override
  Future<void> onStop() async {
    isPlaying = false;
    await player.stop();
    await player.dispose();

    return await super.onStop();
  }

  @override
  Future<void> onClick(MediaButton button) {
    return super.onClick(button);
  }

  //Implement onSeekTo, onFastForward, onRewind

  handlePlaybackComplete() {
    //
  }

  Future<void> setState({
    AudioProcessingState processingState,
    Duration position,
    Duration bufferedPosition,
  }) async {
    //
    if (null == position) {
      position = player.playbackEvent.updatePosition;
    }
    await AudioServiceBackground.setState(
      controls: getControls(),
      systemActions: [MediaAction.seekTo],
      processingState:
          processingState ?? AudioServiceBackground.state.processingState,
      playing: isPlaying,
      position: position,
      speed: player.speed,
    );
  }

  List<MediaControl> getControls() {
    if (isPlaying) {
      return [skipToPrevCtrl, pauseCtrl, stopCtrl, skipToNextCtrl];
    } else {
      return [skipToPrevCtrl, playCtrl, stopCtrl, skipToNextCtrl];
    }
  }
}
