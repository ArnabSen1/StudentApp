import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:studentattendence/AuthService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDDJY2CFHUcycAig8Oj2IqAMSFEVLPsF9Y',
      appId: '1:411672249625:android:b4311b67c33a3a060f3188',
      messagingSenderId: '411672249625',
      projectId: 'location-data-b5fe2',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Attendance',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 9, 9, 9)),
        useMaterial3: true,
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Poppins', // Custom font for modern look
            ),
      ),
      home: const MyHomePage(title: 'Student Attendance'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _locationMessage = "";
  final auth = AuthService();

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _locationMessage =
          "Latitude: ${position.latitude.toStringAsFixed(5)},\nLongitude: ${position.longitude.toStringAsFixed(5)}";
    });
    try {
      await auth.addUser(lat: position.latitude.toString(), lon: position.longitude.toString());
    } catch (e) {
      print("Error getting location or creating user: ${e.toString()}");
    }
  }

  @override
  void initState() {
    super.initState();
    auth.loginWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 53, 36, 93),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 74, 78, 121), Color.fromARGB(255, 16, 15, 16)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _getCurrentLocation,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  elevation: 15,
                  shadowColor: const Color.fromARGB(255, 50, 8, 22).withOpacity(0.5),
                  backgroundColor: const Color.fromARGB(255, 67, 121, 203),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text(
                  'Mark Attendance',
                  style: TextStyle(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              AnimatedOpacity(
                opacity: _locationMessage.isNotEmpty ? 1.0 : 0.0,
                duration: const Duration(seconds: 1),
                child: _locationMessage.isNotEmpty
                    ? Card(
                        color: const Color.fromARGB(255, 229, 219, 219).withOpacity(0.8),
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.deepOrange,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Your Location',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(255, 228, 95, 95),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _locationMessage,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 5.0,
                                      color: Colors.black26,
                                      offset: Offset(1.5, 1.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
