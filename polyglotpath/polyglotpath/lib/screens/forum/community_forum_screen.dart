import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/forumtile.dart';
import 'forum_list_screen.dart'; // Pastikan path impor ini sesuai dengan struktur proyek Anda
import 'package:provider/provider.dart';
import 'package:polyglotpath/services/theme_provider.dart';

class CommunityForumScreen extends StatelessWidget {
  final List<Map<String, String>> forums = [
    {
      'title': 'English Forum',
      'forumName': 'english_forum',
      'flagAsset': 'assets/english.png',
    },
    {
      'title': 'Japanese Forum',
      'forumName': 'japanese_forum',
      'flagAsset': 'assets/japan.png',
    },
    {
      'title': 'Korean Forum',
      'forumName': 'korean_forum',
      'flagAsset': 'assets/korea.png',
    },
    {
      'title': 'Russian Forum',
      'forumName': 'russian_forum',
      'flagAsset': 'assets/russia.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Community Forum',
          style: GoogleFonts.montserrat(
            textStyle: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
        backgroundColor:
            themeProvider.isDarkMode ? Colors.grey.shade900 : Colors.teal,
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: forums.length,
        itemBuilder: (context, index) {
          final forum = forums[index];
          final color = index % 2 == 0
              ? (themeProvider.isDarkMode ? Colors.teal.shade700 : Colors.teal)
              : (themeProvider.isDarkMode
                  ? Colors.grey.shade800
                  : Colors.grey.shade200);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: MouseRegion(
              onEnter: (_) {
                // You can add custom logic when the mouse enters the region if needed
              },
              onExit: (_) {
                // You can add custom logic when the mouse exits the region if needed
              },
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                      color: themeProvider.isDarkMode
                          ? Colors.white
                          : Colors.black),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: ForumTile(
                  title: forum['title']!,
                  forumName: forum['forumName']!,
                  flagAsset: forum['flagAsset']!,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForumPage(
                        forumName: forum['forumName']!,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
