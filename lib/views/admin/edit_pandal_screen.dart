import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/admin_pandal_controller.dart';
import '../../models/pandal_model.dart';
import '../widgets/empty_widget.dart';
import '../widgets/loading_widget.dart';
import 'add_pandal_screen.dart';

class EditPandalScreen extends StatefulWidget {
  const EditPandalScreen({super.key, required this.pandalId, this.isSlider = false});

  final String pandalId;
  final bool isSlider;

  @override
  State<EditPandalScreen> createState() => _EditPandalScreenState();
}

class _EditPandalScreenState extends State<EditPandalScreen> {
  bool _hasRequestedData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasRequestedData) return;
    _hasRequestedData = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final admin = context.read<AdminPandalController>();
      if (widget.isSlider) {
        if (admin.adminSliders.isEmpty) {
          admin.fetchAllSliderPandals();
        }
      } else {
        if (admin.adminPandals.isEmpty) {
          admin.fetchAllPandalsForAdmin();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminPandalController>(
      builder: (context, admin, _) {
        final pandal = widget.isSlider ? _findPandal(admin.adminSliders) : _findPandal(admin.adminPandals);
        if (pandal != null) {
          return PandalFormScreen(initialPandal: pandal, isSlider: widget.isSlider);
        }
        if (admin.isLoading) {
          return const Scaffold(
            body: LoadingWidget(message: 'Loading pandal details'),
          );
        }
        return const Scaffold(
          body: EmptyWidget(
            title: 'Pandal not found',
            message: 'This pandal cannot be edited because it is not loaded.',
          ),
        );
      },
    );
  }

  PandalModel? _findPandal(List<PandalModel> pandals) {
    for (final pandal in pandals) {
      if (pandal.id == widget.pandalId) {
        return pandal;
      }
    }
    return null;
  }
}
