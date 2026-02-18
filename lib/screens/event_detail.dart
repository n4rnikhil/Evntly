import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _calculateTimeLeft());
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    final deadline = widget.event.registrationDeadline;
    setState(() {
      _timeLeft = deadline.isAfter(now) ? deadline.difference(now) : Duration.zero;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    if (d == Duration.zero) return "Closed";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${d.inDays}d ${twoDigits(d.inHours.remainder(24))}h ${twoDigits(d.inMinutes.remainder(60))}m ${twoDigits(d.inSeconds.remainder(60))}s";
  }

  void _shareEvent(BuildContext context) {
    Share.share('Check out ${widget.event.title} on Evntly!\n\n${widget.event.description}');
  }

  void _toggleSave(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event saved to your profile!')));
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not launch registration link')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'event_image_${widget.event.id}',
                child: CachedNetworkImage(
                  imageUrl: widget.event.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () => _shareEvent(context),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_border_rounded),
                onPressed: () => _toggleSave(context, ref),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                        ),
                        child: Text(
                          widget.event.category,
                          style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'Posted by ${widget.event.organizerName ?? 'Admin'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.event.title,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildInfoRow(Icons.calendar_today, 'Date', DateFormat('EEEE, MMM dd, yyyy').format(widget.event.date)),
                  _buildInfoRow(Icons.access_time, 'Time', DateFormat('hh:mm a').format(widget.event.date)),
                  _buildInfoRow(Icons.location_on_outlined, 'Location', widget.event.location),
                  _buildInfoRow(
                    Icons.timer_outlined, 
                    'Deadline', 
                    _formatDuration(_timeLeft),
                    textColor: _timeLeft.inHours < 24 ? AppColors.deadlineRed : AppColors.textPrimary
                  ),
                  
                  const SizedBox(height: 32),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.event.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.background.withOpacity(0.8),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: ElevatedButton(
          onPressed: () => _launchUrl(widget.event.registrationLink),
          child: const Text('Register Now'),
        ),
      ).animate().slideY(begin: 1, end: 0, duration: 600.ms),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppColors.accent),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                value, 
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14, 
                  fontWeight: FontWeight.bold,
                  color: textColor ?? AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
