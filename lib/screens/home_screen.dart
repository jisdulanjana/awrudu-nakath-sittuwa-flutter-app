import 'package:flutter/material.dart';
import '../data/nakath_data.dart';
import '../widgets/event_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = nakathEvents.firstWhere(
      (event) => event.dateTime.isAfter(now),
      orElse: () => nakathEvents.last,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('අලුත් අවුරුදු නැකත්'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📌 ලබන සිදුවීම:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            EventCard(event: upcoming, isUpcoming: true),

            const SizedBox(height: 20),
            Text(
              '📅 සියලු නැකත්:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: nakathEvents.length,
                itemBuilder: (context, index) {
                  return EventCard(event: nakathEvents[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
