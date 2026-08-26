import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';

/// Permanent Account Deletion Workflow (§44, §84).
class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _passwordController = TextEditingController();
  bool _confirmChecked = false;
  bool _isDeleting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete() async {
    if (!_confirmChecked) {
      AppSnackbar.show(
        context,
        message: 'Please confirm that you understand this action is permanent.',
        variant: SnackbarVariant.warning,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Account Permanently?'),
        content: const Text(
          'This action cannot be undone. All your saved recipes, meal plans, pantry items, and preferences will be permanently wiped.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isDeleting = true;
      });

      HapticFeedback.heavyImpact();
      final authCubit = context.read<AuthCubit>();
      final success = await authCubit.deleteAccount(
        password: _passwordController.text.trim().isNotEmpty
            ? _passwordController.text.trim()
            : null,
      );

      if (mounted) {
        setState(() {
          _isDeleting = false;
        });

        if (success) {
          AppSnackbar.show(
            context,
            message: 'Your account and data have been permanently deleted.',
            variant: SnackbarVariant.info,
          );
          context.go(AppRoutes.login);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Warning Icon Avatar
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 38,
                      color: scheme.error,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                'Are you sure you want to delete your account?',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              Text(
                'Deleting your account will permanently remove:\n'
                '• Your profile and personal settings\n'
                '• All saved favorite recipes & custom notes\n'
                '• Weekly meal planner schedules\n'
                '• Pantry inventory & shopping lists\n'
                '• Cooking streaks and meal history',
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Password Re-authentication Field (if required)
              AppTextField(
                label: 'Confirm Password (if applicable)',
                controller: _passwordController,
                obscureText: true,
                prefixIcon: Icons.lock_outline_rounded,
              ),
              const SizedBox(height: AppSpacing.md),

              // Confirmation Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _confirmChecked,
                    activeColor: scheme.error,
                    onChanged: (val) {
                      setState(() {
                        _confirmChecked = val ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'I understand that this action is irreversible and all my data will be deleted immediately.',
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Permanent Delete Button
              AppButton(
                label: 'Permanently Delete Account',
                backgroundColor: scheme.error,
                foregroundColor: Colors.white,
                isLoading: _isDeleting,
                onPressed: _handleDelete,
              ),
              const SizedBox(height: AppSpacing.md),

              // Cancel Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => context.pop(),
                child: const Text(
                  'Keep My Account',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
