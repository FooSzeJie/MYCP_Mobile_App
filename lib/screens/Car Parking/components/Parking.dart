class Parking {
  final String id;
  final String start_date;
  final String end_date;
  final int duration;
  final String licensePlate; // Updated field for the license plate
  final String deliver;

  Parking({
    required this.id,
    required this.start_date,
    required this.end_date,
    required this.duration,
    required this.licensePlate,
    required this.deliver,
  });
}