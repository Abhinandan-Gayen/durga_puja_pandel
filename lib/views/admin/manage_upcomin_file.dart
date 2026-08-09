import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../controllers/event_controller.dart';
import '../../../models/event_model.dart';

class ManageUpcomingFilePage extends StatelessWidget {
  const ManageUpcomingFilePage({super.key});

  static const Color primaryRed = Color(0xFFB91419);
  static const Color bgColor = Color(0xFFFFF8ED);
  static const Color borderColor = Color(0xFFEBDCC7);
  static const Color darkText = Color(0xFF302B28);
  static const Color secondaryText = Color(0xFF7A7069);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        title: const Text(
          'Upcoming Events',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<EventController>(
        builder: (context, controller, _) {
          if (controller.isLoading && controller.events.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              itemBuilder: (_, __) => _ShimmerCard(),
            );
          }

          if (controller.events.isEmpty) {
            return const Center(
              child: Text(
                'No events found.',
                style: TextStyle(color: secondaryText, fontSize: 14),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.events.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final event = controller.events[index];
              return _EventCard(
                event: event,
                onEdit: () => _showEditSheet(context, controller, event),
                onDelete: () => _confirmDelete(context, controller, event),
              );
            },
          );
        },
      ),
    );
  }

  // ── Edit bottom sheet ─────────────────────────────────────────────────────
  void _showEditSheet(
    BuildContext context,
    EventController controller,
    EventModel event,
  ) {
    final formKey = GlobalKey<FormState>();
    final monthCtrl = TextEditingController(text: event.month);
    final dateCtrl = TextEditingController(text: event.date);
    final titleCtrl = TextEditingController(text: event.title);
    final subtitleCtrl = TextEditingController(text: event.subtitle);
    final timeCtrl = TextEditingController(text: event.time);
    bool notif = event.notification;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6D2CF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Header
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: primaryRed.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.edit_calendar_outlined,
                                color: primaryRed,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Edit Event',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: darkText,
                                  ),
                                ),
                                Text(
                                  'Update the event details',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Month & Date row
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                controller: monthCtrl,
                                label: 'Month (e.g. SEP)',
                                icon: Icons.calendar_month,
                                caps: TextCapitalization.characters,
                                required: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _field(
                                controller: dateCtrl,
                                label: 'Date (e.g. 28)',
                                icon: Icons.numbers,
                                keyboardType: TextInputType.number,
                                required: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _field(
                          controller: titleCtrl,
                          label: 'Event Title',
                          icon: Icons.title,
                          required: true,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          controller: subtitleCtrl,
                          label: 'Subtitle',
                          icon: Icons.subtitles,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          controller: timeCtrl,
                          label: 'Time (e.g. 7:00 AM Onwards)',
                          icon: Icons.access_time_filled_rounded,
                        ),
                        const SizedBox(height: 12),
                        // Notification toggle
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
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFE9EA),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: primaryRed,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Notification',
                                  style: TextStyle(
                                    color: darkText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Switch(
                                value: notif,
                                activeColor: primaryRed,
                                onChanged: (v) =>
                                    setSheetState(() => notif = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Save button
                        ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            Navigator.pop(ctx);
                            final ok = await controller.updateEvent(
                              id: event.id,
                              month: monthCtrl.text,
                              date: dateCtrl.text,
                              title: titleCtrl.text,
                              subtitle: subtitleCtrl.text,
                              time: timeCtrl.text,
                              notification: notif,
                            );
                            Get.snackbar(
                              ok ? 'Updated' : 'Error',
                              ok
                                  ? 'Event updated successfully!'
                                  : controller.errorMessage ?? 'Failed',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: ok
                                  ? const Color(0xFF2E7D32)
                                  : primaryRed,
                              colorText: Colors.white,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Delete confirmation ───────────────────────────────────────────────────
  void _confirmDelete(
    BuildContext context,
    EventController controller,
    EventModel event,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Delete Event',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${event.title}"?\nThis cannot be undone.',
          style: const TextStyle(color: secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: secondaryText)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await controller.deleteEvent(event.id);
              Get.snackbar(
                ok ? 'Deleted' : 'Error',
                ok
                    ? 'Event deleted successfully!'
                    : controller.errorMessage ?? 'Failed',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: ok ? const Color(0xFF2E7D32) : primaryRed,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── Text field helper ─────────────────────────────────────────────────────
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization caps = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: caps,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryRed, size: 20),
        filled: true,
        fillColor: const Color(0xFFFFFCF7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
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
      ),
      validator: required
          ? (v) => v == null || v.trim().isEmpty ? 'Required' : null
          : null,
    );
  }
}

// ── Event card ──────────────────────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  final EventModel event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const Color primaryRed = Color(0xFFB91419);
  static const Color borderColor = Color(0xFFEBDCC7);
  static const Color darkText = Color(0xFF302B28);
  static const Color secondaryText = Color(0xFF7A7069);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date box
          Container(
            width: 52,
            height: 60,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 20,
                  color: primaryRed,
                  alignment: Alignment.center,
                  child: Text(
                    event.month,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      event.date,
                      style: const TextStyle(
                        color: primaryRed,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: darkText,
                  ),
                ),
                if (event.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    event.subtitle,
                    style: const TextStyle(color: secondaryText, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 12, color: primaryRed),
                    const SizedBox(width: 4),
                    Text(
                      event.time,
                      style: const TextStyle(
                        color: secondaryText,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      event.notification
                          ? Icons.notifications_active_outlined
                          : Icons.notifications_off_outlined,
                      size: 13,
                      color: event.notification ? primaryRed : Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFF1565C0),
                  size: 22,
                ),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: primaryRed,
                  size: 22,
                ),
                tooltip: 'Delete',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shimmer placeholder card ─────────────────────────────────────────────────
class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment(_anim.value - 1, 0),
              end: Alignment(_anim.value + 1, 0),
              colors: const [
                Color(0xFFF0E5D3),
                Color(0xFFFAF3E6),
                Color(0xFFF0E5D3),
              ],
            ),
          ),
        );
      },
    );
  }
}
