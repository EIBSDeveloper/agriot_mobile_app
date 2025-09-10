// widgets/search_bar.dart

import 'package:argiot/src/app/modules/near_me/model/models.dart';
import 'package:argiot/src/core/app_style.dart';
import 'package:flutter/material.dart';

class ManPowerAgentCard extends StatelessWidget {
  final ManPowerAgent agent;
  final VoidCallback onTap;

  const ManPowerAgentCard({
    super.key,
    required this.agent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: AppStyle.decoration,
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      agent.mobileNo.toString(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(agent.taluk, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            if (agent.workersCount > 0)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('(${agent.workersCount} Workers )'),
              ),
          ],
        ),
      ),
    );
}
