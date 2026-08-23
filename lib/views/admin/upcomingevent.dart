import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../controllers/event_controller.dart';
import '../../models/event_model.dart';

/// Pass [existingEvent] to open in Edit mode; omit it for Add mode.
class AddFestivalScreen extends StatefulWidget {
  final EventModel? existingEvent;

  const AddFestivalScreen({super.key, this.existingEvent});

  @override
  State<AddFestivalScreen> createState() => _AddFestivalScreenState();
}

class _AddFestivalScreenState extends State<AddFestivalScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController titleController;
  late final TextEditingController subtitleController;

  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late bool notificationEnabled;

  bool get _isEditMode => widget.existingEvent != null;

  static const Color primaryRed = Color(0xFFE50914);
  static const Color bgColor = Color(0xFFFFF8ED);
  static const Color borderColor = Color(0xFFEBDCC7);
  static const Color darkText = Color(0xFF302B28);
  static const Color secondaryText = Color(0xFF7A7069);

  @override
  void initState() {
    super.initState();
    final e = widget.existingEvent;

    // Pre-fill controllers from existing event (Edit mode) or blank (Add mode)
    titleController = TextEditingController(text: e?.title ?? '');
    subtitleController = TextEditingController(text: e?.subtitle ?? '');
    notificationEnabled = e?.notification ?? true;

    // Parse date from event model
    if (e != null) {
      final monthIndex = _monthAbbreviations.indexOf(e.month.toUpperCase());
      final day = int.tryParse(e.date) ?? DateTime.now().day;
      final month = monthIndex >= 0 ? monthIndex + 1 : DateTime.now().month;
      selectedDate = DateTime(DateTime.now().year, month, day);

      // Parse time from "7:00 AM Onwards" format
      final timeStr = e.time.replaceAll(' Onwards', '').trim();
      selectedTime = _parseTimeOfDay(timeStr);
    } else {
      selectedDate = DateTime.now();
      selectedTime = const TimeOfDay(hour: 7, minute: 0);
    }
  }

  static const List<String> _monthAbbreviations = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];

  TimeOfDay _parseTimeOfDay(String timeStr) {
    try {
      final isPm = timeStr.toLowerCase().contains('pm');
      final isAm = timeStr.toLowerCase().contains('am');
      final clean = timeStr
          .toLowerCase()
          .replaceAll('am', '')
          .replaceAll('pm', '')
          .trim();
      final parts = clean.split(':');
      int hour = int.parse(parts[0].trim());
      final int minute =
          parts.length > 1 ? int.parse(parts[1].trim()) : 0;
      if (isPm && hour != 12) hour += 12;
      if (isAm && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 7, minute: 0);
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    subtitleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (time != null) setState(() => selectedTime = time);
  }

  String get monthName => _monthAbbreviations[selectedDate.month - 1];

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    final eventController = context.read<EventController>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: primaryRed),
      ),
    );

    bool success;

    if (_isEditMode) {
      // ── EDIT mode ──
      success = await eventController.updateEvent(
        id: widget.existingEvent!.id,
        month: monthName,
        date: selectedDate.day.toString(),
        title: titleController.text,
        subtitle: subtitleController.text,
        time: '${selectedTime.format(context)} Onwards',
        notification: notificationEnabled,
        eventDate: selectedDate,
      );
    } else {
      // ── ADD mode ──
      success = await eventController.addEvent(
        month: monthName,
        date: selectedDate.day.toString(),
        title: titleController.text,
        subtitle: subtitleController.text,
        time: '${selectedTime.format(context)} Onwards',
        notification: notificationEnabled,
        eventDate: selectedDate,
      );
    }

    // Pop the loading dialog
    if (mounted) Navigator.pop(context);

    if (success) {
      if (mounted) Navigator.pop(context);
      Get.snackbar(
        'Success',
        _isEditMode
            ? 'Event updated successfully!'
            : 'Festival event added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        eventController.errorMessage ?? 'Something went wrong.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: primaryRed,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        surfaceTintColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _isEditMode ? 'Edit Festival' : 'Add Festival',
          style: const TextStyle(
            color: darkText,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkText),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 600 ? 40 : 16,
                vertical: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D000000),
                                blurRadius: 18,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isEditMode
                                    ? 'Edit Festival Details'
                                    : 'Festival Details',
                                style: const TextStyle(
                                  color: darkText,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: 18),

                              // EVENT NAME
                              _label('Event Name'),
                              const SizedBox(height: 7),
                              TextFormField(
                                controller: titleController,
                                onChanged: (_) => setState(() {}),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter event name';
                                  }
                                  return null;
                                },
                                decoration: _inputDecoration(
                                  hint: 'Ex: Maha Saptami',
                                  icon: Icons.temple_hindu_rounded,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // SUBTITLE
                              _label('Subtitle'),
                              const SizedBox(height: 7),
                              TextFormField(
                                controller: subtitleController,
                                onChanged: (_) => setState(() {}),
                                decoration: _inputDecoration(
                                  hint: 'Ex: Puja & Pushpanjali',
                                  icon: Icons.auto_awesome_rounded,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // DATE
                              _label('Date'),
                              const SizedBox(height: 7),
                              InkWell(
                                onTap: _selectDate,
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: double.infinity,
                                  height: 54,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFCF7),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_month_rounded,
                                        color: primaryRed,
                                        size: 21,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '${selectedDate.day.toString().padLeft(2, '0')} '
                                          '$monthName '
                                          '${selectedDate.year}',
                                          style: const TextStyle(
                                            color: darkText,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: secondaryText,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // TIME
                              _label('Time'),
                              const SizedBox(height: 7),
                              InkWell(
                                onTap: _selectTime,
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  height: 54,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFCF7),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule_rounded,
                                        color: primaryRed,
                                        size: 21,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          selectedTime.format(context),
                                          style: const TextStyle(
                                            color: darkText,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: secondaryText,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // NOTIFICATION
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8F3),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFE9EA),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.notifications_none_rounded,
                                        color: primaryRed,
                                        size: 21,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Notification',
                                            style: TextStyle(
                                              color: darkText,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Notify users about this event',
                                            style: TextStyle(
                                              color: secondaryText,
                                              fontSize: 11.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: notificationEnabled,
                                      activeThumbColor: primaryRed,
                                      onChanged: (value) {
                                        setState(() {
                                          notificationEnabled = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── BUTTONS ──────────────────────────────────────
                        Row(
                          children: [
                            // CANCEL
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: primaryRed,
                                    side: const BorderSide(
                                        color: primaryRed, width: 1.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // SAVE / UPDATE
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _saveData,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: primaryRed,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 19,
                                      ),
                                      const SizedBox(width: 7),
                                      Text(
                                        _isEditMode ? 'Update' : 'Save',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: darkText,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFAAA19A), fontSize: 13),
      prefixIcon: Icon(icon, color: primaryRed, size: 20),
      filled: true,
      fillColor: const Color(0xFFFFFCF7),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryRed, width: 1.3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryRed, width: 1.3),
      ),
    );
  }
}
