import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:audiohub/audiopage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:just_audio/just_audio.dart';

import 'package:marquee_widget/marquee_widget.dart';

import 'globalvariables.dart' as g;

class HomePage extends StatefulWidget {
  String uid;
  HomePage({this.uid});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  CollectionReference music = FirebaseFirestore.instance.collection('Music');
  CollectionReference userdata =
      FirebaseFirestore.instance.collection('User Data');

  final ValueNotifier<int> progresscounter = ValueNotifier<int>(0);
  final ValueNotifier<int> playpausecounter = ValueNotifier<int>(0);
  final ValueNotifier<int> favIcon = ValueNotifier<int>(0);

  //Icon fav;

  String uid;
  String audioUrl;

  bool visibility;
  DocumentSnapshot currentFile;

  //bool isListFavourite;
  //bool isNowFavourite;

  //
  var player = AudioPlayer();

  double mediaLength;
  double progress;

  Timer t;

  @override
  void initState() {
    super.initState();
    //isNowFavourite = false;

    //isListFavourite = false;
    uid = widget.uid;
    visibility = false;
    player.stop();
    progress = 0.0;
    g.p = 0;
    g.playing = player.playing;
    if (g.playing) {
      visibility = true;
      setState(() {});
    }
    checkIfPlaying();
  }

////////////////////////////////////////////////////////////////////////////////
  void checkIfPlaying() {
    if (player.playing) {
      setProgress();
    }
    //g.p > 0 ? progress = 1.0 * g.p / mediaLength : progress = 0;
    progresscounter.value++;
    playpausecounter.value++;
  }
////////////////////////////////////////////////////////////////////////////////

/*
  @override
  void dispose() {
    super.dispose();
    t.cancel();
  }
*/

  @override
  Widget build(BuildContext context) {
    getFavourites();
    print('scaffold updated');
    return SafeArea(
        child: Scaffold(
            backgroundColor: Color(0xfe212121),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                        stream: music.snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          ///////////////////////////////////////
                          try {
                            return new ListView(
                              children: snapshot.data.docs
                                  .map((DocumentSnapshot document) {
                                return createListTile(document);
                              }).toList(),
                            );
                          } catch (Exception) {
                            return Container();
                          }
                        })

                    //////////////////////////////////////////////
                    ),
                /////////////////////////////////////////////////////Now Playing
                nowPlaying(),
                ///////////////////////////////////////////////////Bottom NavBar
                Theme(
                    data: ThemeData(canvasColor: Color(0xfe212121)),
                    child: Container(
                        height: 55,
                        child: BottomNavigationBar(
                          type: BottomNavigationBarType.fixed,
                          items: [
                            BottomNavigationBarItem(
                                title: Text('Home',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13)),
                                icon: Icon(Icons.home,
                                    color: Color(0xfe9e9e9e), size: 25)),
                            BottomNavigationBarItem(
                                title: Text('Search',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13)),
                                icon: Icon(Icons.search,
                                    color: Color(0xfe9e9e9e), size: 25)),
                            BottomNavigationBarItem(
                                title: Text('Playlists',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13)),
                                icon: Icon(Icons.menu,
                                    color: Color(0xfe9e9e9e), size: 25)),
                            BottomNavigationBarItem(
                                title: Text('Local',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13)),
                                icon: Icon(Icons.cloud_download,
                                    color: Color(0xfe9e9e9e), size: 25)),
                          ],
                        ))),
                ///////////////////////////////////////////////////Bottom NavBar
              ],
            )));
  }

  ///////////////////////////////////////////////////////////////////Main Widget

//https://drive.google.com/file/d/1tKPXZGyUOpHyP7Xo-hwU4RuXFD13SLBg/view?usp=drivesdk
//https://drive.google.com/uc?export=view&id=
//https://drive.google.com/uc?export=view&id=1tKPXZGyUOpHyP7Xo-hwU4RuXFD13SLBg

  //////////////////////////////////////////////////////////////////////////////
  Widget createListTile(DocumentSnapshot document) {
    final ValueNotifier<int> listFav = ValueNotifier<int>(0);
    String listTitle = document.data()['title'];
    return

        /*
    GestureDetector(
        onTap: () {
          currentFile = document;
          getAudioUrl(document.data()['audio_url']);
          if (player.playing == true) {
            player.stop();
            t.cancel();
          }
          g.playing = true;
          setState(() {
            g.p = 0;
            progress = 0;
            visibility = true;
          });
          playAudio();
        },
        child: 
        */
        Padding(
            padding: EdgeInsets.only(left: 25, right: 5, top: 10, bottom: 10),
            child: Container(
                height: 45,
                width: MediaQuery.of(context).size.width,
                color: Color(0xfe212121),
                child: Row(
                  children: [
                    ////////////////////////////////////////////////////////////
                    Expanded(
                        child: GestureDetector(
                            onTap: () {
                              currentFile = document;
                              getAudioUrl(document.data()['audio_url']);
                              if (player.playing == true) {
                                player.stop();
                                t.cancel();
                              }
                              g.playing = true;
                              setState(() {
                                g.p = 0;
                                progress = 0;

                                visibility = true;
                              });
                              playAudio();
                            },
                            child: Row(children: [
                              ////////////////////////////////////////Song Pic
                              Container(
                                  width: 45,
                                  child: ClipRRect(
                                      child: Image.network(
                                          document.data()['cover']))),
                              //////////////////////////////////Title & Artist
                              Expanded(
                                child: Container(
                                    padding: EdgeInsets.only(left: 10, top: 3),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ///////////////////////////////Title
                                          Text(
                                            document.data()['title'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          //////////////////////////////Artist
                                          Expanded(
                                              child: Padding(
                                                  padding: EdgeInsets.all(0),
                                                  child: Text(
                                                    document.data()['artist'],
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )))
                                        ])),
                              )
                            ]))),
                    //////////////////////////////////Title & Artist

                    Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        //////////////////////////////////////////////////////////
                        child: GestureDetector(
                          child: g.favourites.contains(document.data()['title'])
                              ? Icon(Icons.favorite, color: Colors.red)
                              : Icon(
                                  Icons.favorite_border_outlined,
                                  color: Colors.grey,
                                ),
                          onTap: () {
                            if (g.favourites
                                .contains(document.data()['title'])) {
                              unfavourite(document.data()['title']);

                              setState(() {
                                //updateUi
                              });
                            } else {
                              favourite(document.data()['title']);
                              setState(() {
                                //updateUi
                              });
                            }
                          },
                        )

                        /*
                                isListFavourite
                                    ? Icon(Icons.favorite, color: Colors.red)
                                    : Icon(
                                        Icons.favorite_border_outlined,
                                        color: Colors.grey,
                                      );*/

                        ),
                    Padding(
                        padding: EdgeInsets.only(left: 5, right: 15),
                        child: GestureDetector(
                          onTap: null,
                          child: Icon(Icons.more_vert, color: Colors.grey),
                        ))
                  ],
                )));
  }

  //////////////////////////////////////////////////////////////////////////////
  Widget nowPlaying() {
    return Visibility(
        visible: visibility,
        child: GestureDetector(
            onTap: () {
              print('||||||||||||||||||||||||||||||||||');
              print('||||||||||||||||||||||||||||||||||');
              print(currentFile.data()['title'].toString());
              print('||||||||||||||||||||||||||||||||||');
              print('||||||||||||||||||||||||||||||||||');
              t.cancel();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AudioPage(
                            uid: uid,
                            maxProgress: mediaLength,
                            document: currentFile,
                            player: player,
                          ))).then((value) => checkIfPlaying());
            },
            child: Container(
              color: Color(0xfe212121),
              height: 65,
              width: MediaQuery.of(context).size.width,
              child: Column(children: [
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
                ValueListenableBuilder(
                    builder: (BuildContext context, int value, Widget child) {
                      return LinearProgressIndicator(
                        backgroundColor: Color(0xfe212121),
                        minHeight: 2,
                        value: progress,
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(Colors.white),
                      );
                    },
                    valueListenable: progresscounter),
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

                Row(
                  children: [
                    Container(
                      width: 60,
                      margin: EdgeInsets.only(left: 5),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: currentFile == null
                              ? null
                              : Image.network(currentFile.data()['cover'])),
                    ),
                    ///////////////////////////////////////Song title & artist
                    Expanded(
                        child: Column(children: [
                      Container(
                          padding: EdgeInsets.only(left: 15, top: 10),
                          alignment: Alignment.centerLeft,
                          child: currentFile == null
                              ? null
                              : Marquee(
                                  animationDuration: Duration(seconds: 3),
                                  pauseDuration: Duration(milliseconds: 1500),
                                  backDuration: Duration(seconds: 3),
                                  textDirection: TextDirection.rtl,
                                  directionMarguee:
                                      DirectionMarguee.TwoDirection,
                                  child: Text(
                                    currentFile.data()['title'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                )),
                      /////////////////////////////////////////////////Title
                      Container(
                          padding: EdgeInsets.only(left: 15, top: 3),
                          alignment: Alignment.centerLeft,
                          child: currentFile == null
                              ? null
                              : Marquee(
                                  animationDuration: Duration(seconds: 3),
                                  pauseDuration: Duration(milliseconds: 1500),
                                  backDuration: Duration(seconds: 3),
                                  textDirection: TextDirection.rtl,
                                  directionMarguee:
                                      DirectionMarguee.TwoDirection,
                                  child: Text(
                                    currentFile.data()['artist'],
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                )
                          //currentFile.data()['artist']
                          ),
                      ////////////////////////////////////////////////Artist
                    ])),
                    ///////////////////////////////////////Song title & artist
                    ///
                    /////////////////////////////////////////////////Favourite
                    Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          child: existsInFavourites(g.favourites, currentFile)
                              ? Icon(Icons.favorite,
                                  size: 28, color: Colors.red)
                              : Icon(
                                  Icons.favorite_border_outlined,
                                  size: 28,
                                  color: Colors.grey,
                                ),
                          onTap: () {
                            g.favourites.contains(currentFile.data()['title'])
                                ? unfavourite(currentFile.data()['title'])
                                : favourite(currentFile.data()['title']);

                            setState(() {
                              //Refresh Ui
                            });
                          },
                        )),
                    /////////////////////////////////////////////////Favourite
                    ///
                    //////////////////////////////////////////////Play / Pause
                    Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: GestureDetector(
                            child:
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
                                ValueListenableBuilder(
                                    valueListenable: playpausecounter,
                                    builder: (BuildContext context, int v,
                                        Widget child) {
                                      return Icon(
                                          player.playing == true
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          size: 40,
                                          color: Colors.white);
                                    }),
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

                            onTap: () {
                              if (g.playing == true) {
                                player.pause();
                                g.playing = false;
                                playpausecounter.value++;
                                t.cancel();
                              } else if (progress == 1 &&
                                  player.playing == false) {
                                progress = 0;
                                progresscounter.value++;
                                playAudio();
                              } else {
                                player.play();
                                g.playing = true;
                                setProgress();
                                playpausecounter.value++;
                              }
                              playpausecounter.value++;
                            })),
                    //////////////////////////////////////////////Play / Pause
                  ],
                )
              ]),
            )));
  }

////////////////////////////////////////////////////////////////////////////////

  Future<bool> nowFavourite() async {
    List favourite;
    DocumentSnapshot document;
    document = await userdata.doc(uid).get();
    favourite = document.data()['favourite songs'];
    print(favourite);
    return null;
  }

////////////////////////////////////////////////////////////////////////////////
  void getAudioUrl(String sentUrl) {
    audioUrl = sentUrl;
  }

////////////////////////////////////////////////////////////////////////////////
  Future<void> playAudio() async {
    await player.setUrl(audioUrl);
    await player.setAudioSource(AudioSource.uri(Uri.parse(audioUrl)));
    await player.load();
    mediaLength = player.duration.inSeconds.toDouble();
    print('////////////////');
    print('////////////////');
    print(mediaLength);
    print('////////////////');
    print('////////////////');
    player.play();
    setProgress();
  }

////////////////////////////////////////////////////////////////////////////////
  Future<void> favourite(String title) async {
    g.favourites.add(title);
    await userdata.doc(uid).update({
      'favourites': FieldValue.arrayUnion([title])
    }).then((value) => null);
    print(g.favourites);

    setState(() {
      //Update Ui
    });
  }

////////////////////////////////////////////////////////////////////////////////
  Future<void> unfavourite(String title) async {
    g.favourites.remove(title);
    await userdata.doc(uid).update({
      'favourites': FieldValue.arrayRemove([title])
    }).then((value) => null);
    print(g.favourites);

    setState(() {
      //Update UI
    });
  }

////////////////////////////////////////////////////////////////////////////////
  void setProgress() {
    playpausecounter.value++;
    const oneSec = const Duration(seconds: 1);
    t = Timer.periodic(oneSec, (t) {
      g.p++;
      progress = (1.0 * g.p / mediaLength);
      progresscounter.value++;
      print(progress);
      print(g.p);
      if (progress == 1) {
        t.cancel();
        player.stop();
        g.playing = false;
        playpausecounter.value++;
        g.p = 0;
        return;
      }
    });
  }

////////////////////////////////////////////////////////////////////////////////
  Future<void> getFavourites() async {
    DocumentSnapshot document;
    document = await userdata.doc(uid).get();
    g.favourites = List.from(document['favourites']);
    print(g.favourites);
  }

////////////////////////////////////////////////////////////////////////////////
  Icon fav(double size) {
    return Icon(Icons.favorite, size: size, color: Colors.red);
  }

////////////////////////////////////////////////////////////////////////////////
  Icon unFav(double size) {
    return Icon(
      Icons.favorite_border_outlined,
      size: size,
      color: Colors.grey,
    );
  }

////////////////////////////////////////////////////////////////////////////////
  bool existsInFavourites(List favourites, DocumentSnapshot document) {
    try {
      if (document.data()['title'] != null) {
        if (favourites.contains(document.data()['title']) == true) {
          return true;
        }
      } else {
        return false;
      }
    } catch (Exception) {
      print('kya pata bc');
      return false;
    }

    return false;
  }
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////

}
