import 'package:flutter/material.dart';

class AddFestivalScreen extends StatefulWidget {
  const AddFestivalScreen({super.key});

  @override
  State<AddFestivalScreen> createState() => _AddFestivalScreenState();
}

class _AddFestivalScreenState extends State<AddFestivalScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController subtitleController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 7, minute: 0);

  bool notificationEnabled = true;

  static const Color primaryRed = Color(0xFFE50914);
  static const Color bgColor = Color(0xFFFFF8ED);
  static const Color borderColor = Color(0xFFEBDCC7);
  static const Color darkText = Color(0xFF302B28);
  static const Color secondaryText = Color(0xFF7A7069);

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

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  String get monthName {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    return months[selectedDate.month - 1];
  }

  void _saveData() {
    if (!_formKey.currentState!.validate()) return;

    debugPrint('Title: ${titleController.text}');
    debugPrint('Subtitle: ${subtitleController.text}');
    debugPrint('Date: $selectedDate');
    debugPrint('Time: ${selectedTime.format(context)}');
    debugPrint('Notification: $notificationEnabled');

    Navigator.pop(context);
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
        title: const Text(
          'Add Festival',
          style: TextStyle(
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
                              const Text(
                                'Festival Details',
                                style: TextStyle(
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
                                    horizontal: 14,
                                  ),
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
                                    horizontal: 14,
                                  ),
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

                        // ============================
                        // BUTTONS
                        // ============================
                        Row(
                          children: [
                            // CANCEL
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: primaryRed,
                                    side: const BorderSide(
                                      color: primaryRed,
                                      width: 1.3,
                                    ),
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

                            // SAVE
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
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 19,
                                      ),
                                      SizedBox(width: 7),
                                      Text(
                                        'Save',
                                        style: TextStyle(
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

  // =========================================================
  // PREVIEW
  // =========================================================
  Widget _buildPreviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // DATE BOX
          Container(
            width: 58,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFFE8D8C4)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: primaryRed,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    monthName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      selectedDate.day.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        color: primaryRed,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleController.text.trim().isEmpty
                      ? 'Maha Saptami'
                      : titleController.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitleController.text.trim().isEmpty
                      ? 'Puja & Pushpanjali'
                      : subtitleController.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: primaryRed,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${selectedTime.format(context)} Onwards',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Icon(
            notificationEnabled
                ? Icons.notifications_none_rounded
                : Icons.notifications_off_outlined,
            color: notificationEnabled ? primaryRed : Colors.grey,
            size: 25,
          ),
        ],
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
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
