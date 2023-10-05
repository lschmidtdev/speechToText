import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:voice_notes_app/utils/images.dart';
import 'package:voice_notes_app/utils/strings.dart';

import '../../pages/speech_to_text/speech_to_text.dart';
import '../../providers/authentication.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});
  Divider divider = const Divider(color: Colors.white);

  @override
  Widget customListTile({
    required BuildContext buildContext,
    required String title,
    required IconData iconData,
    required VoidCallback onTap,
}) {
    return ListTile(
      tileColor: Colors.grey[200],
      leading: Icon(
        iconData,
        color: Colors.grey,
        size: 30,
      ),
      title: Text(
        title,
        style: GoogleFonts.mavenPro(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 20,
        ),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build (BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            color: Colors.white,
            child: Image.network(
              ImagesPath.documetCheklistImage,
              fit: BoxFit.cover,
            ),
          ),
          divider,
          customListTile(
            buildContext: context,
            title: StringsConst.addNewNote,
            iconData: Icons.note_add_rounded,
            onTap: () {
              Scaffold.of(context).closeDrawer();
              Navigator.of(context).pushNamed(SpeechToTextPage.routeName);
            }
          ),
          divider,
          customListTile(
              buildContext: context,
              title: StringsConst.logout,
              iconData: Icons.logout,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context){
                    return AlertDialog(
                      title: const Text(StringsConst.alertDialogText0),
                      content: const Text(StringsConst.alertDialogText2),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(StringsConst.no),
                        ),
                        TextButton(onPressed: () {
                          Navigator.of(context).pop();
                          Provider.of<Authentication>(context, listen: false).logout();
                        },
                        child: const Text(StringsConst.yes),
                        ),
                      ],
                    );
                  }
                );
              }
          )
        ],
      ),
    );
  }
}


