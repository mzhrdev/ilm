import 'package:flutter/material.dart';
import 'package:lms/features/call/data/model/call_model.dart';

class CallListItem extends StatelessWidget {
  final CallModel call;
  final VoidCallback onCallBack;

  const CallListItem({super.key, required this.call, required this.onCallBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
            child: call.contactAvatar != null
                ? ClipOval(
                    child: Image.network(
                      call.contactAvatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, color: Colors.grey, size: 30);
                      },
                    ),
                  )
                : const Icon(Icons.person, color: Colors.grey, size: 30),
          ),
          const SizedBox(width: 12),
          // Call Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        call.contactName + (call.callCount > 1 ? ' (${call.callCount})' : ''),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: call.isMissed ? Colors.red : Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(call.directionIcon, size: 14, color: call.isMissed ? Colors.red : Colors.green),
                    const SizedBox(width: 4),
                    Text(call.formattedTime, style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                  ],
                ),
              ],
            ),
          ),
          // Call Icon
          IconButton(
            icon: Icon(
              call.callType == CallType.video ? Icons.videocam : Icons.call,
              color: Colors.white,
              size: 24,
            ),
            onPressed: onCallBack,
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}
