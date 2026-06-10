import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:agroledger/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:agroledger/features/home/data/datasources/business_profile_remote_data_source.dart';
import 'package:agroledger/core/di/service_locator.dart';
import 'package:agroledger/core/theme/app_colors.dart';
import 'package:agroledger/core/theme/app_text_styles.dart';
import 'package:agroledger/features/auth/presentation/widgets/animated_input_field.dart';
import 'package:agroledger/core/presentation/widgets/soft_card.dart';

class BusinessSetupScreen extends StatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  State<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends State<BusinessSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _binController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final user = context.read<AuthBloc>().state.user;
    if (user != null && user.hasBusinessProfile) {
      try {
        final dataSource = sl<BusinessProfileRemoteDataSource>();
        final profile = await dataSource.getMyProfile();
        setState(() {
          _nameController.text = profile['name'] ?? '';
          _binController.text = profile['bin_inn'] ?? '';
          _locationController.text = profile['location'] ?? '';
          _descriptionController.text = profile['description'] ?? '';
          _isUpdating = true;
        });
      } catch (e) {
        // Just continue as new if fetch fails
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final dataSource = sl<BusinessProfileRemoteDataSource>();
        final data = {
          'name': _nameController.text.trim(),
          'bin_inn': _binController.text.trim(),
          'location': _locationController.text.trim(),
          'description': _descriptionController.text.trim(),
        };

        if (_isUpdating) {
          await dataSource.updateProfile(data);
        } else {
          await dataSource.createProfile(data);
        }
        
        if (mounted) {
          // Refresh user data
          context.read<AuthBloc>().add(AuthCheckStatusRequested());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isUpdating ? 'Профиль обновлен' : 'Профиль создан'),
              backgroundColor: AppColors.sagePrimary,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: AppColors.errorSoft),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && !_isUpdating) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: AppBar(
        title: Text(_isUpdating ? 'Редактировать профиль' : 'Профиль хозяйства'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              _isUpdating 
                ? 'Обновите информацию о вашем хозяйстве'
                : 'Расскажите о вашем хозяйстве, чтобы начать работу на платформе.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMax.copyWith(color: AppColors.textLight),
            ),
            const SizedBox(height: 32),
            SoftCard(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AnimatedInputField(
                      controller: _nameController,
                      label: 'Название хозяйства',
                      prefixIcon: Icons.business_outlined,
                      validator: (v) => (v == null || v.isEmpty) ? 'Введите название' : null,
                    ),
                    const SizedBox(height: 16),
                    AnimatedInputField(
                      controller: _binController,
                      label: 'БИН / ИИН',
                      prefixIcon: Icons.numbers_outlined,
                      validator: (v) => (v == null || v.isEmpty) ? 'Введите БИН/ИИН' : null,
                    ),
                    const SizedBox(height: 16),
                    AnimatedInputField(
                      controller: _locationController,
                      label: 'Местоположение',
                      prefixIcon: Icons.location_on_outlined,
                      validator: (v) => (v == null || v.isEmpty) ? 'Укажите адрес или регион' : null,
                    ),
                    const SizedBox(height: 16),
                    AnimatedInputField(
                      controller: _descriptionController,
                      label: 'Описание (опционально)',
                      prefixIcon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(_isUpdating ? 'Сохранить изменения' : 'Создать профиль'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
