// ignore_for_file: discarded_futures, inference_failure_on_instance_creation, inference_failure_on_function_invocation

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// Edit profile page
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({required this.user, super.key});
  final UserEntity user;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _shouldUpdateProfileAfterAvatar = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final profileBloc = context.read<ProfileBloc>();
      final name = _nameController.text.trim();
      final bio = _bioController.text.trim();

      final hasNameOrBioChange = name != widget.user.name || bio != widget.user.bio;
      final hasImageChange = _selectedImage != null;

      // If both avatar and profile need updating, upload avatar first
      // Then update profile in the listener after avatar upload succeeds
      if (hasImageChange && hasNameOrBioChange) {
        _shouldUpdateProfileAfterAvatar = true;
        profileBloc.add(
          UploadAvatar(userId: widget.user.id, imageFile: _selectedImage!),
        );
      } else if (hasImageChange) {
        // Only avatar needs updating
        _shouldUpdateProfileAfterAvatar = false;
        profileBloc.add(
          UploadAvatar(
            userId: widget.user.id,
            imageFile: _selectedImage!,
          ),
        );
      } else if (hasNameOrBioChange) {
        // Only profile info needs updating
        _shouldUpdateProfileAfterAvatar = false;
        profileBloc.add(
          UpdateProfile(
            userId: widget.user.id,
            name: name.isNotEmpty ? name : null,
            bio: bio.isNotEmpty ? bio : null,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is AvatarUploadSuccess && _shouldUpdateProfileAfterAvatar) {
          // Avatar uploaded successfully, now update profile info
          _shouldUpdateProfileAfterAvatar = false;
          final name = _nameController.text.trim();
          final bio = _bioController.text.trim();

          context.read<ProfileBloc>().add(
            UpdateProfile(
              userId: widget.user.id,
              name: name.isNotEmpty ? name : null,
              bio: bio.isNotEmpty ? bio : null,
            ),
          );
        } else if (state is ProfileUpdateSuccess ||
            (state is AvatarUploadSuccess && !_shouldUpdateProfileAfterAvatar)) {
          // Update AuthBloc with new user data
          final updatedUser = state is ProfileUpdateSuccess
              ? state.user
              : (state as AvatarUploadSuccess).user;
          context.read<AuthBloc>().add(UserProfileUpdated(updatedUser));

          // All operations completed successfully
          Navigator.of(context).pop();
        } else if (state is ProfileError) {
          _shouldUpdateProfileAfterAvatar = false; // Reset on error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          actions: [
            BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                final isUpdating = state is ProfileUpdating || state is AvatarUploading;
                return TextButton(
                  onPressed: isUpdating ? null : _handleSave,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: isUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save'),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            final isUpdating = state is ProfileUpdating || state is AvatarUploading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar picker
                  GestureDetector(
                    onTap: isUpdating ? null : _showImageSourceDialog,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (widget.user.avatarUrl != null &&
                                    widget.user.avatarUrl!.isNotEmpty)
                              ? NetworkImage(widget.user.avatarUrl!)
                                    as ImageProvider
                              : null,
                          child:
                              _selectedImage == null &&
                                  (widget.user.avatarUrl == null ||
                                      widget.user.avatarUrl!.isEmpty)
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey[600],
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to change avatar',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Enter your name',
                      prefixIcon: Icon(Icons.person_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                    enabled: !isUpdating,
                  ),
                  const SizedBox(height: 16),

                  // Bio field
                  TextFormField(
                    controller: _bioController,
                    maxLines: 4,
                    maxLength: 200,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell us about yourself...',
                      prefixIcon: Icon(Icons.info_outlined),
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    enabled: !isUpdating,
                  ),
                  const SizedBox(height: 16),

                  // Email (read-only)
                  TextFormField(
                    initialValue: widget.user.email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                      enabled: false,
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email cannot be changed',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}}
