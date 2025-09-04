import 'package:flutter/material.dart';
import '../models/request_model.dart'; // Sesuaikan path jika perlu

class StatusChip extends StatelessWidget {
  final RequestStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    String label;

    switch (status) {
      case RequestStatus.Approved:
        chipColor = Colors.green.shade100;
        label = 'Disetujui';
        break;
      case RequestStatus.Rejected:
        chipColor = Colors.red.shade100;
        label = 'Ditolak';
        break;
      case RequestStatus.Pending:
      chipColor = Colors.orange.shade100;
        label = 'Pending';
        break;
    }

    return Chip(
      label: Text(label),
      backgroundColor: chipColor,
      labelStyle: TextStyle(
        color: HSLColor.fromColor(chipColor).withLightness(0.2).toColor(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
