import 'package:cloud_firestore/cloud_firestore.dart';

class Global
{
  static final CollectionReference music = FirebaseFirestore.instance.collection("Music");
  //Collection Reference to the Database "Music"

  static final CollectionReference userData =
      FirebaseFirestore.instance.collection("User Data");
  //CollectionReference to the Database "User Data"

  static String uid;
  static List favourites = [];
  static DocumentSnapshot currentFile;

//Fetch the user's favourite list
  static Future<void> fetchFavourites() async {
    await userData
        .doc(uid)
        .get()
        .then((document) => {favourites = List.from(document['favourites'])});
    print('Fetched favourites');
  }

//Add to favourites
  static Future<void> favourite(String musicId) async {
    await userData.doc(uid).update({
      'favourites': FieldValue.arrayUnion([musicId])
    });
    print('Added to favourites');
  }

//Remove from favourites
  static Future<void> unfavourite(String musicId) async {
    await userData.doc(uid).update({
      'favourites': FieldValue.arrayRemove([musicId])
    });
    print('Removed from favourites');
  }
}
