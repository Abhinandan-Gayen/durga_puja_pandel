import 'package:durga_puja_pandel/views/admin/upcomingevent.dart';
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
                onEdit: () => _goToEditPage(context, event),
                onDelete: () => _confirmDelete(context, controller, event),
              );
            },
          );
        },
      ),
    );
  }

  // ── Navigate to Edit page ─────────────────────────────────────────────────
  void _goToEditPage(BuildContext context, EventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddFestivalScreen(existingEvent: event),
      ),
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
