/*
* Student Numbers: 224102916, 224099548, 223095490, 224004511, 224022386, 224097774, 224052285, 224019969, 224008698, 224053964
* Student Names: Ramahlosi PD, Bere AM, Motlhakane M, Modisana MD, Simelane LW, Freeman C, Seitshiro TT, Lewis DC, Molefi MD, Mfuphi L
*/

import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  Map<String, dynamic> _getStatusConfig() {
    switch (status.toLowerCase()) {
      case 'approved':
        return {
          'color': const Color(0xFF4CAF50),
          'icon': Icons.check_circle_outline_rounded,
          'label': 'Approved',
        };
      case 'rejected':
        return {
          'color': const Color(0xFFF44336),
          'icon': Icons.cancel_outlined,
          'label': 'Rejected',
        };
      case 'pending':
      default:
        return {
          'color': const Color(0xFFFF9800),
          'icon': Icons.hourglass_empty_rounded,
          'label': 'Pending',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig();
    final Color color = config['color'];
    final IconData icon = config['icon'];
    final String label = config['label'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color, 
              fontSize: 12, 
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

