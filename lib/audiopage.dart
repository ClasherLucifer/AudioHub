import 'package:audiohub/audiohubplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:audiohub/global.dart';
import 'package:marquee/marquee.dart';

import 'package:audiohub/changeListener.dart' as Listener;

class AudioPage extends StatelessWidget {

  bool isPlaying;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Color(0xfe212121),
          body: Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Cover image
                Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Container(
                        height: MediaQuery.of(context).size.width - 60,
                        width: MediaQuery.of(context).size.width - 60,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(
                                    Global.currentFile.data()['cover']),
                                fit: BoxFit.fill)))),
                //Padding
                Padding(padding: EdgeInsets.only(top: 30)),
                //Title & Favourite button
                Padding(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: Row(
                      children: [
                        //Title
                        ValueListenableBuilder(
                            valueListenable: Listener.statue,
                            builder: (BuildContext context, int value,
                                Widget child) {
                              String text = Global.currentFile.data()['title'];
                              return text.length >
                                      (MediaQuery.of(context).size.width / 20)
                                  ? Container(
                                      height: 30,
                                      width: MediaQuery.of(context).size.width -
                                          115,
                                      child: Marquee(
                                          velocity: 20,
                                          blankSpace: 100,
                                          fadingEdgeStartFraction: 0.15,
                                          fadingEdgeEndFraction: 0.15,
                                          text: text,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: Colors.white)))
                                  : Expanded(
                                      child: Text(
                                      text,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.white),
                                    ));
                            }),
                        //Padding
                        Padding(padding: EdgeInsets.only(left: 15)),
                        //Favourite button
                        ValueListenableBuilder(
                            valueListenable: Listener.favNotifier,
                            builder: (BuildContext context, int value,
                                Widget child) {
                              return GestureDetector(
                                  onTap: () {
                                    Global.favourites
                                            .contains(Global.currentFile.id)
                                        ? Global.unfavourite(
                                            Global.currentFile.id)
                                        : Global.favourite(
                                            Global.currentFile.id);

                                    Global.fetchFavourites().then(
                                        (_) => Listener.favNotifier.value++);
                                  },
                                  child: Global.favourites
                                          .contains(Global.currentFile.id)
                                      ? Icon(Icons.favorite,
                                          size: 30, color: Colors.red)
                                      : Icon(Icons.favorite_border,
                                          size: 30, color: Colors.grey));
                            }),
                      ],
                    )),
                //Artist
                Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 30, top: 10),
                    child: Text(
                      Global.currentFile.data()['artist'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    )),
                //Progress slider
                Padding(
                    padding: EdgeInsets.only(top: 30, left: 5, right: 5),
                    child: ValueListenableBuilder(
                        valueListenable: Listener.progressNotifier,
                        builder:
                            (BuildContext context, int value, Widget child) {
                              isPlaying=AudioHubPlayer.isPlaying();
                          return Container(
                              height: 20,
                              child: SliderTheme(
                                  data: SliderThemeData(
                                      thumbShape: RoundSliderThumbShape(
                                          enabledThumbRadius: 5,
                                          disabledThumbRadius: 10),
                                      //////////////////////////////////////////////When Enabled
                                      trackHeight: 1,
                                      thumbColor: Colors.white,
                                      activeTrackColor: Colors.white,
                                      inactiveTrackColor: Colors.white,
                                      /////////////////////////////////////////////When Disabled
                                      disabledActiveTrackColor: Colors.white,
                                      disabledInactiveTrackColor: Colors.white,
                                      disabledThumbColor: Colors.white),
                                  child: Slider(
                                      min: 0,
                                      max: AudioHubPlayer.mediaLength,
                                      divisions:
                                          AudioHubPlayer.mediaLength.toInt(),
                                      value: AudioHubPlayer.intProgress,
                                      onChangeStart: (var v) {
                                        AudioHubPlayer.intProgress = v;
                                        Listener.progressNotifier.value++;
                                      },
                                      onChangeEnd: (var v) {
                                        AudioHubPlayer.intProgress = v;
                                        Listener.progressNotifier.value++;
                                      },
                                      onChanged: (var v) {
                                        AudioHubPlayer.intProgress = v;
                                        Listener.progressNotifier.value++;
                                        AudioHubPlayer.seek(v);                                       
                                      })));
                        })),
                //Time elapsed
                Padding(
                    padding: EdgeInsets.only(left: 30, right: 30),
                    child: ValueListenableBuilder(
                        valueListenable: Listener.progressNotifier,
                        builder:
                            (BuildContext context, int value, Widget child) {
                          return Row(children: [
                            Expanded(
                                child: Text(
                                    timeInMinutes(AudioHubPlayer.intProgress),
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.start)),
                            Expanded(
                                child: Text(
                                    timeInMinutes(AudioHubPlayer.mediaLength -
                                        AudioHubPlayer.intProgress),
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.end)),
                          ]);
                        })),
                //Playback control buttons
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  //Skip to previous
                  Container(
                      child: GestureDetector(
                    onTap: null, //TODO : Implement skip-to-previous action
                    child: Icon(Icons.skip_previous,
                        size: 50, color: Colors.white),
                  )),
                  //Pading
                  Padding(padding: EdgeInsets.only(left: 10)),
                  //Play-pause
                  ValueListenableBuilder(
                      valueListenable: Listener.playBackNotifier,
                      builder: (BuildContext context, int value, Widget child) {
                        return GestureDetector(
                            onTap: ()
                            {
                              if(AudioHubPlayer.decProgress==1)
                              {
                                AudioHubPlayer.playFromStart();
                              }
                              else
                              {
                                AudioHubPlayer.isPlaying()?
                                AudioHubPlayer.pause():
                                AudioHubPlayer.resume();
                              }
                            }, //TODO : Implement play-pause action
                            child: Icon(
                                AudioHubPlayer.isPlaying()
                                    ? Icons.pause
                                    : Icons.play_circle_fill,
                                size: 55,
                                color: Colors.white));
                      }),
                  //Padding
                  Padding(padding: EdgeInsets.only(left: 10)),
                  //Skip to next
                  Container(
                      child: GestureDetector(
                          onTap: null, //TODO : Implement skip-to-next action
                          child: Icon(Icons.skip_next,
                              size: 40, color: Colors.white)))
                ])
              ])),
    );
  }
  //Build method ends here

  //Displays time in mm:ss
  String timeInMinutes(var time) {
    var min = time / 60;
    var sec = time % 60;
    return (min.toStringAsFixed(0) +
        ':' +
        (sec < 10 ? ('0' + sec.toStringAsFixed(0)) : sec.toStringAsFixed(0)));
  }
}
