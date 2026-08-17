// lib/features/calls/presentation/widgets/call_list_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Edvance/core/routing/app_routing.dart';
import 'package:Edvance/features/chat/data/model/call_model.dart';
import 'package:Edvance/features/chat/data/provider/active_call_provider.dart';

// ✅ CHANGE 1: Extend ConsumerWidget instead of StatelessWidget
class CallListItem extends ConsumerWidget {
  final CallModel call;
  final VoidCallback onCallBack;

  const CallListItem({super.key, required this.call, required this.onCallBack});

  // ✅ CHANGE 2: ConsumerWidget's build method correctly accepts (context, ref)
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(25)),
            child: call.contactAvatar != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(25),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  call.contactName + (call.callCount > 1 ? ' (${call.callCount})' : ''),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: call.isMissed ? Colors.red : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(call.directionIcon, size: 14, color: call.isMissed ? Colors.red : Colors.green),
                    const SizedBox(width: 4),
                    Text(call.formattedTime, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              // Start the call using existing CallModel
              ref.read(activeCallProvider.notifier).startCall(call);

              // Navigate to appropriate screen
              if (call.callType == CallType.video) {
                context.push(Routes.videoCall);
              } else {
                context.push(Routes.audioCall);
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
              child: Icon(
                call.callType == CallType.video ? Icons.videocam : Icons.call,
                color: Colors.black87,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
