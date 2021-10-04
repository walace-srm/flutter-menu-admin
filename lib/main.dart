import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:menu_admin/pages/sign_in/sign_in_page.dart';
import 'package:menu_core/core/theme.dart';
import 'package:oktoast/oktoast.dart';

// void main() async {
//  await Firebase.initializeApp();
//  WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR', null);
  await Firebase.initializeApp();
  runApp(MyApp());
}
  class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        // theme: ThemeData(
        //   primarySwatch: Colors.blue,
        //   visualDensity: VisualDensity.adaptivePlatformDensity,
        // ),
        theme: lightTheme,
        home: SignInPage(),
      ),
    );
  }
}
