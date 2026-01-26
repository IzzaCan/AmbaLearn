import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../config/theme_config.dart';
import '../providers/user_provider.dart';
import '../providers/auth_provider.dart';

class OnboardingBirthdayPage extends StatefulWidget {
  const OnboardingBirthdayPage({super.key});

  @override
  State<OnboardingBirthdayPage> createState() => _OnboardingBirthdayPageState();
}

class _OnboardingBirthdayPageState extends State<OnboardingBirthdayPage> {
  DateTime? _selectedDate;
  final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit(BuildContext context) async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Tanggal lahir wajib diisi',
          ), // Keep ID for now as requested
          backgroundColor: context.errorColor,
        ),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final authProvider = context.read<AuthProvider>();

    final res = await userProvider.updateUser(
      birthday: _formatter.format(_selectedDate!),
    );

    if (!mounted) return;

    if (res != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res), backgroundColor: context.errorColor),
      );
      return;
    }

    // Refresh current user
    await authProvider.fetchCurrentUser();
    // AppEntry will redirect to Home automatically
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: context.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Icon / Illustration
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cake_rounded,
                    size: 60,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 2. Title & Description
              Text(
                'Lengkapi Profil',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Kami membutuhkan tanggal lahir untuk menyesuaikan pengalaman belajar Anda.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // 3. Date Picker Field
              Text(
                'Tanggal Lahir',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _pickDate(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedDate != null
                          ? theme.colorScheme.primary
                          : context.dividerColor,
                      width: _selectedDate != null ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      if (isDark)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: _selectedDate != null
                            ? theme.colorScheme.primary
                            : context.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'Pilih tanggal lahir'
                              : DateFormat('dd MMMM yyyy').format(
                                  _selectedDate!,
                                ),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _selectedDate == null
                                ? context.textSecondary.withOpacity(0.7)
                                : context.textPrimary,
                            fontWeight: _selectedDate != null
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down_rounded,
                        color: context.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // 4. Submit Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  onPressed: userProvider.isLoading
                      ? null
                      : () => _submit(context),
                  child: userProvider.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Lanjutkan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
