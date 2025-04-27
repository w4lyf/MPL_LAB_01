class Train {                         // A custom data model representing a train.
  final String trainNo;
  final String trainName;
  final String sourceStation;
  final String destStation;
  final String days;

  Train({
    required this.trainNo,            // All are final (immutable) and required in the constructor
    required this.trainName,
    required this.sourceStation,
    required this.destStation,
    required this.days,
  });
}
