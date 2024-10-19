import 'dart:io';
import 'package:notily/noti.dart';
import 'package:notily/settings_model.dart';
import 'package:excel/excel.dart' as excelPlugin;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:notily/settings_page.dart';
import 'package:notily/note_model.dart';
import 'package:notily/edit_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class HomePage extends StatefulWidget {
  final Settings currentSettings;
  final Function(bool, String, String) updateSettings;

  final List<Note> notes;
  final Function(List<Note>) onNotesUpdated;

  const HomePage({Key? key, required this.notes, required this.onNotesUpdated, required this.currentSettings, required this.updateSettings,})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int daysInAMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
  double dayItemWidth = 64;
  int selectedDay = DateTime.now().day;

  Future<void> createExcelFile() async {
    var excel = excelPlugin.Excel.createExcel();

    var sheet = excel['Sheet1'];

    sheet.appendRow([
      AppLocalizations.of(context)!.dateTime,
      AppLocalizations.of(context)!.incomes,
      '${AppLocalizations.of(context)!.amount} (${widget.currentSettings.cur})'
    ]);

    // Set column widths
    sheet.setColWidth(0, 15);
    sheet.setColWidth(1, 15);
    sheet.setColWidth(2, 20);

    for (int index = 0; index < widget.notes.length; index++) {
      var note = widget.notes[index];
      if (note.noteType == '0') {
        sheet.appendRow([
          DateFormat('yyyy-MM-dd').format(note.editedTime),
          note.title,
          double.parse(note.amount)
        ]);
      }
    }

    sheet.appendRow(["", "", ""]); // Empty
    sheet.appendRow(["", "", ""]); // Empty

    sheet.appendRow([
      AppLocalizations.of(context)!.dateTime,
      AppLocalizations.of(context)!.expenses,
      '${AppLocalizations.of(context)!.amount} (${widget.currentSettings.cur})'
    ]);

    for (int index = 0; index < widget.notes.length; index++) {
      var note = widget.notes[index];
      if (note.noteType == '1') {
        sheet.appendRow([
          DateFormat('yyyy-MM-dd').format(note.editedTime),
          note.title,
          double.parse(note.amount)
        ]);
      }
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String filePath = '${documentsDirectory.path}/notily_excel.xlsx';

    var onValue = excel.encode();
    File file = File(filePath);
    await file.create(recursive: true);
    await file.writeAsBytes(onValue!);

    // Open Excel File
    OpenFile.open(filePath);
  }

  String selectedNoteTypeCategory = 'Total';
  Future<void> _showDropdownNoteTypeCategory() async {
    String? newValue = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        if(selectedNoteTypeCategory == 'Total') {
          selectedNoteTypeCategory = AppLocalizations.of(context)!.total;
        }
        List<String> noteTypesArray = [AppLocalizations.of(context)!.total, AppLocalizations.of(context)!.incomes, AppLocalizations.of(context)!.expenses, AppLocalizations.of(context)!.notes];
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
                            itemCount: noteTypesArray.length,
                            itemBuilder: (context, index) {
                              final noteType = noteTypesArray[index];

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
                                                  color: selectedNoteTypeCategory == noteType ? const Color(0xFF83D39D) : Colors.grey.shade200,
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Icon(
                                                  selectedNoteTypeCategory == noteType ? Icons.done_all_rounded : Icons.done_rounded,
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
                                                      noteType,
                                                      style: Theme.of(context).textTheme.titleSmall,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            setState(() {
                                              selectedNoteTypeCategory = noteType;
                                            });
                                            Navigator.pop(context, noteType); // Close the dialog and return the selected value
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
        selectedNoteTypeCategory = newValue;
      });
    }
  }

  double calculateIncomesSum() {
    double sum = 0;
    for (var note in widget.notes) {
      if (note.noteType == '0') {
        sum += double.parse(note.amount);
      }
    }
    return sum;
  }

  double calculateExpensesSum() {
    double sum = 0;
    for (var note in widget.notes) {
      if (note.noteType == '1') {
        sum += double.parse(note.amount);
      }
    }
    return sum;
  }

  List<Note> filteredNotes = []; // Store the filtered notes here
  String searchText = ''; // Store the search query here
  void onSearchTextChanged(String query) {
    setState(() {
      searchText = query;
      // Filter the notes based on the title containing the query (case-insensitive)
      filteredNotes = widget.notes.where((note) {
        final title = note.title.toLowerCase();
        final lowerCaseQuery = query.toLowerCase();
        return title.contains(lowerCaseQuery);
      }).toList();
    });
  }

  @override
  void initState() {
    // Initialize the filtered notes with all the notes initially
    filteredNotes = widget.notes;

    super.initState();

    Noti.initialize(flutterLocalNotificationsPlugin);

    // Schedule notifications for each note with a noteType of 'Expenses'
    _scheduleMonthlyNotificationsForExpenses();
  }

  // Schedule monthly notifications for notes with noteType 'Expenses'
  Future<void> _scheduleMonthlyNotificationsForExpenses() async {
    final currentDate = DateTime.now();

    for (Note note in widget.notes) {
      if (note.noteType == '1') {
        // Parse the note's date to a DateTime object
        final noteDate = DateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS").parse(note.date);

        // Check if the note's day is in the future
        if (noteDate.isAfter(currentDate)) {
          // Calculate the time difference between the note's day and the current date
          final timeDifference = noteDate.difference(currentDate);

          // Check if the notification for this note has already been scheduled
          final isNotificationScheduled = await _isNotificationScheduled(note);

          if (!isNotificationScheduled) {
            // Schedule a notification for the note's day
            await _scheduleNotification(note, timeDifference);
          }
        }
      }
    }
  }

  // Check if a notification for the note is already scheduled
  Future<bool> _isNotificationScheduled(Note note) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if a notification has been scheduled for this note
    return prefs.getBool('notification_${note.title}') ?? false;
  }

  Future<void> _scheduleNotification(Note note, Duration timeDifference) async {
    // Calculate the planned time for the notification
    final plannedTime = DateTime.now().add(timeDifference);

    await Noti.showScheduledNotification(
      title: note.title,
      body: '${note.amount} ${widget.currentSettings.cur}',
      plannedTime: plannedTime,
      fln: flutterLocalNotificationsPlugin,
    );

    // You should also update your persistent storage to mark this notification as scheduled
    // This prevents scheduling duplicate notifications
    await _markNotificationScheduled(note);
  }

  Future<void> _markNotificationScheduled(Note note) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Store the information that the notification for this note has been scheduled
    prefs.setBool('notification_${note.title}', true);
  }

  List<FlSpot> generateChartSpots(List<Note> notes) {
    List<FlSpot> chartSpots = [];

    int noteTypeIndex = (selectedNoteTypeCategory == AppLocalizations.of(context)!.incomes ? 0 :
                          selectedNoteTypeCategory == AppLocalizations.of(context)!.expenses ? 1 :
                          2);

    // Total
    if (selectedNoteTypeCategory == AppLocalizations.of(context)!.total || selectedNoteTypeCategory == 'Total') {

      double dailyTotalAmount = 0;
      for (int i = 0; i < daysInAMonth; i++) {
        double sumOfDailyIncomes = 0, sumOfDailyExpenses = 0;

        for (Note note in notes) {
          DateTime noteDate = DateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS").parse(note.date);
          if (note.noteType == 0.toString() && noteDate.day == (i + 1)) {
            sumOfDailyIncomes += double.parse(note.amount);
          }
          else if (note.noteType == 1.toString() && noteDate.day == (i + 1)) {
            sumOfDailyExpenses += double.parse(note.amount);
          }
          dailyTotalAmount += (sumOfDailyIncomes - sumOfDailyExpenses);
          sumOfDailyIncomes = 0;
          sumOfDailyExpenses = 0;
        }

        chartSpots.add(FlSpot(i.toDouble() + 1, dailyTotalAmount));
      }
    }
    // Income and Expenses
    else {
      for (int i = 0; i < daysInAMonth; i++) {
        double sumOfDailyAmounts = 0;

        for (Note note in notes) {
          DateTime noteDate = DateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS").parse(note.date);
          if (note.noteType == noteTypeIndex.toString() && noteDate.day == (i + 1)) {
            sumOfDailyAmounts += double.parse(note.amount);
          }
        }

        chartSpots.add(FlSpot(i.toDouble() + 1, sumOfDailyAmounts));
      }
    }

    return chartSpots;
  }

  bool isLineChartVisible = true;
  void toggleChart() {
    setState(() {
      isLineChartVisible = !isLineChartVisible;
    });
  }

  @override
  Widget build(BuildContext context) {

    // Sort the notes to display liked cards first, and then non-liked cards
    widget.notes.sort((a, b) => b.isDone ? 1 : -1);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(157),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 11),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AppBar(
                    leading: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          child: Image.asset(
                            'assets/appicon/appicon.png',
                            width: 148,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ],
                    ),
                    leadingWidth: double.infinity,
                    actions: [
                      IconButton(
                        onPressed: () {
                          createExcelFile(); // Call the function to create Excel file
                        },
                        icon: const Icon(Icons.file_download_outlined, size: 24),
                      ),
                      IconButton(
                          onPressed: () async  {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) {
                                  return SettingsPage(currentSettings: widget.currentSettings, updateSettings: widget.updateSettings);
                                },
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0); // Define the start position
                                  const end = Offset.zero; // Define the end position
                                  const curve = Curves.easeInOut; // Define the animation curve

                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                  var offsetAnimation = animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings_rounded, size: 24,)
                      ),
                    ],
                    flexibleSpace: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 108, 24, 0),
                      child: TextField(
                        onChanged: onSearchTextChanged,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          hintText: AppLocalizations.of(context)!.search,
                          hintStyle: Theme.of(context).textTheme.titleSmall,
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          fillColor: Colors.grey.shade200,
                          filled: true,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.black54),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.transparent),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.only(bottom: 104),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFCCE3F3), Colors.white], // Gradient
                        begin: Alignment.topLeft,
                        end: Alignment.topRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 11, 15, 0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () => _showDropdownNoteTypeCategory(),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            selectedNoteTypeCategory == 'Total' ? AppLocalizations.of(context)!.total :
                                            selectedNoteTypeCategory,
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          if (selectedNoteTypeCategory != AppLocalizations.of(context)!.notes) ...[
                                            if ((calculateIncomesSum() - calculateExpensesSum()) > 0) ...[
                                              const Icon(
                                                Icons.trending_up_rounded,
                                                size: 20,
                                                color: Colors.black87,
                                              ),
                                            ]
                                            else if ((calculateIncomesSum() - calculateExpensesSum()) < 0) ...[
                                              const Icon(
                                                Icons.trending_down_rounded,
                                                size: 20,
                                                color: Colors.black87,
                                              ),
                                            ]
                                            else ...[
                                                const Icon(
                                                  Icons.trending_neutral_rounded,
                                                  size: 20,
                                                  color: Colors.black87,
                                                ),
                                              ],
                                          ],
                                        ],
                                      ),
                                      const Icon(
                                        Icons.menu,
                                        size: 20,
                                        color: Color(0xFFCCE3F3),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      if (selectedNoteTypeCategory != AppLocalizations.of(context)!.notes) ...[
                                        if (selectedNoteTypeCategory == AppLocalizations.of(context)!.incomes) ...[
                                          Text(
                                            calculateIncomesSum().toStringAsFixed(2),
                                            style: Theme.of(context).textTheme.titleLarge,
                                          ),
                                        ]
                                        else if (selectedNoteTypeCategory == AppLocalizations.of(context)!.expenses) ...[
                                          Text(
                                            calculateExpensesSum().toStringAsFixed(2), // Format the sum to 2 decimal places
                                            style: Theme.of(context).textTheme.titleLarge,
                                          ),
                                        ]
                                        else ...[
                                            Text(
                                              (calculateIncomesSum() - calculateExpensesSum()).toStringAsFixed(2), // Format the sum to 2 decimal places
                                              style: Theme.of(context).textTheme.titleLarge,
                                            ),
                                          ],

                                        Text(
                                          ' ${widget.currentSettings.cur}',
                                          style: Theme.of(context).textTheme.titleLarge,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            if (selectedNoteTypeCategory != AppLocalizations.of(context)!.notes) ...[
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 500),
                                firstChild: AspectRatio(
                                  aspectRatio: 2,
                                  child: LineChart(LineChartData(
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: generateChartSpots(widget.notes),
                                        isCurved: false,
                                        dotData: const FlDotData(show: false),
                                        barWidth: 2,
                                        belowBarData: BarAreaData(show: false),
                                        aboveBarData: BarAreaData(show: false),
                                        gradient: const LinearGradient(
                                          colors: [Colors.white, Colors.black, Color(0xFFCCE3F3)], // Gradient
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                      ),
                                    ],
                                    titlesData: FlTitlesData(
                                      show: true,

                                      bottomTitles: AxisTitles(sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, titleMeta) => Text(
                                              value == daysInAMonth ? '${value.toInt()} ${AppLocalizations.of(context)!.day}' : value.toInt().toString(),
                                              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey.shade400),
                                            ),
                                        reservedSize: 28,
                                      )),
                                      topTitles: AxisTitles(sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, titleMeta) =>
                                        value == 1 ? Text(
                                          AppLocalizations.of(context)!.amount,
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.black54),
                                        ) : Text(
                                          value.toInt().toString(),
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.transparent),
                                        ),
                                        reservedSize: 48,
                                      )),
                                      leftTitles: AxisTitles(sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, titleMeta) =>
                                            Text(
                                              value.toInt().toString(),
                                              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey.shade400),
                                            ),
                                        reservedSize: 48,
                                      )),
                                      rightTitles: AxisTitles(sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, titleMeta) =>
                                            Text(
                                              value.toInt().toString(),
                                              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.transparent),
                                            ),
                                        reservedSize: 28,
                                      )),
                                    ),

                                    gridData: const FlGridData(
                                      show: true,
                                      horizontalInterval: 250,
                                      verticalInterval: 250,
                                    ),
                                    borderData: FlBorderData(show: false,),
                                  )),
                                ),
                                secondChild: SizedBox(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('vienss', style: Theme.of(context).textTheme.titleSmall?.copyWith(backgroundColor: Colors.white)),
                                    ],
                                  ),
                                ),

                                crossFadeState: isLineChartVisible
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                firstCurve: Curves.easeInOut,
                                secondCurve: Curves.easeInOut,
                                sizeCurve: Curves.easeInOut,
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_left_rounded),
                                    onPressed: () {
                                      toggleChart();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_right_rounded),
                                    onPressed: () {
                                      toggleChart();
                                    },
                                  ),
                                ],
                              ),
                            ],

                            selectedNoteTypeCategory == AppLocalizations.of(context)!.notes ? const SizedBox(height: 11,) : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8,),

                Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        top: -64,
                        child: ClipRRect(
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                                Colors.white.withOpacity(0.3),
                                BlendMode.dstIn,
                            ),
                            child: Image.asset(
                              'assets/images/abstract1.png',
                              width: 224,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 11, 15, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(17, 17, 0, 0),
                                  child: Text(
                                    AppLocalizations.of(context)!.day,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                const Expanded(child: SizedBox.shrink(),),
                              ],
                            ),
                            const SizedBox(height: 16,),

                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: SingleChildScrollView(
                                controller: ScrollController(initialScrollOffset: (selectedDay - 1) * dayItemWidth),
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: List.generate(
                                    daysInAMonth, (index) {
                                      final dayNumber = index + 1;

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedDay = dayNumber;
                                          });
                                        },
                                        child: Card(
                                          elevation: 0.3,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            width: dayItemWidth,
                                            height: dayNumber == selectedDay ? 80 : 60,
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              gradient: LinearGradient(
                                                colors: dayNumber == selectedDay ? [const Color(0xFFCCE3F3), Colors.white] : [Colors.white, Colors.white], // Gradient
                                                begin: Alignment.topLeft,
                                                end: Alignment.topRight,
                                              ),
                                              border: Border.all(
                                                color: dayNumber == selectedDay ? Colors.grey.shade600 : Colors.transparent,
                                                width: 0.2,
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '$dayNumber',
                                                    style: dayNumber == selectedDay
                                                        ? Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.black54, fontSize: 14)
                                                        : Theme.of(context).textTheme.titleSmall,
                                                  ),
                                                  Expanded(
                                                    child: dayNumber == selectedDay ? Text('.', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.black54)) : const SizedBox.shrink(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16,),

                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: searchText.isEmpty ? widget.notes.length : filteredNotes.length,
                              itemBuilder: (context, index) {
                                final note = searchText.isEmpty ? widget.notes[index] : filteredNotes[index];

                                // Visual
                                if (DateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS").parse(note.date).day == selectedDay){
                                  return Dismissible(
                                    key: Key(note.editedTime.toIso8601String()),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) {
                                      if(direction == DismissDirection.endToStart){
                                        setState(() {
                                          // Remove the note from the appropriate list based on whether search is active or not
                                          if (searchText.isEmpty) {
                                            widget.notes.removeAt(index);
                                          } else {
                                            filteredNotes.removeAt(index);
                                          }
                                        });
                                        widget.onNotesUpdated(widget.notes);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            backgroundColor: Colors.black,
                                            content: Text(AppLocalizations.of(context)!.deleted),
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      }
                                    },

                                    background: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(0),
                                        child: Container(
                                          color: Colors.red,
                                          alignment: Alignment.centerRight,
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),

                                    child: Card(
                                      margin: const EdgeInsets.only(bottom: 0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(0),
                                      ),
                                      elevation: 0,
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
                                                        color: note.isDone ? const Color(0xFF83D39D) : Colors.grey.shade200,
                                                        borderRadius: BorderRadius.circular(16),
                                                        border: Border.all(
                                                          color: Colors.transparent,
                                                          width: 2, // Border width
                                                        ),
                                                      ),
                                                      child: AnimatedSwitcher(
                                                        duration: const Duration(milliseconds: 500), // Adjust the duration as needed
                                                        child: IconButton(
                                                          key: ValueKey<bool>(note.isDone), // This key helps Flutter identify the different IconButton states
                                                          alignment: Alignment.center,
                                                          padding: const EdgeInsets.all(0),
                                                          onPressed: () {
                                                            setState(() {
                                                              note.isDone = !note.isDone;
                                                              widget.notes[index] = note;
                                                              widget.onNotesUpdated(widget.notes);
                                                            });

                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                              SnackBar(
                                                                backgroundColor: Colors.black,
                                                                content: Text(note.isDone
                                                                    ? AppLocalizations.of(context)!.done
                                                                    : AppLocalizations.of(context)!.undone),
                                                                duration: const Duration(seconds: 1),
                                                              ),
                                                            );
                                                          },
                                                          icon: Icon(
                                                            note.isDone ? Icons.done_all_rounded : Icons.done_rounded,
                                                            color: Colors.white,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            note.title,
                                                            style: Theme.of(context).textTheme.titleSmall,
                                                          ),
                                                          const Expanded(child: SizedBox()), // Add an expanded spacer
                                                          if (note.noteType != 2.toString()) ...[
                                                            Text(
                                                              '${note.noteType == 0.toString() ? '+' :
                                                              note.noteType == 1.toString() ? '-' :
                                                              ''}${note.amount} ${widget.currentSettings.cur}',

                                                              style: note.noteType == 0.toString() ? Theme.of(context).textTheme.titleSmall!.copyWith(color: const Color(0xFF83D39D)) :
                                                              note.noteType == 1.toString() ? Theme.of(context).textTheme.titleSmall!.copyWith(color: const Color(0xFFD38383)) :
                                                              Theme.of(context).textTheme.titleSmall,
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onTap: () {
                                                  // Open the edit page with the selected note data.
                                                  Navigator.push(
                                                    context,
                                                    PageRouteBuilder(
                                                      pageBuilder: (context, animation, secondaryAnimation) {
                                                        return EditPage(
                                                          note: note, // Pass the selected note to EditPage
                                                          currentSettings: widget.currentSettings,
                                                          updateSettings: widget.updateSettings,
                                                        );
                                                      },
                                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                        const begin = Offset(1.0, 0.0); // Define the start position
                                                        const end = Offset.zero; // Define the end position
                                                        const curve = Curves.easeInOut; // Define the animation curve

                                                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                                                        var offsetAnimation = animation.drive(tween);

                                                        return SlideTransition(
                                                          position: offsetAnimation,
                                                          child: child,
                                                        );
                                                      },
                                                    ),
                                                  ).then((updatedNote) {
                                                    if (updatedNote != null) {
                                                      setState(() {
                                                        widget.notes[index] = updatedNote;
                                                      });
                                                      widget.onNotesUpdated(widget.notes);
                                                    }
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return const SizedBox.shrink();
                              },
                            ),

                            if((searchText.isEmpty ? widget.notes.length : filteredNotes.length) == 0) ...[
                              SizedBox(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    AppLocalizations.of(context)!.noResult,
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 16,),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        height: 70,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36), // Adjust the radius as needed
              color: Colors.black87,
            ),
            child: FloatingActionButton(
              onPressed: () {
                // Open the edit page to add a new note.
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return EditPage(
                        currentSettings: widget.currentSettings,
                        updateSettings: widget.updateSettings,
                      );
                    },
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0); // Define the start position
                      const end = Offset.zero; // Define the end position
                      const curve = Curves.easeInOut; // Define the animation curve

                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                ).then((newNote) {
                  if (newNote != null) {
                    setState(() {
                      widget.notes.add(newNote);
                    });
                    widget.onNotesUpdated(widget.notes);
                  }
                });
              },
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Text(
                AppLocalizations.of(context)!.addToTheList,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
