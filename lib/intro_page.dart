import 'package:flutter/material.dart';
import 'package:notily/note_model.dart';
import 'package:notily/settings_model.dart';
import 'package:url_launcher/url_launcher.dart';

class IntroPage extends StatefulWidget {
  final Settings currentSettings;
  final Function(bool, String, String) updateSettings;

  final List<Note> notes;
  final Function(List<Note>) onNotesUpdated;

  const IntroPage({Key? key, required this.notes, required this.onNotesUpdated, required this.currentSettings, required this.updateSettings,})
      : super(key: key);

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {

  int _currentIndex = 0;
  void _changeContainerFw() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _containers.length;
    });
  }
  void _changeContainerBw() {
    setState(() {
      _currentIndex = (_currentIndex - 1) % _containers.length;
    });
  }

  final List<Widget> _containers = [
    Container(
      height: 576,
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFFCCE3F3), Colors.white], // Gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 28, 0, 0),
        child: Stack(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'New\napproach\nfor your\nFinance',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFF201A1A),
                    fontSize: 38,
                    fontWeight: FontWeight.w500,
                    height: 1.22,
                  ),
                ),
                SizedBox(height: 12,),
                Text(
                  'Now your finances are in one place and always under control',
                  style: TextStyle(
                    color: Color(0xFF5A5B5F),
                    fontSize: 16,
                    fontFamily: 'SuisseIntl',
                  ),
                ),
              ],
            ),
            Positioned(
              right: -32,
              bottom: -64,
              child: ClipRRect(
                child: Image.asset(
                  'assets/images/abstract1.png',
                  width: 384,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    Container(
      height: 576,
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFFD3EBCD), Colors.white], // Gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 28, 0, 0),
        child: Stack(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Quick\nanalysis\nof all\nexpenses',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFF201A1A),
                    fontSize: 38,
                    fontWeight: FontWeight.w500,
                    height: 1.22,
                  ),
                ),
                SizedBox(height: 12,),
                Padding(
                  padding: EdgeInsets.only(right: 32),
                  child: Text(
                    'All expenses by cards are reflected automatically in the application, and the analytics system helps to control them',
                    style: TextStyle(
                      color: Color(0xFF5A5B5F),
                      fontSize: 16,
                      fontFamily: 'SuisseIntl',
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: -64,
              bottom: -80,
              child: ClipRRect(
                child: Image.asset(
                  'assets/images/abstract2.png',
                  width: 384,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    Container(
      height: 576,
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFFF8EED4), Colors.white], // Gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 28, 0, 0),
        child: Stack(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Tips\nto optimize\neach\nspending',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFF201A1A),
                    fontSize: 38,
                    fontWeight: FontWeight.w500,
                    height: 1.22,
                  ),
                ),
                SizedBox(height: 12,),
                Padding(
                  padding: EdgeInsets.only(right: 32),
                  child: Text(
                    'The system notices where you\'re slipping on the budget and tells you how to optimize costs',
                    style: TextStyle(
                      color: Color(0xFF5A5B5F),
                      fontSize: 16,
                      fontFamily: 'SuisseIntl',
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: -64,
              bottom: -80,
              child: ClipRRect(
                child: Image.asset(
                  'assets/images/abstract3.png',
                  width: 384,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    Container(
      height: 576,
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFFE9EAEF), Colors.white], // Gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 0, 0),
        child: Stack(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'End\nUser\nLicense\nAgreement',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: Color(0xFF201A1A),
                    fontSize: 38,
                    fontWeight: FontWeight.w500,
                    height: 1.22,
                  ),
                ),
                SizedBox(height: 12,),
                Padding(
                  padding: EdgeInsets.only(right: 32),
                  child: Text(
                    'By clicking \'Agree EULA & Complete\' you accept the EULA and the application will be launched. You can view the EULA by clicking the \'Document\' file in the top right.',
                    style: TextStyle(
                      color: Color(0xFF5A5B5F),
                      fontSize: 16,
                      fontFamily: 'SuisseIntl',
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: -64,
              bottom: -80,
              child: ClipRRect(
                child: Image.asset(
                  'assets/images/abstract4.png',
                  width: 384,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('vienss', style: Theme.of(context).textTheme.titleSmall),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Stack(
                            children: [
                              AnimatedCrossFade(
                                firstChild: _containers[_currentIndex],
                                secondChild: _containers[(_currentIndex + 1) % _containers.length],
                                crossFadeState: CrossFadeState.showFirst,

                                duration: const Duration(milliseconds: 100),
                                sizeCurve: Curves.easeInOut,
                              ),
                              Positioned(
                                right: 16,
                                top: 16,
                                child: IconButton(
                                  icon: const Icon(Icons.file_open_outlined, size: 18),
                                  onPressed: () {
                                    launchUrl(
                                      Uri.parse('https://docs.google.com/document/d/1XUaTHl2HYqs-qZx7mlwj0wOxE2iFEXziBn7KoEms0E8/edit?usp=sharing'),
                                      mode: LaunchMode.inAppWebView,
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                left: 32,
                                bottom: 32,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      if(_currentIndex != 0) ...[
                                        IconButton(
                                          onPressed: _changeContainerBw,
                                          icon: const Icon(Icons.arrow_back_ios_rounded),
                                        ),
                                      ],
                                      if(_currentIndex != _containers.length-1) ...[
                                        IconButton(
                                          onPressed: _changeContainerFw,
                                          icon: const Icon(Icons.arrow_forward_ios_rounded),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: LinearGradient(
                        colors: [
                          _currentIndex == 0 ? const Color(0xFFCCE3F3) :
                          _currentIndex == 1 ? const Color(0xFFD3EBCD) :
                          _currentIndex == 2 ? const Color(0xFFF8EED4) :
                          const Color(0xFFE9EAEF),

                          Colors.white,
                        ], // Gradient
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if(_currentIndex == _containers.length-1) {
                                  widget.updateSettings(false, widget.currentSettings.cur, widget.currentSettings.lang);
                                }
                                else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.black,
                                      content: Text('Read all tips'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                color: Colors.black87,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'Agree EULA & Complete',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for(int i = 0; i < _containers.length; i++) ...[
                              Icon(
                                i == _currentIndex ? Icons.circle_rounded : Icons.circle_outlined,
                                size: 12,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
