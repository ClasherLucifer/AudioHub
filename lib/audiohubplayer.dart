import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';

import 'package:audiohub/changeListener.dart' as Listener;

class AudioHubPlayer
{
  static double decProgress=0;
  static double intProgress=0;

  static double mediaLength=0;

  static final player=AudioPlayer();

  static Timer t;

  static void initialiseValues()
  {
    decProgress=0;
    intProgress=0;
  }
  
  //Implementts play action
  static Future<void> play(DocumentSnapshot document) async
  {
    print(document.id);
    String audioUrl=document.data()['audio_url'];
    await player.setUrl(audioUrl);
    await player.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
    getMediaLength();
    player.play();
    beginTimer();
    Listener.playBackNotifier.value++;    
  }

  //Implements pause action
  static Future<void> pause() async
  {
    player.pause();
    endTimer();
    Listener.playBackNotifier.value++;
  }

  //Implements resume action
  static Future<void> resume() async
  {
    player.play();
    beginTimer();    
    Listener.playBackNotifier.value++;    
  }

  //Implements stop action
  static Future<void> stop() async
  {
    player.stop();
    endTimer();
    Listener.playBackNotifier.value++;
  }

  //Implements seek action
  static Future<void> seek(double position) async
  {
    await player.seek(Duration(seconds: position.toInt()));
  }

  //Implements play from start
  static Future<void> playFromStart() async
  {
    initialiseValues();

    if(t!=null)
    {
      t.cancel();
    }
    await player.seek(Duration(seconds:0)).then((_) => resume());
    Listener.playBackNotifier.value++;
    Listener.progressNotifier.value++;
  }

  //Gets the duration of the audio file
  static void getMediaLength()
  {
    mediaLength=player.duration.inSeconds.toDouble();
    print('Media Length : $mediaLength');
  }

  //Gets the playing status of player.
  static bool isPlaying()
  {
    return player.playing;
  }

  //Timer  
  static void beginTimer()
  {
  t=Timer.periodic(Duration(seconds: 1), (t)
  {
    intProgress=player.position.inSeconds.toDouble();
    decProgress=intProgress/mediaLength;

    print('////////////////////////// Timer ');
    print('decP : $decProgress');
    print('intP : $intProgress');
    print('////////////////////////// Timer ');

    Listener.progressNotifier.value++;

    if(intProgress==mediaLength)
    {
      endTimer();  
      stop();
      Listener.playBackNotifier.value++;     
      Listener.progressNotifier.value++;
    }
  });
  }
  //Stop timer
  static void endTimer()
  {
      t.cancel();
  }
  
}