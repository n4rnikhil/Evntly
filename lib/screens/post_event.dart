import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/event.dart';
import '../providers/auth_provider.dart';
import '../providers/events_provider.dart';
import '../theme.dart';
import '../providers/navigation_provider.dart';

class PostEventScreen extends ConsumerStatefulWidget {
  const PostEventScreen({super.key});

  @override
  ConsumerState<PostEventScreen> createState() => _PostEventScreenState();
}

class _PostEventScreenState extends ConsumerState<PostEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _linkController = TextEditingController();
  
  String _selectedCategory = 'Hackathons';
  File? _image;
  bool _isLoading = false;
  
  DateTime _eventDate = DateTime.now().add(const Duration(days: 7));
  DateTime _deadline = DateTime.now().add(const Duration(days: 5));

  Future<void> _pickDate(bool isEventDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isEventDate ? _eventDate : _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            onPrimary: Colors.white,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(isEventDate ? _eventDate : _deadline),
      );
      if (time != null) {
        setState(() {
          final newDateTime = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
          if (isEventDate) {
            _eventDate = newDateTime;
          } else {
            _deadline = newDateTime;
          }
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(currentUserProvider)!;
      final eventService = ref.read(eventServiceProvider);
      
      // Real upload to Firebase Storage
      String finalImageUrl;
      if (_image != null) {
        finalImageUrl = await eventService.uploadEventImage(_image!);
      } else {
        finalImageUrl = 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?auto=format&fit=crop&q=80&w=800';
      }
      
      final event = Event(
        id: '', 
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        date: _eventDate,
        registrationDeadline: _deadline,
        location: _locationController.text.trim(),
        registrationLink: _linkController.text.trim(),
        imageUrl: finalImageUrl,
        submittedBy: user.uid,
        organizerName: user.name,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await eventService.submitEvent(event);
      
      if (mounted) {
        setState(() => _isLoading = false);
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Success! 🎉'),
            content: const Text('Your event has been submitted and is now in the admin review queue.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  _titleController.clear();
                  _descController.clear();
                  _locationController.clear();
                  _linkController.clear();
                  setState(() => _image = null);
                  ref.read(bottomNavIndexProvider.notifier).state = 0;
                }, 
                child: const Text('Great!'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Event'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.textSecondary.withOpacity(0.2)),
                  ),
                  child: _image != null 
                    ? ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.file(_image!, fit: BoxFit.cover))
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 40, color: AppColors.textSecondary),
                          SizedBox(height: 8),
                          Text('Upload Poster', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Event Title'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(hintText: 'Description'),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: ['Hackathons', 'AI & ML', 'Web Dev', 'Design', 'Other'].map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
                decoration: const InputDecoration(hintText: 'Category'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(hintText: 'Location'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(hintText: 'Registration Link'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              _buildDateTimePicker('Event Date & Time', _eventDate, () => _pickDate(true)),
              const SizedBox(height: 16),
              _buildDateTimePicker('Registration Deadline', _deadline, () => _pickDate(false)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Submit for Review'),
              ),
              const SizedBox(height: 100), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(String label, DateTime value, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${value.day}/${value.month}/${value.year} - ${value.hour}:${value.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.calendar_month_outlined, color: AppColors.accent, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
