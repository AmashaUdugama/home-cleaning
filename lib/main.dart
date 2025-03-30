import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:flutter/material.dart';
import 'package:mobileapp/cleaner/cleaner_home.dart';
import 'package:mobileapp/pages/Registration.dart';
import 'package:mobileapp/pages/firstPage.dart';
import 'package:mobileapp/pages/home_customer.dart';
import 'package:mobileapp/pages/login.dart';
import 'package:mobileapp/screens/add_review.dart';
// import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
// void main() {
//   runApp(const MyApp());
// }
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'mobile app',
        debugShowCheckedModeBanner: false,
        routes: {

          '/register': (context) => RegisterPage(),
          '/login': (context) => LoginPage(),
          '/home_coustomer': (context) => HomePage(),
          '/home_cleaner': (context) => HomePage1(),
          '/start':(context)=>firstPage(),
        },
        theme: ThemeData(

          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: firstPage()
    );
  }
}

