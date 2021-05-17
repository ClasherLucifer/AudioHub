import 'package:audiohub/audiopage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'audiohubplayer.dart';
import 'package:marquee/marquee.dart';

import 'package:audiohub/changeListener.dart' as Listener;
import 'package:audiohub/global.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeState();
}

class HomeState extends State<HomePage> {
  ValueNotifier<int> currentMusicNotifier = ValueNotifier<int>(0);

  bool visibility = false;

  @override
  void initState() {
    super.initState();
    visibility = AudioHubPlayer.isPlaying();
    Global.fetchFavourites();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Color(0xfe212121),
            body: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: Global.music.snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        try {
                          return new ListView(
                              children: snapshot.data.docs
                                  .map((DocumentSnapshot document) {
                            return Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: createListItem(document));
                          }).toList());
                        } catch (Exception) {
                          return Container();
                        }
                      })

                  /*
        ListView.builder(
        itemCount: musicData.length,
        itemBuilder: (context, index)
        {
          return Padding(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child:createListItem(musicData[index]));
        }
      )*/

                  ),
              nowPlaying()
            ])
            //Scaffold ends here.
            )
        //SafeArea ends here.
        );
    //build method ends here//////////////////////////////////////////////////////
  }

  //This function creates the items in a single list tile
  Widget createListItem(DocumentSnapshot document) {
    String cover = document.data()['cover'];
    String title = document.data()['title'];
    String artist = document.data()['artist'];

    return GestureDetector(
        onTap: () {
          //Implement play music action.
          Global.currentFile = document;
          print(Global.currentFile);
          visibility = true;
          AudioHubPlayer.play(Global.currentFile);
          currentMusicNotifier.value++;
        },
        child: Row(children: [
          //Cover Image
          Container(width: 50, height: 50, child: Image.network(cover)),
          //Spacing
          Padding(padding: EdgeInsets.only(right: 10)),
          //Title & Artist
          Expanded(
              //width: 50,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                //Title
                Text(
                  title,
                  style: TextStyle(color: Colors.white, fontSize: 16.5),
                  overflow: TextOverflow.ellipsis,
                ),
                //Spacing
                Padding(padding: EdgeInsets.only(bottom: 5)),
                //Artist
                Text(artist, style: TextStyle(color: Colors.white))
              ])),
          //Favourite Button

          ValueListenableBuilder(
              valueListenable: Listener.favNotifier,
              builder: (BuildContext context, int value, Widget child) {
                return Global.favourites.contains(document.id)
                    ? GestureDetector(
                        onTap: () {
                          Global.favourites.contains(document.id)
                              ? Global.unfavourite(document.id)
                              : Global.favourite(document.id);

                          Global.fetchFavourites().then((_) => Listener.favNotifier.value++);
                        }, //TODO : Implement add to/remove from favourites list
                        child: Container(
                            //width: 30,
                            padding: EdgeInsets.only(left: 5),
                            child: Icon(Icons.favorite,
                                color: Colors.red, size: 25)))
                    : Container();
              }),
          //Options Button
          GestureDetector(
              onTap: null, //TODO : Implement various other actions
              child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Icons.more_vert, size: 25, color: Colors.white)))
        ]));
  }

  //Now Playing tab
  Widget nowPlaying() {
    try {
      return ValueListenableBuilder(
          valueListenable: currentMusicNotifier,
          builder: (BuildContext context, int value, Widget child) {
            return Visibility(
                visible: visibility,
                child: Container(
                    color: Color(0xfe363636),
                    height: 62,
                    child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    AudioPage())), //TODO : Implement tap action
                        child: Column(children: [
                          ValueListenableBuilder(
                            valueListenable: Listener.progressNotifier,
                            builder: (BuildContext context, int value,
                                Widget child) {
                              return LinearProgressIndicator(
                                backgroundColor: Color(0xfe212121),
                                minHeight: 2,
                                value: AudioHubPlayer.decProgress,
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              );
                            },
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                //Cover Image
                                Container(
                                    width: 60,
                                    height: 60,
                                    child: Image.network(
                                        Global.currentFile != null
                                            ? Global.currentFile.data()['cover']
                                            : "")),
                                //Spacing
                                Padding(padding: EdgeInsets.only(right: 15)),
                                //Title and Artist
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    //Title
                                    ValueListenableBuilder(
                                        valueListenable: Listener.statue,
                                        builder: (BuildContext context,
                                            int value, Widget child) {
                                          String text = Global.currentFile
                                              .data()['title'];

                                          return text.length >
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      20
                                              ? 
                                              Padding(
                                              padding: EdgeInsets.only(top:10,bottom:3),
                                              child:Container(
                                                  height: 20,
                                                  child: Marquee(
                                                      blankSpace: 50,
                                                      velocity: 20,
                                                      fadingEdgeStartFraction:
                                                          0.15,
                                                      fadingEdgeEndFraction:
                                                          0.15,
                                                      text: Global.currentFile !=
                                                              null
                                                          ? Global.currentFile
                                                              .data()['title']
                                                          : 'null',
                                                      style: TextStyle(
                                                          fontSize: 17,
                                                          color: Colors.white))))
                                              : Expanded(
                                                  child: Container(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(text,
                                                          style: TextStyle(
                                                              fontSize: 17,
                                                              color: Colors.white))));
                                        }),

                                    //Artist
                                    Expanded(
                                        child: Text(
                                            Global.currentFile != null
                                                ? Global.currentFile
                                                    .data()['artist']
                                                : '',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style:
                                                TextStyle(color: Colors.white)))
                                  ],
                                )),

                                //Favourite button
                                Padding(
                                    padding:
                                        EdgeInsets.only(left: 20, right: 10),
                                    child: ValueListenableBuilder(
                                        valueListenable: Listener.favNotifier,
                                        builder: (BuildContext context,
                                            int value, Widget child) {
                                          return Container(
                                              child: GestureDetector(
                                                  child: Global.favourites
                                                          .contains(Global
                                                              .currentFile.id)
                                                      ? Icon(
                                                          Icons.favorite,
                                                          color: Colors.red,
                                                          size: 25,
                                                        )
                                                      : Icon(
                                                          Icons.favorite_border,
                                                          color: Colors.grey,
                                                          size: 25,
                                                        ),

                                                  //Implement favourite/unfavourite action
                                                  onTap: () {
                                                    try {
                                                      Global.favourites
                                                              .contains(Global
                                                                  .currentFile
                                                                  .id)
                                                          ? Global.unfavourite(
                                                              Global.currentFile
                                                                  .id)
                                                          : Global.favourite(
                                                              Global.currentFile
                                                                  .id);
                                                      Global.fetchFavourites()
                                                          .then((_) => Listener
                                                              .favNotifier
                                                              .value++);
                                                    } catch (Exception) {
                                                      print("Unknown id");
                                                    }
                                                  }));
                                        })),

                                //Play/pause button
                                Padding(
                                    padding: EdgeInsets.only(right: 20),
                                    child: ValueListenableBuilder(
                                        valueListenable:
                                            Listener.playBackNotifier,
                                        builder: (BuildContext context,
                                            int value, Widget child) {
                                          return Container(
                                              //padding: EdgeInsets.only(right: 10),

                                              child: GestureDetector(
                                            child: AudioHubPlayer.isPlaying()
                                                ? Icon(
                                                    Icons.pause,
                                                    color: Colors.white,
                                                    size: 35,
                                                  )
                                                : Icon(Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: 35),
                                            //Implement Play/Pause action
                                            onTap: () {

                                              if(AudioHubPlayer.decProgress==1)
                                              {
                                                AudioHubPlayer.playFromStart();
                                              }
                                              else{
                                              AudioHubPlayer.isPlaying()
                                                  ? AudioHubPlayer.pause()
                                                  : AudioHubPlayer.resume();}
                                            },
                                          ));
                                        })),
                              ],
                            ),
                          )
                        ]))));
          });
    } catch (exception) {
      print('id not found');
      return Container();
    }
  }

  //Now Playing widget ends here

  //Ui update
  void updateUi() {
    setState(() {
      //updates ui
    });
  }

  //HomeState class ends here.
}
