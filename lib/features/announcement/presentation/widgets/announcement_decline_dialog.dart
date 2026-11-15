import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:masic_generation/core/extensions/app_extension.dart';
import 'package:masic_generation/features/announcement/presentation/controllers/announcement_controller.dart';

class AnnouncementDeclineDialog extends StatefulWidget {
  const AnnouncementDeclineDialog({
    super.key,
    required this.announcementId,
    required this.controller,
  });

  final String announcementId;
  final AnnouncementController controller;

  @override
  State<AnnouncementDeclineDialog> createState() =>
      _AnnouncementDeclineDialogState();
}

class _AnnouncementDeclineDialogState extends State<AnnouncementDeclineDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = widget.controller.updateLoadingState.isLoading;
      return PopScope(
        canPop: !isLoading,
        child: AlertDialog(
          title: const Text('Decline announcement'),
          content: SingleChildScrollView(
            child: TextField(
              controller: _reasonController,
              enabled: !isLoading,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'Explain why this announcement was declined',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => widget.controller.updateStatus(
                      widget.announcementId,
                      'declined',
                      declineReason: _reasonController.text,
                    ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Decline'),
            ),
          ],
        ),
      );
    });
  }
}
