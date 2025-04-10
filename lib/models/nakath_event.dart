class NakathEvent {
  final String title;
  final DateTime dateTime;
  final String description;
  final String? ritualInstructions;
  final List<String>? preparationItems;

  const NakathEvent({
    required this.title,
    required this.dateTime,
    required this.description,
    this.ritualInstructions,
    this.preparationItems,
  });

  bool isPassed() {
    return DateTime.now().isAfter(dateTime);
  }

  bool isUpcoming() {
    final now = DateTime.now();
    return dateTime.isAfter(now) && 
      dateTime.difference(now) < const Duration(days: 2);
  }
}