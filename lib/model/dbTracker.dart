import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DailyTracker {
  final tracker = FirebaseDatabase.instance.ref("dailyTracker");
  final user = FirebaseAuth.instance.currentUser;

  Future<void> updateTracker(int gameNo) async {
    final query = tracker.orderByChild("email").equalTo(user!.email);
    final snapshot = await query.get();
    print("Snapshot exists");
    if (snapshot.exists) {
      Map<String, dynamic> data =
          Map<String, dynamic>.from(snapshot.value as Map);

      final key = data.keys.first;
      await tracker.child(key).update({
        "lastDateTime": DateTime.now().toUtc().toString().substring(0, 16),
        'gamesPlayed': gameNo
      });
      print("Tracker has been incremented by 1");
    } else {
      print("Could not update tracker");
    }
  }

  Future<String> getLastDateTime(User user) async {
    var snapshot =
        await tracker.orderByChild("email").equalTo(user.email).get();

    if (snapshot.exists) {
      Map fullMap = snapshot.value as Map;
      Map<String, dynamic> userData =
          Map<String, dynamic>.from(fullMap.values.first);
      print(userData);

      return userData['lastDateTime'];
    } else {
      print("User not found");
      return "0";
    }
  }

  Future<bool> userTrackerExists() async {
    final user = FirebaseAuth.instance.currentUser;
    var snapshot =
        await tracker.orderByChild("email").equalTo(user!.email).get();
    print(tracker.orderByChild("email").equalTo(user.email).get());
    if (snapshot.exists) {
      print("User tracekr exists");
      return true;
    } else {
      print("User tracekr does not exists");
      return false;
    }
  }

  Future<void> updateEveryday() async {
    var snapshot =
        await tracker.orderByChild("email").equalTo(user!.email).get();
    String currentDateTime = DateTime.now().toUtc().toString().substring(0, 16);
    late String temp;
    if (snapshot.exists) {
      Map fullMap = snapshot.value as Map;
      Map<String, dynamic> userData =
          Map<String, dynamic>.from(fullMap.values.first);
      temp = userData['lastDateTime'];
      if (temp == "") {
        return;
      }
    } else {
      return;
    }

    Map<String, dynamic> dateTimeToCompare = await dateParser(temp);
    Map<String, dynamic> current = await dateParser(currentDateTime);
    await updateOrNot(current, dateTimeToCompare);
    return;
  }

  Future<Map<String, dynamic>> dateParser(String temp) async {
    return {
      'y': int.parse(temp.substring(0, 4)),
      'mo': int.parse(temp.substring(5, 7)),
      'd': int.parse(temp.substring(8, 10)),
      'h': int.parse(temp.substring(11, 13)),
      'mi': int.parse(temp.substring(14, 16))
    };
  }

  Future<void> updateOrNot(Map current, Map compare) async {
    bool y = current['y'] == compare['y'];
    bool mo = current['mo'] == compare['mo'];
    bool d = current['d'] == compare['d'];

    if (!y || !mo || !d) {
      //different day
      await resetTracker(); // 5:30 is over
      print("tracker has been resetted");
    } else if (y && mo && d) {
      //same day
      print("Tracker has not been reset");
      return;
    }

    return;
  }

  Future<void> resetTracker() async {
    final query = tracker.orderByChild("email").equalTo(user!.email);
    final snapshot = await query.get();

    if (snapshot.exists) {
      Map<String, dynamic> data =
          Map<String, dynamic>.from(snapshot.value as Map);

      final key = data.keys.first;
      await tracker.child(key).update({'gamesPlayed': 0});
    } else {
      print("User not found");
    }
  }

  Future<int> getGamesCompleted() async {
    var snapshot =
        await tracker.orderByChild("email").equalTo(user!.email).get();

    if (snapshot.exists) {
      Map fullMap = snapshot.value as Map;
      Map<String, dynamic> userData =
          Map<String, dynamic>.from(fullMap.values.first);
      print("Getting daily challenges");
      print(userData);

      return userData['gamesPlayed'];
    } else {
      print("User not found");
      return 0;
    }
  }
}
