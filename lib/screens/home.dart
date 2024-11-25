//import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wordle/constants/constants.dart';
import 'package:wordle/screens/gamescreen.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:wordle/screens/login/Login.dart';
//import 'package:wordle/screens/keytest.dart';
import 'package:wordle/screens/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wordle/screens/leaderboard.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:wordle/model/providers/instances.dart';
import 'package:wordle/model/providers/dailyProvider.dart';
import 'package:wordle/model/providers/userInfoProvider.dart';
import 'package:provider/provider.dart';
import 'package:wordle/util/ShowNoti.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final user = FirebaseAuth.instance.currentUser;
int imagePickedHome = 0;
Color dailyColor = dailyGreen;

int completed = 0;

Future<void> startMadu(context, {bool isChallenge = false}) async {
  String contentsF = await rootBundle.loadString("assets/filtered-words.txt");
  List<String> fwords = contentsF.split('\n');
  var random = Random();
  String finalWord =
      fwords[random.nextInt(fwords.length)].substring(0, 5).toUpperCase();
  print(finalWord);

  await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => gameScreen(
          word: finalWord,
          isChallenge: isChallenge,
          restart: () => startMadu(context, isChallenge: isChallenge),
          popmethod: () => popMadu(context))));
}

void popMadu(context) {
  return;
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    refreshDaily();
    Provider.of<DailyProvider>(context, listen: false).getDailyChallenges();
  }

  void changeDailyColor() {
    setState(() {
      dailyColor = dailyTheme;
    });
  }

  Future<void> refreshDaily() async {
    print("Refreshing and updating");
    await Instances.userTracker.updateEveryday();
  }

  Future<void> onRefreshed() async {
    Provider.of<DailyProvider>(context, listen: false).getDailyChallenges();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = AppBar().preferredSize.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Consumer<DailyProvider>(
        builder: (context, dailyProvider, child) =>
            Consumer<UserDetailsProvider>(
              builder: (context, userProvider, child) => Scaffold(
                appBar: buildAppBar(
                    context,
                    userProvider.check == 1
                        ? userProvider.userDetails!.pfp.toString()
                        : "0"),
                body: RefreshIndicator(
                  onRefresh: onRefreshed,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: screenHeight - appBarHeight - statusBarHeight,
                      child: Stack(
                        children: [
                          buildFAB(context, "chubs"),
                          Align(
                            alignment: Alignment.center,
                            child: Container(child: buildStartButton(context)),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (dailyProvider.completed < 3) {
                                    startMadu(context, isChallenge: true);

                                    await dailyProvider.incrementDaily();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        dailyProvider.completed >= 3
                                            ? darkertheme
                                            : dailyGreen,
                                    foregroundColor: white,
                                    fixedSize: Size(
                                        screenWidth / 1.50, screenHeight / 18),
                                    textStyle: TextStyle(
                                      fontSize: screenHeight / 45,
                                      fontWeight: FontWeight.w500,
                                    )),
                                child: dailyProvider.completed != 5
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Daily Challenges ${dailyProvider.completed}/3",
                                            ),
                                          ),
                                          dailyProvider.completed >= 3
                                              ? const Icon(
                                                  Icons.check,
                                                )
                                              : const Icon(Icons.flag),
                                        ],
                                      )
                                    : const CircularProgressIndicator(
                                        color: white,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ));
  }

  Widget buildStartButton(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 170,
            width: 170,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: theme, foregroundColor: grey),
                onPressed: () {
                  startMadu(context, isChallenge: false);
                },
                child: const Center(
                  child: Text(
                    "START",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
                  ),
                )),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}

Widget buildFAB(context, username) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0, top: 20),
    child: SizedBox(
      height: 70,
      width: 70,
      child: FloatingActionButton(
        backgroundColor: darktheme,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const LeaderboardScreen()));
        },
        child: Container(
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          child: Image.asset('assets/images/trophy.png'),
        ),
      ),
    ),
  );
}

AppBar buildAppBar(context, imagePicked) {
  return AppBar(
    backgroundColor: theme,
    title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      GestureDetector(
          onTap: () async {
            showTopMessage(context, "You have pressed", Colors.blue, white);
          },
          child: const Icon(Icons.menu, color: grey, size: 30)),
      const Text(
        'WORDLE',
        style:
            TextStyle(fontWeight: FontWeight.w600, color: grey, fontSize: 24),
      ),
      Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
          child: GestureDetector(
            child: ClipOval(
              child: Image.asset('assets/profiles/$imagePicked.png'),
            ),
            onTap: () async {
              if (user == null) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              }
            },
          ))
    ]),
  );
}
