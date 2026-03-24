import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:media_kit/media_kit.dart';
import 'package:pandamusic/data/colors.dart';
import 'package:pandamusic/data/routes.dart';
import 'package:pandamusic/pages/unknownpage.dart';

void main() {  
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        colorScheme: .fromSeed(
          contrastLevel: 0.3,
          brightness: Brightness.light,
          dynamicSchemeVariant: DynamicSchemeVariant.tonalSpot,
          seedColor: AppColor.blue
        ),
        sliderTheme: SliderThemeData(
          showValueIndicator: ShowValueIndicator.onDrag
        )
      ),
      initialRoute: "/home",
      builder: (context, child) => DefaultTextStyle(
        style: GoogleFonts.googleSans(
          fontSize: 16
        ), 
        child: child ?? Container()
      ),
      routes: Routes.routes.map((route, routeObj) => MapEntry(route, routeObj.widget)),
      onGenerateRoute: (settings) {
        if(settings.name == null || !Routes.routes.keys.contains("${settings.name}")){
          return MaterialPageRoute(builder: (_) => UnknownPage());
        }
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => 
          Material(
            child: Routes.routes[settings.name]!.widget(context),
          )
          //transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c)
        );
      },
    );
  }
}
