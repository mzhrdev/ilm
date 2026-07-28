import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/chat/data/provider/call_provider.dart';
import 'package:lms/features/chat/data/provider/chat_provider.dart';
import 'package:lms/features/chat/presentation/widget/call_list_item.dart';
import 'package:lms/features/chat/presentation/widget/chat_list_item.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<ChatScreen> {
  final _searchController = TextEditingController();
  String _selectedTab = 'Chat'; // 'Chat' or 'Calls'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(messagesProvider);
    final callsState = ref.watch(callsProvider);
    final messages = messagesState.filteredMessages;
    final calls = callsState.filteredCalls;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => context.go(Routes.home),
        ),
        title: const Text(
          'Inbox',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Here',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                if (_selectedTab == 'Chat') {
                  ref.read(messagesProvider.notifier).setSearchQuery(value);
                } else {
                  ref.read(callsProvider.notifier).setSearchQuery(value);
                }
              },
            ),
          ),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 44,
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = 'Chat';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedTab == 'Chat' ? Colors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Chat',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == 'Chat' ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = 'Calls';
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedTab == 'Calls' ? Colors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Calls',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == 'Calls' ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Content based on selected tab
          Expanded(
            child: _selectedTab == 'Chat'
                ? _buildChatList(messagesState, messages)
                : _buildCallsList(callsState, calls),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildChatList(messagesState, messages) {
    return messagesState.isLoading
        ? const Center(child: CircularProgressIndicator())
        : messages.isEmpty
        ? _buildEmptyState('No messages yet', 'When you receive messages, they will appear here')
        : ListView.separated(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: messages.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final message = messages[index];
              return ChatListItem(
                message: message,
                onTap: () {
                  ref.read(messagesProvider.notifier).markAsRead(message.id);
                  context.push('${Routes.conversation}?name=${Uri.encodeComponent(message.senderName)}');
                },
              );
            },
          );
  }

  Widget _buildCallsList(callsState, calls) {
    return callsState.isLoading
        ? const Center(child: CircularProgressIndicator())
        : calls.isEmpty
        ? _buildEmptyState('No recent calls', 'Calls you make or receive will appear here')
        : ListView.separated(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: calls.length,
            separatorBuilder: (context, index) => Divider(color: Colors.grey[200], height: 1),
            itemBuilder: (context, index) {
              final call = calls[index];
              return CallListItem(
                call: call,
                onCallBack: () {
                  // Initiate callback
                },
              );
            },
          );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedTab == 'Chat' ? Icons.chat_bubble_outline : Icons.call_end,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2, // Messages is active
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          activeIcon: Icon(Icons.school),
          label: 'Courses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            context.go(Routes.home);
            break;
          case 1:
            context.go(Routes.course);
            break;
          case 2:
            // Already on messages
            break;
          case 3:
            context.go(Routes.profile);
            break;
        }
      },
    );
  }
}
