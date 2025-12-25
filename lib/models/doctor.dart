class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String bio;
  final String price;
  final Map<String, List<String>> bookings; // key: yyyy-m-d

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    String? bio,
    required this.price,
    Map<String, List<String>>? bookings,
  })  : bio = bio ?? '',
        bookings = bookings ?? {};

  bool isBooked(String dateKey, String time) =>
      bookings[dateKey]?.contains(time) ?? false;

  void book(String dateKey, String time) {
    bookings.putIfAbsent(dateKey, () => []);
    if (!bookings[dateKey]!.contains(time)) bookings[dateKey]!.add(time);
  }

  void cancel(String dateKey, String time) {
    bookings[dateKey]?.remove(time);
    if (bookings[dateKey]?.isEmpty ?? false) bookings.remove(dateKey);
  }
}

