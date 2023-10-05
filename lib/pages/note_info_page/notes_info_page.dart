import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:voice_notes_app/providers/authentication.dart';
import 'package:voice_notes_app/utils/custom_colors.dart';
import 'package:voice_notes_app/utils/strings.dart';
import '../../providers/notes/notes.dart';
import '../../providers/notes/notes_info.dart';
import '../../utils/widgets/snackbar_widget.dart';
import '../speech_to_text/speech_to_text.dart';

class NotesInfoPage extends StatelessWidget {
  const NotesInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authData = context.watch<Authentication>();
    final notes = context.watch<NotesInfo>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notes.title,
                      style: GoogleFonts.mavenPro(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      DateFormat.MMMMEEEEd()
                          .addPattern('h:mm a')
                          .format(notes.dateTime),
                      style: Theme.of(context).textTheme.titleSmall!,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Expanded(
              flex: 8,
              child: ListView(
                children: [
                  Text(
                    notes.description,
                    style: Theme.of(context).textTheme.titleMedium!,
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(StringsConst.alertDialogText0),
                        content: const Text(StringsConst.alertDialogText1),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(StringsConst.no),
                          ),
                          TextButton(
                            onPressed: () async {
                              await context
                                  .read<Notes>()
                                  .deleteNote(notes.id)
                                  .whenComplete(() {
                                SnackBarWidget(
                                  context: context,
                                  label: StringsConst.noteDeleted,
                                  color: Colors.grey[200]!,
                                ).show();
                                Navigator.of(context).pop();
                              });
                            },
                            child: const Text(StringsConst.yes),
                          ),
                        ],
                      );
                    },
                  );
                },
                iconSize: 30,
                splashRadius: 25,
                icon: const Icon(
                  FeatherIcons.trash2,
                  color: Colors.red,
                ),
              ),
              Consumer<NotesInfo>(
                builder: (context, notes, _) => IconButton(
                  onPressed: () async {
                    await notes.toggleFavourites(
                      userId: authData.userId!,
                      authToken: authData.token!,
                    );
                    SnackBarWidget(
                      context: context,
                      label: notes.isFavourite
                          ? StringsConst.noteAddedToFavourite
                          : StringsConst.noteRemovedFromFavourite,
                      color: CustomColors.grey200!,
                    ).show();
                  },
                  iconSize: 30,
                  color: Colors.red,
                  splashRadius: 25,
                  icon: Icon(
                    notes.isFavourite
                        ? Icons.favorite
                        : Icons.favorite_border_rounded,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(
            SpeechToTextPage.routeName,
            arguments: {
              'id': notes.id,
              'title': notes.title,
              'description': notes.description,
              'isFavourite': notes.isFavourite,
            },
          );
        },
        backgroundColor: Colors.grey[200],
        elevation: 6,
        child: const Icon(
          FeatherIcons.edit,
          color: Colors.grey,
          size: 30,
        ),
      ),
    );
  }
}
