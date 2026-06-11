import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/core/di/service_locator.dart';
import 'package:agroledger/features/home/data/datasources/ai_remote_data_source.dart';

class Message {
  final String text;
  final bool isUser;
  final DateTime time;

  Message({required this.text, required this.isUser, required this.time});
}

class AIConsultantScreen extends StatefulWidget {
  const AIConsultantScreen({super.key});

  @override
  State<AIConsultantScreen> createState() => _AIConsultantScreenState();
}

class _AIConsultantScreenState extends State<AIConsultantScreen> {
  final List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<String> _quickQuestions = [
    'Схема вакцинации бройлеров',
    'Рацион стельной коровы',
    'Симптомы ящура у овец',
    'Как поднять жирность молока?',
    'Норма корма для теленка',
  ];

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(
      Message(
        text: 'Здравствуйте! Я ваш персональный ИИ-Ветеринар и Агро-Консультант. '
            'Я могу помочь вам с диагностикой симптомов болезней животных, составить оптимальный рацион кормления или подсказать календарь прививок. '
            'Задайте ваш вопрос или выберите одну из тем ниже:',
        isUser: false,
        time: DateTime.now(),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(text: text, isUser: true, time: DateTime.now()));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final aiResponse = await sl<AiRemoteDataSource>().consultAi(text);
      if (!mounted) return;
      
      setState(() {
        _messages.add(Message(text: aiResponse, isUser: false, time: DateTime.now()));
        _isTyping = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(Message(text: 'Извините, произошла ошибка: $e', isUser: false, time: DateTime.now()));
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: const Text('ИИ Ветеринарный Помощник'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  Message(
                    text: 'Привет! Я ИИ-консультант AgroLedger. Задайте мне вопрос по ветеринарии, кормлению или разведению животных.',
                    isUser: false,
                    time: DateTime.now(),
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat Area
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return _buildTypingIndicator();
                  }

                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),

            // Quick Questions (only visible if chat is short)
            if (_messages.length <= 2)
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _quickQuestions.length,
                  itemBuilder: (context, index) {
                    final question = _quickQuestions[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                      child: ActionChip(
                        label: Text(question, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                        backgroundColor: AppColors.creamSurface,
                        side: BorderSide(color: AppColors.sageLight.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        onPressed: () => _sendMessage(question),
                      ),
                    );
                  },
                ),
              ),

            // Disclaimer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Внимание: Ответы ИИ носят справочный характер и не заменяют профессиональную ветеринарную помощь.',
                style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.errorSoft),
                textAlign: TextAlign.center,
              ),
            ),

            // Input Bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.creamSurface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: AppColors.sageLight.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Задать вопрос ветеринару...',
                          border: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(_controller.text),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: AppColors.sagePrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final format = DateFormat('HH:mm');
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? AppColors.creamSurface
                    : AppColors.sagePrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 20),
                ),
                border: message.isUser 
                    ? Border.all(color: AppColors.sageLight.withValues(alpha: 0.2), width: 1)
                    : null,
              ),
              child: Text(
                message.text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDark,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                format.format(message.time),
                style: AppTextStyles.caption.copyWith(fontSize: 9, color: AppColors.textLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: AppColors.sagePrimary.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Печатает ответы...', style: AppTextStyles.caption.copyWith(color: AppColors.sagePrimary)),
              const SizedBox(width: 8),
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.sagePrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
