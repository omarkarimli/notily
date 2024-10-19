import 'package:notily/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.currentSettings, required this.updateSettings});

  final Settings currentSettings;
  final Function(bool, String, String) updateSettings;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  late String selectedCurrencyCategory;
  late String selectedLanguageCategory;

  @override
  void initState() {
    super.initState();
    selectedCurrencyCategory = widget.currentSettings.cur;
    selectedLanguageCategory = widget.currentSettings.lang;
  }

  Future<void> _showDropdownLanguageCategory() async {
    String? newValue = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        List<String> langTypesArray = ['en', 'az', 'ru'];
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 11, 15, 11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: langTypesArray.length,
                            itemBuilder: (context, index) {
                              final langType = langTypesArray[index];

                              // Visual
                              return Card(
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Stack(
                                      alignment: Alignment.centerRight,
                                      fit: StackFit.passthrough,
                                      children: [
                                        ListTile(
                                          title: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 42,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  color: selectedLanguageCategory == langType ? const Color(0xFF83D39D) : Colors.grey.shade200,
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Icon(
                                                  selectedLanguageCategory == langType ? Icons.done_all_rounded : Icons.done_rounded,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      langType,
                                                      style: Theme.of(context).textTheme.titleSmall,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            setState(() {
                                              selectedLanguageCategory = langType;
                                            });
                                            Navigator.pop(context, langType); // Close the dialog and return the selected value
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );

                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (newValue != null) {
      setState(() {
        selectedLanguageCategory = newValue;
      });

      widget.updateSettings(widget.currentSettings.firstOpen, widget.currentSettings.cur, newValue);
      Navigator.pop(context); // Close the dialog
    }
  }

  Future<void> _showDropdownCurrencyCategory() async {
    String? newValue = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        List<String> curTypesArray = ['AZN', 'USD', 'EUR'];
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(15, 11, 15, 11),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: curTypesArray.length,
                            itemBuilder: (context, index) {
                              final curType = curTypesArray[index];

                              // Visual
                              return Card(
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Stack(
                                      alignment: Alignment.centerRight,
                                      fit: StackFit.passthrough,
                                      children: [
                                        ListTile(
                                          title: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 42,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  color: selectedCurrencyCategory == curType ? const Color(0xFF83D39D) : Colors.grey.shade200,
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Icon(
                                                  selectedCurrencyCategory == curType ? Icons.done_all_rounded : Icons.done_rounded,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      curType,
                                                      style: Theme.of(context).textTheme.titleSmall,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            setState(() {
                                              selectedCurrencyCategory = curType;
                                            });
                                            Navigator.pop(context, curType); // Close the dialog and return the selected value
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );

                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (newValue != null) {
      setState(() {
        selectedCurrencyCategory = newValue;
      });

      widget.updateSettings(widget.currentSettings.firstOpen, newValue, widget.currentSettings.lang);
      Navigator.pop(context); // Close the dialog
    }
  }

  Future<void>? _launched;
  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(188),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
              flexibleSpace: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        AppLocalizations.of(context)!.settings,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 26.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 72,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 72,
                                  padding: const EdgeInsets.only(top: 8, left: 16, right: 24, bottom: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.dark_mode_outlined,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Container(
                                          height: double.infinity,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: const BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  AppLocalizations.of(context)!.theme,
                                                  style: Theme.of(context).textTheme.displaySmall,
                                                ),
                                              ),
                                              SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  AppLocalizations.of(context)!.lightMode,
                                                  style: Theme.of(context).textTheme.titleSmall,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showDropdownLanguageCategory(),
                            child: SizedBox(
                              width: double.infinity,
                              height: 72,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 72,
                                    padding: const EdgeInsets.only(top: 8, left: 16, right: 24, bottom: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.language_rounded,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Container(
                                            height: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: const BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: Text(
                                                    AppLocalizations.of(context)!.languageWord,
                                                    style: Theme.of(context).textTheme.displaySmall,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: Text(
                                                    selectedLanguageCategory,
                                                    style: Theme.of(context).textTheme.titleSmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showDropdownCurrencyCategory(),
                            child: SizedBox(
                              width: double.infinity,
                              height: 72,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 72,
                                    padding: const EdgeInsets.only(top: 8, left: 16, right: 24, bottom: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.attach_money_rounded,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Container(
                                            height: double.infinity,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: const BoxDecoration(),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: Text(
                                                    AppLocalizations.of(context)!.currency,
                                                    style: Theme.of(context).textTheme.displaySmall,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: double.infinity,
                                                  child: Text(
                                                    selectedCurrencyCategory,
                                                    style: Theme.of(context).textTheme.titleSmall,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 72,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 72,
                                  padding: const EdgeInsets.only(top: 8, left: 16, right: 24, bottom: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Container(
                                          height: double.infinity,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: const BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  AppLocalizations.of(context)!.about,
                                                  style: Theme.of(context).textTheme.displaySmall,
                                                ),
                                              ),
                                              SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  'notily 0.0.1',
                                                  style: Theme.of(context).textTheme.titleSmall,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16,),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Container(
                        height: 448,
                        alignment: Alignment.topLeft,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFCCE3F3), Colors.white], // Gradient
                            begin: Alignment.topLeft,
                            end: Alignment.topRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(32, 28, 0, 0),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -32,
                                bottom: -64,
                                child: ClipRRect(
                                  child: ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                        Colors.white.withOpacity(0.5),
                                        BlendMode.dstIn,
                                    ),
                                    child: Image.asset(
                                      'assets/images/abstract1.png',
                                      width: 256,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.supportme,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 12,),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap:  () => setState(() {
                                          final Uri toLaunch = Uri(scheme: 'https', host: 'www.instagram.com', path: '_vienss/');
                                          _launched = _launchInBrowser(toLaunch);
                                        }),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 72,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                height: 72,
                                                padding: const EdgeInsets.only(top: 8, right: 24, bottom: 8),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                      child: Image.asset(
                                                        'assets/images/instagram.png',
                                                        width: 20,
                                                        color: Colors.grey.shade900,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Container(
                                                        height: double.infinity,
                                                        clipBehavior: Clip.antiAlias,
                                                        decoration: const BoxDecoration(),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            SizedBox(
                                                              width: double.infinity,
                                                              child: Text(
                                                                'Instagram',
                                                                style: Theme.of(context).textTheme.displaySmall,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: double.infinity,
                                                              child: Text(
                                                                '@_vienss',
                                                                style: Theme.of(context).textTheme.titleSmall,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap:  () => setState(() {
                                          final Uri toLaunch = Uri(scheme: 'https', host: 'www.linkedin.com', path: '/in/omar-kerimli-7o7');
                                          _launched = _launchInBrowser(toLaunch);
                                        }),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 72,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                height: 72,
                                                padding: const EdgeInsets.only(top: 8, right: 24, bottom: 8),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                      child: Image.asset(
                                                        'assets/images/linkedin.png',
                                                        width: 20,
                                                        color: Colors.grey.shade900,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Container(
                                                        height: double.infinity,
                                                        clipBehavior: Clip.antiAlias,
                                                        decoration: const BoxDecoration(),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            SizedBox(
                                                              width: double.infinity,
                                                              child: Text(
                                                                'LinkedIn',
                                                                style: Theme.of(context).textTheme.displaySmall,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: double.infinity,
                                                              child: Text(
                                                                '@omar-kerimli-7o7',
                                                                style: Theme.of(context).textTheme.titleSmall,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap:  () => setState(() {
                                          final Uri toLaunch = Uri(scheme: 'https', host: 'www.patreon.com', path: '/vienss/');
                                          _launched = _launchInBrowser(toLaunch);
                                        }),
                                        child: SizedBox(
                                          width: double.infinity,
                                          height: 72,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                height: 72,
                                                padding: const EdgeInsets.only(top: 8, right: 24, bottom: 8),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                      child: Image.asset(
                                                        'assets/images/patreon.png',
                                                        width: 20,
                                                        color: Colors.grey.shade900,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Container(
                                                        height: double.infinity,
                                                        clipBehavior: Clip.antiAlias,
                                                        decoration: const BoxDecoration(),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            SizedBox(
                                                              width: double.infinity,
                                                              child: Text(
                                                                'Patreon',
                                                                style: Theme.of(context).textTheme.displaySmall,
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: double.infinity,
                                                              child: Text(
                                                                '@vienss',
                                                                style: Theme.of(context).textTheme.titleSmall,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}