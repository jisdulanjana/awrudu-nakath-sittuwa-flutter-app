import 'package:awrudu_nakath_sittuwa_flutter_app/models/nakath_event.dart';
import 'package:awrudu_nakath_sittuwa_flutter_app/screens/event_detail_screen.dart';
import 'package:flutter/material.dart';
import '../data/nakath_data.dart';
import '../widgets/event_card.dart';
import 'dart:async';
import 'package:lottie/lottie.dart'; // For animated illustrations
import 'package:google_fonts/google_fonts.dart'; // For better typography
import 'package:flutter_animate/flutter_animate.dart'; // For smooth animations
import 'package:shimmer/shimmer.dart'; // For loading effects

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  Duration _timeRemaining = Duration.zero;
  late NakathEvent _upcomingEvent;
  late AnimationController _animationController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _findUpcomingEvent();
    _setupCountdown();
    
    // Simulate loading for smoother transitions
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _findUpcomingEvent() {
    final now = DateTime.now();
    _upcomingEvent = nakathEvents.firstWhere(
      (event) => event.dateTime.isAfter(now),
      orElse: () => nakathEvents.last,
    );
  }

  void _setupCountdown() {
    _updateTimeRemaining();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeRemaining();
    });
  }

  void _updateTimeRemaining() {
    final now = DateTime.now();
    
    // Check if current upcoming event has passed
    if (!_upcomingEvent.dateTime.isAfter(now)) {
      // Find the next upcoming event
      _findUpcomingEvent();
    }
    
    if (_upcomingEvent.dateTime.isAfter(now)) {
      setState(() {
        _timeRemaining = _upcomingEvent.dateTime.difference(now);
      });
    } else {
      setState(() {
        _timeRemaining = Duration.zero;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
        ? _buildLoadingView() 
        : _buildMainContent(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/sri-lanka-loading.json', 
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
          Shimmer.fromColors(
            baseColor: Colors.orange.shade300,
            highlightColor: Colors.amber.shade100,
            child: Text(
              'අලුත් අවුරුදු නැකත්...',
              style: GoogleFonts.notoSansSinhala(
                fontSize: 24, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return CustomScrollView(
      slivers: [
        // Fancy app bar with parallax effect
        SliverAppBar(
          expandedHeight: 220,
          floating: false,
          pinned: true,
          backgroundColor: Colors.deepOrange.shade700,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'අලුත් අවුරුදු නැකත්',
              style: GoogleFonts.notoSansSinhala(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/avurudu_header.jpg',
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.deepOrange.shade900.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {
                // Show notification settings dialog
                _showNotificationDialog();
              },
            ),
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () {
                // Show about dialog
                _showAboutDialog();
              },
            ),
          ],
        ),
        
        // Main content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Upcoming event section
                _buildUpcomingEventSection(),
                
                const SizedBox(height: 24),
                
                // All events list header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_available, 
                        color: Colors.deepOrange.shade700,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'සියලු නැකත්',
                        style: GoogleFonts.notoSansSinhala(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Events list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final event = nakathEvents[index];
              final bool isCurrentUpcoming = event.dateTime == _upcomingEvent.dateTime;
              
              return EventCard(
                event: event, 
                isUpcoming: isCurrentUpcoming,
              ).animate()
              .fadeIn(duration: 300.ms, delay: (index * 100).ms)
              .slideY(begin: 0.2, end: 0, duration: 300.ms, curve: Curves.easeOutQuad);
            },
            childCount: nakathEvents.length,
          ),
        ),
        
        // Footer space
        const SliverToBoxAdapter(
          child: SizedBox(height: 24),
        ),
      ],
    );
  }

  Widget _buildUpcomingEventSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.shade50,
              Colors.orange.shade100,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.upcoming, 
                    color: Colors.deepOrange.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ලබන නැකත: ${_upcomingEvent.title}',
                      style: GoogleFonts.notoSansSinhala(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCountdownTimer(),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailScreen(event: _upcomingEvent),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.deepOrange.shade600,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'විස්තර බලන්න',
                          style: GoogleFonts.notoSansSinhala(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .scale(begin: const Offset(0.95, 0.95), duration: 600.ms);
  }

  Widget _buildCountdownTimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade200.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'ආරම්භ වීමට තව',
            style: GoogleFonts.notoSansSinhala(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCountdownUnit(_timeRemaining.inDays, 'දින'),
              _buildDivider(),
              _buildCountdownUnit(_timeRemaining.inHours.remainder(24), 'පැය'),
              _buildDivider(),
              _buildCountdownUnit(_timeRemaining.inMinutes.remainder(60), 'මිනිත්තු'),
              _buildDivider(),
              _buildCountdownUnit(_timeRemaining.inSeconds.remainder(60), 'තත්පර'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownUnit(int value, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepOrange.shade500,
                Colors.deepOrange.shade700,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.deepOrange.shade200.withOpacity(0.5),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.notoSansSinhala(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: 0.4 + (_animationController.value * 0.6),
          child: Text(
            ':',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange.shade800,
            ),
          ),
        );
      },
    );
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'දැනුම්දීම් සැකසුම්',
            style: GoogleFonts.notoSansSinhala(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text(
                  'සියලුම නැකත් සඳහා දැනුම්දීම්',
                  style: GoogleFonts.notoSansSinhala(),
                ),
                value: true,
                onChanged: (value) {
                  // Toggle notification setting
                },
              ),
              SwitchListTile(
                title: Text(
                  'පැය 1ක් කලින් මතක් කිරීම',
                  style: GoogleFonts.notoSansSinhala(),
                ),
                value: true,
                onChanged: (value) {
                  // Toggle reminder setting
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'එකඟයි',
                style: GoogleFonts.notoSansSinhala(
                  color: Colors.deepOrange.shade700,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'අප ගැන',
            style: GoogleFonts.notoSansSinhala(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/avurudu.json',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 16),
              Text(
                'මෙම යෙදුම සිංහල අලුත් අවුරුද්ද සැමරීමට සහාය වීම සඳහා නිර්මාණය කර ඇත.',
                style: GoogleFonts.notoSansSinhala(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'සියලුම නැකත් වේලාවන් ශ්‍රී ලංකාවේ පොදු දත්ත මත පදනම්ව සකස් කර ඇත.',
                style: GoogleFonts.notoSansSinhala(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                'එකඟයි',
                style: GoogleFonts.notoSansSinhala(
                  color: Colors.deepOrange.shade700,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}