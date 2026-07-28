import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/call/data/provider/call_provider.dart';
import '../widgets/call_list_item.dart';

class CallsScreen extends ConsumerStatefulWidget {
  const CallsScreen({super.key});

  @override
  ConsumerState<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends ConsumerState<CallsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callsState = ref.watch(callsProvider);
    final calls = callsState.filteredCalls;

    return Scaffold(
      backgroundColor: const Color(0xFF1B262C), // WhatsApp dark background
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B262C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Calls',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // More options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Recent Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[300]),
              ),
            ),
          ),

          // Calls List
          Expanded(
            child: callsState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : calls.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: calls.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: Colors.white.withOpacity(0.1), height: 1),
                    itemBuilder: (context, index) {
                      final call = calls[index];
                      return CallListItem(
                        call: call,
                        onCallBack: () {
                          // Initiate callback
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // New call
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.call, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.call_end, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 16),
          const Text(
            'No recent calls',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Calls you make or receive will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3, // Calls is active
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF1B262C),
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: 'Chats',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.update), activeIcon: Icon(Icons.update), label: 'Updates'),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Communities',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.phone_outlined),
          activeIcon: Icon(Icons.phone),
          label: 'Calls',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            context.go(Routes.chat);
            break;
          case 1:
            // Updates
            break;
          case 2:
            // Communities
            break;
          case 3:
            // Already on calls
            break;
        }
      },
    );
  }
}
