import 'dart:async';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'train_model.dart';

Future<List<Train>> loadTrainsFromCsv() async {
  final rawData = await rootBundle.loadString('assets/train_info.csv');
  final List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);     

  List<Train> trains = [];

  for (int i = 1; i < csvTable.length; i++) {                 // Converts csv to a list of rows. Each row = multiple column values
    final row = csvTable[i];
    if (row.length >= 5) {
      trains.add(Train(
        trainNo: row[0].toString(),
        trainName: row[1].toString(),
        sourceStation: row[2].toString(),
        destStation: row[3].toString(),
        days: row[4].toString(),
      ));
    }
  }

  return trains;
}

Future<List<Train>> searchTrains(String fromStation, String toStation) async {
  List<Train> allTrains = await loadTrainsFromCsv();

  return allTrains.where((train) {
    return train.sourceStation.toLowerCase().contains(fromStation.toLowerCase()) &&
           train.destStation.toLowerCase().contains(toStation.toLowerCase());
  }).toList();
}
