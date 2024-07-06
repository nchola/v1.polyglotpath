import 'package:flutter/material.dart';
import 'package:polyglotpath/widgets/global_bottom_nav_bar.dart';

class DetailScreen extends StatefulWidget {
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/favorites');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/community');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Terima argument sebagai Map<String, String>
    final Map<String, String> arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    final String level = arguments['level']!;
    final String lesson = arguments['lesson']!;
    final String description = arguments['description']!;
    final String language = arguments['language']!;
    final String imagePath = arguments['imagePath']!;

    List<Widget> _widgetOptions = <Widget>[
      Text('Home for $language', style: TextStyle(fontSize: 24)),
      Text('Favorites for $language', style: TextStyle(fontSize: 24)),
      Text('Community for $language', style: TextStyle(fontSize: 24)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('$language - $level - $lesson'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  language,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 4),
                        blurRadius: 4,
                        color: Color.fromARGB(63, 0, 0, 0),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Image.asset(
                  imagePath,
                  width: 48,
                  height: 41,
                  fit: BoxFit.contain,
                  color: Colors.transparent,
                  colorBlendMode: BlendMode.colorBurn,
                  filterQuality: FilterQuality.high,
                  alignment: Alignment.center,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$lesson',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              description,
              style: TextStyle(fontSize: 16),
            ),
            // Add other lesson details here
          ],
        ),
      ),
      bottomNavigationBar: GlobalBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
