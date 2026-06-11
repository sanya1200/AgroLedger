import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';

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

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(Message(text: text, isUser: true, time: DateTime.now()));
      _isTyping = true;
    });
    _controller.clear();
    _scrollToBottom();

    // Simulate AI response
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      String aiResponse = _getPresetResponse(text);
      
      setState(() {
        _messages.add(Message(text: aiResponse, isUser: false, time: DateTime.now()));
        _isTyping = false;
      });
      _scrollToBottom();
    });
  }

  String _getPresetResponse(String query) {
    query = query.toLowerCase();

    if (query.contains('вакцинац') || query.contains('бройлер')) {
      return '📋 **Рекомендуемая схема вакцинации бройлеров:**\n\n'
          '1. **1-3 день**: Вакцинация против болезни Ньюкасла (штамм Ла-Сота) и Инфекционного бронхита кур (ИБК) — методом крупнокапельного спрея.\n'
          '2. **10-12 день**: Вакцинация против Болезни Гамборо (ИББ) — через питьевую воду.\n'
          '3. **16-18 день**: Ревакцинация против болезни Ньюкасла и ИБК — выпаивание.\n'
          '4. **22-24 день**: Ревакцинация против Болезни Гамборо — выпаивание.\n\n'
          '*Важно: За 2 часа до выпаивания вакцины птицу не поят. В воду добавляют сухое молоко (2 г на 1 л) для нейтрализации хлора.*';
    } else if (query.contains('стельн') || query.contains('коров')) {
      return '🌾 **Оптимальный рацион для стельной коровы в сухостойный период (за 60-10 дней до отела):**\n\n'
          '• **Грубые корма**: Сено злаково-бобовое — 6-8 кг в сутки.\n'
          '• **Сочные корма**: Сенаж качественный — 8-10 кг. Ограничьте силос (не более 5 кг) для избежания закисления рубца.\n'
          '• **Концентраты (комбикорм)**: 1.5 - 2.0 кг в день. Избегайте перекорма!\n'
          '• **Минеральные добавки**: Мел, фосфаты, премикс с витаминами A, D, E и селеном.\n\n'
          '*Рекомендация: За 14 дней до отела исключите из рациона сочные корма и соль для профилактики отека вымени.*';
    } else if (query.contains('ящур') || query.contains('овец')) {
      return '⚠️ **Симптомы ящура у овец и коз:**\n\n'
          '1. **Повышение температуры** тела до 41-41.5 °C.\n'
          '2. **Вялость и хромота** (животное часто лежит, неохотно встает, поджимает конечности).\n'
          '3. **Афты (пузырьки) и эрозии** на венчике копыт, в межкопытной щели, а также на слизистой оболочке рта и губах.\n'
          '4. **Обильное слюнотечение** и затрудненное пережевывание корма.\n\n'
          '*Действия при подозрении: Немедленно изолируйте группу животных и вызовите государственного ветеринара. Ящур крайне заразен и передается человеку!*';
    } else if (query.contains('жирност') || query.contains('молок')) {
      return '🥛 **Как повысить жирность молока у коров:**\n\n'
          '1. **Увеличьте долю клетчатки** в рационе. Структурная клетчатка (длинное сено от 3 см) стимулирует жевание и выработку уксусной кислоты в рубце, которая является предшественником молочного жира. Доля сена должна быть не менее 18-20% от СВ.\n'
          '2. **Контролируйте уровень крахмала**. Не перекармливайте зерновыми концентратами (пшеница, ячмень). Максимум 30-35% крахмала в рационе, иначе возникнет субклинический ацидоз, снижающий жирность.\n'
          '3. **Качественная вода**. Корова должна пить до 100-120 литров чистой воды в день.\n'
          '4. **Дрожжевые добавки**. Введение в рацион активных кормовых дрожжей стабилизирует микрофлору рубца и повышает жирность на 0.15 - 0.3%.';
    } else if (query.contains('телен') || query.contains('норм')) {
      return '🍼 **Нормы выпойки и кормления телят (0-3 месяца):**\n\n'
          '• **1-й час жизни**: Обязательно выпойка молозива (10% от веса теленка, около 3-4 литров) для формирования пассивного иммунитета.\n'
          '• **1-10 день**: Цельное молоко 3 раза в день по 2 литра (всего 6 л в сутки).\n'
          '• **С 5-го дня**: Введение в свободный доступ чистой воды и стартерного престартер-комбикорма в гранулах (для развития ворсинок рубца).\n'
          '• **2-й месяц**: Постепенное снижение выпойки молока до 4 л в сутки, приучение к нежному злаковому сену.\n'
          '• **3-й месяц**: Снятие с выпойки при потреблении стартера более 1.5 кг в день.';
    } else {
      return '🤖 Спасибо за вопрос! Я проанализировал ваш запрос по теме: "$query".\n\n'
          'Для точной рекомендации в животноводстве важно соблюдать нормы содержания. Пожалуйста, уточните возраст животного, его живой вес и текущую продуктивность (удой/привес).\n\n'
          'Если у животного острые симптомы (отказ от корма, вялость, температура выше 40.5 °C), рекомендуется немедленный вызов ветеринара для очного осмотра.';
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
