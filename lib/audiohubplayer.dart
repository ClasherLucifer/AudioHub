import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';

class AudioHubPlayer
{
  String cover;
  String audio_url;
  String title;
  String artist;
  //TODO : Add declarations as per each database fields if necessary.

  AudioHubPlayer({
    this.cover,
    this.audio_url,
    this.title,
    this.artist,
    //TODO : Add fields if necessary.
  });
  
  AudioPlayer player;


  //Implementts play action
  Future<void> play() async
  {
    await player.setUrl(audio_url);
    await player.setAudioSource(AudioSource.uri(Uri.parse(audio_url)));
    await player.load();

    player.play();
  }

  //Implements stop action
  Future<void> stop() async{
    player.stop();
  }

  //Implements pause action
  Future<void> pause() async
  {
    await player.pause();
  }
}