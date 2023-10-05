import 'package:google_fonts/google_fonts.dart';
import 'package:voice_notes_app/utils/custom_colors.dart';
import 'package:voice_notes_app/utils/widgets/snackbar_widget.dart';
import '../../pages/note_info_page/notes_info_page.dart';
import '../../providers/authentication.dart';
import '../../providers/notes/notes_info.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../strings.dart';


class NotesItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notes = Provider.of<NotesInfo>(context, listen: false);
    final authData = Provider.of<Authentication>(context, listen: false);

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        tileColor: Colors.grey[200],
        title: Text(
          notes.title,
          style: GoogleFonts.mavenPro(
            color: Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          DateFormat.MMMMd().format(notes.dateTime),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        trailing: Consumer<NotesInfo>(
          builder: (context, notes, _) => IconButton(
            onPressed: () => notes
                .toggleFavourites(
              authToken: authData.token!,
              userId: authData.userId!,
            )
                .then((_) => SnackBarWidget(
              context: context,
              label: notes.isFavourite
                  ? StringsConst.noteAddedToFavourite
                  : StringsConst.noteRemovedFromFavourite,
              color: CustomColors.grey200!,
            ).show()),
            icon: Icon(
              notes.isFavourite ? Icons.favorite : Icons.favorite_border,
            ),
            color: Colors.redAccent,
          ),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChangeNotifierProvider.value(
              value: notes,
              child: const NotesInfoPage(),
            ),
          ),
        ),
      ),
    );
  }
}
