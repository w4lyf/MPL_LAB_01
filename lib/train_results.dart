// train_results.dart
import 'package:flutter/material.dart';
import 'train_model.dart';
import 'verification.dart';

class TrainResultsPage extends StatelessWidget {
  final List<Train> trains;
  final String fromStation;
  final String toStation;
  final String selectedClass;
  final String selectedQuota;

  const TrainResultsPage({
    Key? key,
    required this.trains,
    required this.fromStation,
    required this.toStation,
    required this.selectedClass,
    required this.selectedQuota,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(                                     // purple app bar saying Available Trains
        title: const Text('Available Trains'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$fromStation to $toStation',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Class: $selectedClass | Quota: $selectedQuota',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${trains.length} trains found',                       // get length of list       
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(                                                     // Make list use all available space
            child: ListView.builder(                                    // Scrollable list
              itemCount: trains.length,
              itemBuilder: (context, index) {
                final train = trains[index];
                return Card(                                            // Elevated white box with spacing
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              train.trainNo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                train.trainName,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('From'),
                                  Text(
                                    train.sourceStation,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward),                    // Arrow Icon
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('To'),
                                  Text(
                                    train.destStation,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Runs on: ${train.days}'),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VerificationPage(     // Navigation route to payment page
                                      trainNo: train.trainNo,
                                      fromStation: fromStation,
                                      toStation: toStation,
                                      selectedClass: selectedClass,
                                      selectedQuota: selectedQuota,
                                      journeyDate: DateTime.now(),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.from(alpha: 1, red: 0.404, green: 0.227, blue: 0.718),
                              ),
                              child: const Text(
                                'Book',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
