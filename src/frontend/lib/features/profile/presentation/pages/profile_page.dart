import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import 'edit_profile_page.dart';

/// Profile page showing user information
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const Scaffold(
            body: Center(
              child: Text('Please log in to view profile'),
            ),
          );
        }

        final userId = authState.user.id;

        return BlocProvider(
          create: (context) => context.read<ProfileBloc>()
            ..add(LoadProfile(userId)),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Profile'),
              actions: [
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    if (state is ProfileLoaded ||
                        state is ProfileUpdateSuccess ||
                        state is AvatarUploadSuccess) {
                      return IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          final user = state is ProfileLoaded
                              ? state.user
                              : state is ProfileUpdateSuccess
                                  ? state.user
                                  : (state as AvatarUploadSuccess).user;

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (newContext) => BlocProvider.value(
                                value: context.read<ProfileBloc>(),
                                child: EditProfilePage(user: user),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
            body: BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is ProfileUpdateSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is AvatarUploadSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Avatar updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is ProfileLoaded ||
                    state is ProfileUpdateSuccess ||
                    state is AvatarUploadSuccess ||
                    state is ProfileUpdating ||
                    state is AvatarUploading) {
                  final user = state is ProfileLoaded
                      ? state.user
                      : state is ProfileUpdateSuccess
                          ? state.user
                          : state is AvatarUploadSuccess
                              ? state.user
                              : state is ProfileUpdating
                                  ? state.currentUser
                                  : (state as AvatarUploading).currentUser;

                  final isUpdating = state is ProfileUpdating || state is AvatarUploading;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 32),

                        // Avatar
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    )
                                  : null,
                            ),
                            if (isUpdating)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Name
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),

                        // User Type Badge
                        _buildUserTypeBadge(context, user.userType),
                        const SizedBox(height: 16),

                        // Email
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  user.email,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Bio
                        if (user.bio != null && user.bio!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user.bio!,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),

                        // Edit Profile Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ElevatedButton.icon(
                            onPressed: isUpdating
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (newContext) => BlocProvider.value(
                                          value: context.read<ProfileBloc>(),
                                          child: EditProfilePage(user: user),
                                        ),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Profile'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Sign Out Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: OutlinedButton.icon(
                            onPressed: isUpdating
                                ? null
                                : () {
                                    _showSignOutDialog(context);
                                  },
                            icon: const Icon(Icons.logout),
                            label: const Text('Sign Out'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                }

                return const Center(
                  child: Text('Unable to load profile'),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserTypeBadge(BuildContext context, UserType userType) {
    final isTrainer = userType == UserType.trainer;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isTrainer
            ? (isDarkMode ? Colors.blue[900]!.withOpacity(0.3) : Colors.blue[100])
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isTrainer ? Icons.fitness_center : Icons.person,
            size: 16,
            color: isTrainer
                ? (isDarkMode ? Colors.blue[300] : Colors.blue[700])
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          const SizedBox(width: 4),
          Text(
            isTrainer ? 'Trainer' : 'User',
            style: TextStyle(
              color: isTrainer
                  ? (isDarkMode ? Colors.blue[300] : Colors.blue[700])
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const SignOutRequested());
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
