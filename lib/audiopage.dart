import 'dart:async';
import 'package:audiohub/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee_widget/marquee_widget.dart';

//

//

import 'globalvariables.dart' as g;

class AudioPage extends StatefulWidget {
  String uid;
  double maxProgress;
  DocumentSnapshot document;
  AudioPlayer player;

  AudioPage({
    this.uid,
    this.document,
    this.maxProgress,
    this.player,
  });

  @override
  State<StatefulWidget> createState() => AudioPageState();
}

class AudioPageState extends State<AudioPage> {
  CollectionReference userdata =
      FirebaseFirestore.instance.collection('User Data');

  String uid;

  final ValueNotifier<int> progresscounter = ValueNotifier<int>(0);
  final ValueNotifier<int> playpausecounter = ValueNotifier<int>(0);
  final ValueNotifier<int> favcounter = ValueNotifier<int>(0);
  final ValueNotifier<int> dummy = ValueNotifier<int>(0);

  double progress;
  double mediaLength;
  DocumentSnapshot document;
  var player;
  //////////////////////////////////////////////////////////////////////////////
  var slidervalue;
  //////////////////////////////////////////////////////////////////////////////
  //
  var elapsed;
  //bool g.playing;
  bool runningTimer;
  Timer t;
  //
  String timeElapsed;
  double prog = g.p;

  Slider slider;

  bool playing;

  @override
  void initState() {
    super.initState();
    uid = widget.uid;
    print(uid);
    document = widget.document;
    mediaLength = widget.maxProgress;
    player = widget.player;
    slidervalue = 0;
    runningTimer = true;
    prog = g.p;
    if (player.playing == true) {
      setProgress();
      playpausecounter.value++;
    }
    playing = player.playing;
  }

  @override
  void dispose() {
    super.dispose();
    HomePage().createState();
    t.cancel();
  }

  @override
  Widget build(BuildContext context) {
    print('apscaffold updated');
    checkIfPlaying();
    testdata(g.p, widget.maxProgress);
    return WillPopScope(
        onWillPop: () => onBackPressed(context),
        child: SafeArea(
            child: Scaffold(
          backgroundColor: Color(0xfe212121),
          body: Column(
            children: [
              Padding(padding: EdgeInsets.only(top: 30)),
              ///////////////////////////////////////////////////////////Music Cover
              Padding(
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: getImage(),
                  )),
              //////////////////////////////////////////////////Music Title & Artist
              Padding(
                padding: EdgeInsets.fromLTRB(30, 20, 30, 40),
                child: Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /////////////////////////////////////////////////////Title

                          Row(children: [
                            Expanded(
                                child: Marquee(
                              animationDuration: Duration(seconds: 2),
                              pauseDuration: Duration(milliseconds: 1000),
                              //backDuration: Duration(seconds: 3),
                              textDirection: TextDirection.ltr,
                              directionMarguee: DirectionMarguee.oneDirection,
                              child: Text(
                                document != null
                                    ? document.data()['title'] + '     '
                                    : 'null_title',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            )),
                            Padding(padding: EdgeInsets.only(left: 5)),
                            //||||||||||||||||||||||||||||||||||||||||||||||||||
                            GestureDetector(
                                child: ValueListenableBuilder(
                                    valueListenable: favcounter,
                                    builder: (BuildContext context, int value,
                                        Widget child) {
                                      return g.favourites.contains(
                                              document.data()['title'])
                                          ? Icon(Icons.favorite,
                                              color: Colors.red)
                                          : Icon(
                                              Icons.favorite_border_outlined,
                                              color: Colors.grey,
                                            );
                                    }),
                                onTap: () {
                                  getFavourites();
                                  g.favourites
                                          .contains(document.data()['title'])
                                      ? unfavourite(document.data()['title'])
                                      : favourite(document.data()['title']);

                                  favcounter.value++;
                                })
                            //||||||||||||||||||||||||||||||||||||||||||||||||||
                          ]),

                          //////////////////////////////////////////////////////////
                          Padding(
                            padding: EdgeInsets.only(top: 2),
                          ),
                          ////////////////////////////////////////////////////Artist
                          Text(
                              document != null
                                  ? document.data()['artist']
                                  : 'null_artist',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                          //////////////////////////////////////////////////////////
                        ])),
              ),
              ////////////////////////////////////////////////////////////////Slider
              Container(
                  height: 20,
                  padding: EdgeInsets.only(left: 10, right: 10, top: 0),

//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
                  child: SliderTheme(
                      data: SliderThemeData(
                          thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 5, disabledThumbRadius: 10),

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
                          max: mediaLength,
                          divisions: mediaLength.toInt(),
                          value: slidervalue != 0 ? slidervalue : g.p,
                          onChangeStart: (var v) {
                            setState(() {
                              if (player.playing) {
                                t.cancel();
                              }
                              g.p = v;
                              progresscounter.value++;
                              playpausecounter.value++;
                            });
                          },
                          onChangeEnd: (var v) {
                            if (v == mediaLength) {
                              player.stop();
                            }
                            setState(() {
                              g.p = v;
                              progresscounter.value++;
                              playpausecounter.value++;
                              if (player.playing && !t.isActive) {
                                player
                                    .seek(Duration(seconds: v.toInt()))
                                    .then((var v) {
                                  setProgress();
                                });
                                setState(() {});
                              } else {
                                setState(() {});
                              }
                            });
                          },
                          onChanged: (double value) {
                            if (value == mediaLength) {
                              player.stop();
                            }
                            t.cancel();
                            player
                                .seek(Duration(seconds: value.toInt()))
                                .then((var v) {
                              setState(() {
                                g.p = value;
                                progresscounter.value++;
                                playpausecounter.value++;
                              });
                            });
                          }))),
              //////////////////////////////////////////////////////////Elapsed Time
              Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Row(children: [
                    Expanded(
                        child: Row(children: [
                      Container(
                          padding: EdgeInsets.only(left: 30),
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

                          child: ValueListenableBuilder(
                              valueListenable: progresscounter,
                              builder: (BuildContext context, int value,
                                  Widget child) {
                                return Text(
                                  timeElapsed != null
                                      ? timeInMinutes(g.p)
                                      : timeInMinutes(g.p),
                                  style: TextStyle(color: Colors.white),
                                );
                              })
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

                          )
                    ])),
                    Expanded(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                            padding: EdgeInsets.only(right: 30),
                            child: ValueListenableBuilder(
                                valueListenable: progresscounter,
                                builder: (BuildContext context, int value,
                                    Widget child) {
                                  return Text(
                                    timeElapsed != null
                                        ? timeInMinutes(mediaLength - g.p)
                                        : timeInMinutes(mediaLength - g.p),
                                    style: TextStyle(color: Colors.white),
                                  );
                                }))
                      ],
                    ))
                  ])),
              //////////////////////////////////////////////////////////////////////
              Container(
                padding: EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                        padding: EdgeInsets.only(right: 5),
                        child: GestureDetector(
                            onTap: null,
                            child: Icon(
                              Icons.fast_rewind_sharp,
                              color: Colors.white,
                              size: 50,
                            ))),
                    Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
                        child: ValueListenableBuilder(
                            valueListenable: playpausecounter,
                            builder: (BuildContext context, int value,
                                Widget child) {
                              return GestureDetector(
                                  onTap: () {
                                    if (player.playing == true) {
                                      player.pause();
                                      t.cancel();
                                      runningTimer = !runningTimer;
                                      g.playing = false;
                                      playpausecounter.value++;
                                    }
                                    /*
                                    else if (g.p == mediaLength &&
                                    player.playing == false) {
                                    g.p = 0;
                                    progresscounter.value++;
                                    playpausecounter.value++;
                                playAudio();
                              }
                                    
                                    */
                                    else {
                                      if (runningTimer) {
                                        setProgress();
                                      }
                                      player.play();
                                      g.playing = true;
                                    }
                                    playpausecounter.value++;
                                  },
                                  child: Icon(
                                    g.playing == true
                                        ? Icons.pause_circle_filled_sharp
                                        : Icons.play_circle_fill_sharp,
                                    color: Colors.white,
                                    size: 70,
                                  ));
                            })
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

                        ),
                    Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Icon(
                          Icons.fast_forward_sharp,
                          color: Colors.white,
                          size: 50,
                        )),
                  ],
                ),
              ),
            ],
          ),
        )));
  }

  //////////////////////////////////////////////////////////////////////////////
  void checkIfPlaying() {
    try {
      playing = player.playing;
    } catch (e) {
      playing = false;
    }
  }

  //////////////////////////////////////////////////////////////////////////////
  void setProgress() {
    playpausecounter.value++;
    setState(() {});
    runningTimer = !runningTimer;
    const oneSec = const Duration(seconds: 1);

    t = Timer.periodic(oneSec, (Timer t) {
      g.p++;
      //playing = player.playing();
      //progresscounter.value++;
      timeElapsed = timeInMinutes(g.p);
      setState(() {
        //update ui
      });
      /*
      print('////////////////////////////////////////////////////////////');
      print('////////////////////////////////////////////////////////////');
      print(g.p);
      print(timeElapsed);
      print('////////////////////////////////////////////////////////////');
      print('////////////////////////////////////////////////////////////');
      */
      if (g.p >= mediaLength) {
        t.cancel();
        g.playing = false;
        player.release();
        playpausecounter.value++;
        return;
      }
    });
  }

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  String timeInMinutes(var time) {
    var min = time / 60;
    var sec = time % 60;
    return (min.toStringAsFixed(0) +
        ':' +
        (sec < 10 ? ('0' + sec.toStringAsFixed(0)) : sec.toStringAsFixed(0)));
  }

  ////////////////////////////////////////////////////////////////////////////////
  void testdata(var data1, var data2) {
    print('///////////////////123');
    print('///////////////////123');
    print(data1);
    print(data2);
    print('///////////////////123');
    print('///////////////////123');
  }

  //////////////////////////////////////////////////////////////////////////////
  Image getImage() {
    try {
      return Image.network(
        document.data()['cover'],
        fit: BoxFit.fill,
      );
    } catch (e) {
      return Image.asset(
        'image/img1.jpg',
        fit: BoxFit.fill,
      );
    }
  }

  //////////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////////
  Future<void> onBackPressed(BuildContext context) {
    Navigator.of(context).pop();
    return null;
  }

  //////////////////////////////////////////////////////////////////////////////
  Future<void> favourite(String title) async {
    g.favourites.add(title);
    await userdata.doc(uid).update({
      'favourites': FieldValue.arrayUnion([title])
    }).then((value) => null);
    getFavourites();
    print(g.favourites);
  }

////////////////////////////////////////////////////////////////////////////////
  Future<void> unfavourite(String title) async {
    g.favourites.remove(title);
    await userdata.doc(uid).update({
      'favourites': FieldValue.arrayRemove([title])
    }).then((value) => null);
    getFavourites();
    print(g.favourites);
  }

  //////////////////////////////////////////////////////////////////////////////
  Future<void> getFavourites() async {
    DocumentSnapshot document;
    document = await userdata.doc(uid).get();
    g.favourites = List.from(document['favourites']);
    print(g.favourites);
  }
  //////////////////////////////////////////////////////////////////End of class
}
