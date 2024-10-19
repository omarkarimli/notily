import 'package:notily/settings_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notily/note_model.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditPage extends StatefulWidget {
  final Settings currentSettings;
  final Function(bool, String, String) updateSettings;

  final Note? note; // Nullable Note object for editing an existing note

  const EditPage({Key? key, this.note, required this.currentSettings, required this.updateSettings}) : super(key: key);

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController _titleController;
  late TextEditingController _noteTypeController;
  late TextEditingController _contentController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  Color _selectedColor = Colors.white; // Variable to store the selected color

  String _selectedValue = 'Incomes';
  Future<void> _showDropdown() async {
    String? newValue = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        if(_noteTypeController.text != '') {
          if(_noteTypeController.text == AppLocalizations.of(context)!.incomes){
            _selectedValue = AppLocalizations.of(context)!.incomes;
          }
          else if(_noteTypeController.text == AppLocalizations.of(context)!.expenses){
            _selectedValue = AppLocalizations.of(context)!.expenses;
          }
          else{
            _selectedValue = AppLocalizations.of(context)!.notes;
          }
        }
        List<String> noteTypesArray = [AppLocalizations.of(context)!.incomes, AppLocalizations.of(context)!.expenses, AppLocalizations.of(context)!.notes];
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
                                                  color: _selectedValue == noteType ? const Color(0xFF83D39D) : Colors.grey.shade200,
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Icon(
                                                  _selectedValue == noteType ? Icons.done_all_rounded : Icons.done_rounded,
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
                                              if (_selectedValue != null) {
                                                _noteTypeController.text = noteType;
                                                Navigator.pop(context, noteType);
                                              }
                                            });
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
        _selectedValue = newValue;
      });
    }
  }

  late DateTime selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedDate = selectedDate.add(const Duration(hours: 15));
        _dateController.text = DateFormat('yyyy-MM-dd HH:mm:ss.SSSSSS').format(selectedDate);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _noteTypeController = TextEditingController(text: widget.note?.noteType ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _amountController = TextEditingController(text: widget.note?.amount ?? '');
    _dateController = TextEditingController(text: widget.note?.date ?? '');
    if (widget.note?.color != null) {
      _selectedColor = widget.note!.color;
    }
    selectedDate = _dateController.text.isEmpty ? DateTime.now() : DateTime.parse(_dateController.text);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteTypeController.dispose();
    _contentController.dispose();
    _amountController.dispose();
    _dateController.dispose();

    super.dispose();
  }

  TextEditingController changeNoteTypeFromDigitToText(TextEditingController controller) {
    controller.text = (int.tryParse(controller.text) != null ? (controller.text == '0' ? AppLocalizations.of(context)!.incomes :
                                                        controller.text == '1' ? AppLocalizations.of(context)!.expenses :
                                                        controller.text == '2' ? AppLocalizations.of(context)!.notes  :
                                                        '') :
                       controller.text
    );
    return controller;
  }

  @override
  Widget build(BuildContext context) {

    final isKeyboardActive = MediaQuery.of(context).viewInsets.bottom != 0;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(164),
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
                        widget.note == null ? AppLocalizations.of(context)!.add : AppLocalizations.of(context)!.edit,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(height: 24,),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.title,
                  labelStyle: Theme.of(context).textTheme.titleSmall,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(width: 3, color: Colors.greenAccent),
                  ),
                ),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 16.0),
              TextField(
                readOnly: true,
                controller: changeNoteTypeFromDigitToText(_noteTypeController),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.noteType,
                  labelStyle: Theme.of(context).textTheme.titleSmall,
                  suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(width: 3, color: Colors.greenAccent),
                  ),
                ),
                style: Theme.of(context).textTheme.titleSmall,
                onTap: () => _showDropdown(),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _contentController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.contentOptional,
                  labelStyle: Theme.of(context).textTheme.titleSmall,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(width: 3, color: Colors.greenAccent),
                  ),
                ),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.date_range_rounded),
                  labelText: AppLocalizations.of(context)!.dateTime,
                  labelStyle: Theme.of(context).textTheme.titleSmall,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(width: 3, color: Colors.greenAccent),
                  ),
                ),
                style: Theme.of(context).textTheme.titleSmall,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 32.0),

              if (_noteTypeController.text != AppLocalizations.of(context)!.notes) ... [
                TextField(
                  controller: _amountController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^[0-9+\-*/(). ]*$'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.amount,
                    labelStyle: Theme.of(context).textTheme.titleSmall,
                    suffixText: widget.currentSettings.cur,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(width: 3, color: Colors.greenAccent),
                    ),
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ],
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: isKeyboardActive ? null : FloatingActionButton(
        onPressed: () {
          if (_titleController.text.isNotEmpty &&
              _noteTypeController.text.isNotEmpty &&
              _dateController.text.isNotEmpty) {
            String noteType = 0.toString();
            if (_noteTypeController.text == AppLocalizations.of(context)!.incomes){
              noteType = 0.toString();
            }
            else if (_noteTypeController.text == AppLocalizations.of(context)!.expenses){
              noteType = 1.toString();
            }
            else if (_noteTypeController.text == AppLocalizations.of(context)!.notes){
              noteType = 2.toString();
            }

            String title = _titleController.text;
            String content = _contentController.text;
            DateTime editedTime = DateTime.now();
            String amount = _solveMathProblem();
            String date = _dateController.text;

            Note updatedNote = Note(
              title: title,
              noteType: noteType,
              content: content,
              editedTime: editedTime,
              color: _selectedColor,
              amount: amount,
              date: date,
            );

            Navigator.pop(context, updatedNote);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.black,
                content: Text(AppLocalizations.of(context)!.fillGaps),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        elevation: 0,
        backgroundColor: Colors.black87,
        child: const Icon(Icons.done_rounded),
      ),
    );
  }

  // Method to open the color picker dialog

  String _solveMathProblem() {
    try {
      Parser p = Parser();
      Expression exp = p.parse(_amountController.text);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);

      return result.toString();
    } catch (e) {
      return '0';
    }
  }
}
