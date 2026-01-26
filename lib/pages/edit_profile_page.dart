import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme_config.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  DateTime? _selectedDate;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _passwordController = TextEditingController();
    _selectedDate = user?.birthday;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? DateTime(now.year - 18);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    final userProvider = context.read<UserProvider>();
    final authProvider = context.read<AuthProvider>();

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text;
    final String? birthday = _selectedDate != null
        ? _dateFormat.format(_selectedDate!)
        : null;

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Username required"),
          backgroundColor: context.errorColor,
        ),
      );
      return;
    }

    // Call update API
    final error = await userProvider.updateUser(
      username: username,
      birthday: birthday,
      password: password.isNotEmpty ? password : null,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: context.errorColor),
      );
    } else {
      // Success: Refresh user data and pop
      await authProvider.fetchCurrentUser();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Profile updated successfully"),
          backgroundColor: context.successColor,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isDark = context.isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"), // TODO: Add to l10n if needed
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Avatar (Visual Only)
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _usernameController.text.isNotEmpty
                            ? _usernameController.text[0].toUpperCase()
                            : "U",
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.surfaceColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Form Fields
            _buildLabel("Username", context),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline_rounded),
                hintText: "Enter your username",
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel("Date of Birth", context),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.dividerColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: context.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedDate != null
                            ? _dateFormat.format(_selectedDate!)
                            : "Select Date of Birth",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _selectedDate != null
                              ? context.textPrimary
                              : context.textSecondary.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel("New Password (Optional)", context),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                hintText: "Leave empty to keep current",
              ),
            ),
            const SizedBox(height: 40),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: userProvider.isLoading ? null : _saveProfile,
                child: userProvider.isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: context.textSecondary,
      ),
    );
  }
}
