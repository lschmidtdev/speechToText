import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter/material.dart';
import 'package:voice_notes_app/pages/notes_page/notes_page.dart';
import 'package:voice_notes_app/utils/custom_colors.dart';
import 'package:voice_notes_app/utils/strings.dart';
import '../../utils/widgets/app_drawer.dart';
import '../speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key}) ;
  static const routeName = '/app-screen';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> _screens = [
    {
      'title': StringsConst.allNotesPageTitle,
      'page': NotesPage(),
    },
    {
      'title': StringsConst.favouriteNotesPageTitle,
      'page': NotesPage(isFavouriteScreen: true),
    },
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.grid_view_rounded,
            size: 40,
            color: Colors.black,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: Text(
          _screens[_currentIndex]['title'] as String,
          style: Theme.of(context).textTheme.headline6,
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      drawer: AppDrawer(),
      body: _screens[_currentIndex]['page'] as Widget,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () => setState(() {
                  _currentIndex = 0;
                }),
                iconSize: 30,
                color: Colors.grey,
                splashRadius: 25,
                icon: const Icon(FeatherIcons.fileText),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _currentIndex = 1;
                }),
                iconSize: 30,
                color: Colors.red,
                splashRadius: 25,
                icon: const Icon(Icons.favorite),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: showFab
          ? FloatingActionButton(
        heroTag: null,
        elevation: 6,
        onPressed: () => Navigator.of(context).pushNamed(
          SpeechToTextPage.routeName,
        ),
        backgroundColor: CustomColors.grey200,
        child: const Icon(
          Icons.add,
          color: Colors.grey,
          size: 30,
        ),
      )
          : null,
    );
  }
}