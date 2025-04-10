import 'package:flutter/material.dart';
import '../models/nakath_event.dart';
import '../screens/event_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class EventCard extends StatelessWidget {
  final NakathEvent event;
  final bool isUpcoming;

  const EventCard({super.key, required this.event, this.isUpcoming = false});

  @override
  Widget build(BuildContext context) {
    // Format date and time more elegantly
    final dateFormat = DateFormat('yyyy MMMM d');
    final timeFormat = DateFormat('h:mm a');
    final isPassed = DateTime.now().isAfter(event.dateTime);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        elevation: isUpcoming ? 6 : 2,
        shadowColor: isUpcoming ? Colors.orange.withOpacity(0.4) : Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isUpcoming ? Colors.orange.shade300 : Colors.transparent,
            width: 1.5,
          ),
        ),
        color: isUpcoming ? Colors.amber.shade50 : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.orange.withOpacity(0.3),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EventDetailScreen(event: event),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Decorative element with status indication
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: _getStatusColor(isPassed, isUpcoming),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor(isPassed, isUpcoming).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _getStatusIcon(isPassed, isUpcoming),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: GoogleFonts.notoSansSinhala(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isUpcoming ? Colors.deepOrange.shade700 : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateFormat.format(event.dateTime),
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeFormat.format(event.dateTime),
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusTag(isPassed, isUpcoming, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(bool isPassed, bool isUpcoming) {
    if (isPassed) return Colors.grey;
    if (isUpcoming) return Colors.deepOrange;
    return Colors.orange;
  }

  IconData _getStatusIcon(bool isPassed, bool isUpcoming) {
    if (isPassed) return Icons.check_circle_outline;
    if (isUpcoming) return Icons.upcoming;
    return Icons.event;
  }

  Widget _buildStatusTag(bool isPassed, bool isUpcoming, BuildContext context) {
    if (isPassed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'අවසන්',
          style: GoogleFonts.notoSansSinhala(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    } else if (isUpcoming) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.deepOrange.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'ඊළඟ',
          style: GoogleFonts.notoSansSinhala(
            color: Colors.deepOrange.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'පැමිණෙමින්',
          style: GoogleFonts.notoSansSinhala(
            color: Colors.orange.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }
  }
}