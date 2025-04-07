import 'package:flutter/material.dart';
import '../models/nakath_event.dart';
import '../screens/event_detail_screen.dart';

class EventCard extends StatelessWidget {
  final NakathEvent event;
  final bool isUpcoming;

  const EventCard({
    super.key,
    required this.event,
    this.isUpcoming = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isUpcoming ? Colors.yellow[100] : null,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(event.title),
        subtitle: Text(
          '${event.dateTime.year}-${event.dateTime.month.toString().padLeft(2, '0')}-${event.dateTime.day.toString().padLeft(2, '0')} '
          '${event.dateTime.hour.toString().padLeft(2, '0')}:${event.dateTime.minute.toString().padLeft(2, '0')}',
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(event: event),
            ),
          );
        },
      ),
    );
  }
}
