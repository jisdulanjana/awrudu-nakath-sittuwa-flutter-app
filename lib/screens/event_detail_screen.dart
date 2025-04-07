import 'dart:async';
import 'package:flutter/material.dart';
import '../models/nakath_event.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatefulWidget {
  final NakathEvent event;
  
  const EventDetailScreen({super.key, required this.event});
  
  @override
  State createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Duration _remaining;
  Timer? _timer;
  bool _hasNotificationEnabled = false;
  
  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }
  
  void _updateCountdown() {
    final now = DateTime.now();
    final diff = widget.event.dateTime.difference(now);
    setState(() {
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy MMMM d');
    final timeFormat = DateFormat('h:mm a');
    final isEventPassed = DateTime.now().isAfter(widget.event.dateTime);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Fancy app bar with event title
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.deepOrange.shade700,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.event.title,
                style: GoogleFonts.notoSansSinhala(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/event_background.jpg',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.deepOrange.shade900.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  _shareEvent();
                },
              ),
            ],
          ),
          
          // Event details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and time card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              color: Colors.deepOrange.shade700,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateFormat.format(widget.event.dateTime),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  timeFormat.format(widget.event.dateTime),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isEventPassed)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'අවසන්',
                                style: GoogleFonts.notoSansSinhala(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'පැමිණෙමින්',
                                style: GoogleFonts.notoSansSinhala(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  // Event description
                  Text(
                    'විස්තරය',
                    style: GoogleFonts.notoSansSinhala(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.orange.shade200,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.event.description,
                      style: GoogleFonts.notoSansSinhala(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms, duration: 300.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  // Countdown section
                  if (!isEventPassed) ...[
                    Text(
                      'කාල ගණනය',
                      style: GoogleFonts.notoSansSinhala(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailedCountdown(),
                  ] else
                    Center(
                      child: Column(
                        children: [
                          Lottie.asset(
                            'assets/animations/completed.json',
                            width: 150,
                            height: 150,
                          ),
                          Text(
                            'මෙම නැකත අවසන් වී ඇත',
                            style: GoogleFonts.notoSansSinhala(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                  
                  const SizedBox(height: 32),
                  
                  // Reminder button
                  if (!isEventPassed)
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasNotificationEnabled 
                            ? Colors.grey.shade300
                            : Colors.deepOrange.shade600,
                          foregroundColor: _hasNotificationEnabled 
                            ? Colors.grey.shade700
                            : Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24, 
                            vertical: 12
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: Icon(
                          _hasNotificationEnabled 
                              ? Icons.notifications_off
                              : Icons.notifications_active,
                        ),
                        label: Text(
                          _hasNotificationEnabled 
                              ? 'මතක් කිරීම අවලංගු කරන්න'
                              : 'මට මතක් කරන්න',
                          style: GoogleFonts.notoSansSinhala(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _hasNotificationEnabled = !_hasNotificationEnabled;
                          });
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _hasNotificationEnabled 
                                    ? 'මතක් කිරීම සක්‍රීය කරන ලදී'
                                    : 'මතක් කිරීම අක්‍රීය කර ඇත',
                                style: GoogleFonts.notoSansSinhala(),
                              ),
                              backgroundColor: _hasNotificationEnabled 
                                  ? Colors.green.shade700
                                  : Colors.grey.shade700,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailedCountdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepOrange.shade50,
            Colors.amber.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade200.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCountdownUnit(_remaining.inDays, 'දින'),
              const SizedBox(width: 12),
              _buildCountdownUnit(_remaining.inHours.remainder(24), 'පැය'),
              const SizedBox(width: 12),
              _buildCountdownUnit(_remaining.inMinutes.remainder(60), 'මිනිත්තු'),
              const SizedBox(width: 12),
              _buildCountdownUnit(_remaining.inSeconds.remainder(60), 'තත්පර'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }
  
  Widget _buildCountdownUnit(int value, String label) {
    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.shade200.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange.shade700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.notoSansSinhala(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
  
  void _shareEvent() {
    final dateFormat = DateFormat('yyyy MMMM d');
    final timeFormat = DateFormat('h:mm a');
    
    final message = 
        '${widget.event.title}\n'
        '${dateFormat.format(widget.event.dateTime)} ${timeFormat.format(widget.event.dateTime)}\n\n'
        '${widget.event.description}\n\n'
        'අලුත් අවුරුදු නැකත් යෙදුම භාවිතා කර තවත් විස්තර ලබා ගන්න.';
    
    Share.share(message);
  }
}