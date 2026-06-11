import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:agroledger/features/chat/presentation/bloc/chat_event.dart';
import 'package:agroledger/features/chat/presentation/bloc/chat_state.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/features/chat/presentation/pages/chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadRoomsRequested());
    context.read<ChatBloc>().add(ConnectWebSocketRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сообщения'),
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.sagePrimary));
          } else if (state is ChatRoomsLoaded) {
            if (state.rooms.isEmpty) {
              return const Center(
                child: Text('У вас пока нет сообщений'),
              );
            }
            return ListView.builder(
              itemCount: state.rooms.length,
              itemBuilder: (context, index) {
                final room = state.rooms[index];
                // Display partner name depending on who we are. 
                // We don't have the current user here, but we can display the product name and partner id for now.
                final title = room.buyer != null ? 'Чат по товару #${room.productId}' : 'Чат';
                final subtitle = room.messages.isNotEmpty ? room.messages.last.text : 'Нет сообщений';
                
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.sagePrimary,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(roomId: room.id, title: title),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is ChatFailure) {
            return Center(child: Text('Ошибка: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
