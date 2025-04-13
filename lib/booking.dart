import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'map.dart'; // Import the MapPage


// Add these imports at the top of your file
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';

import 'package:intl/intl.dart';
import 'payment_api.dart'; // Import the new payment API page

import 'map_calibration.dart';



// Define a Train model class
class Train {
  final String trainNo;
  final String trainName;
  final String sourceStation;
  final String destStation;
  final String days;

  Train({
    required this.trainNo,
    required this.trainName,
    required this.sourceStation,
    required this.destStation,
    required this.days,
  });
}



// Function to load and parse the CSV file
Future<List<Train>> loadTrainsFromCsv() async {
  final rawData = await rootBundle.loadString('assets/train_info.csv');
  final List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);
  
  List<Train> trains = [];
  
  // Skip header row
  for (int i = 1; i < csvTable.length; i++) {
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



// Function to search for trains
Future<List<Train>> searchTrains(String fromStation, String toStation) async {
  List<Train> allTrains = await loadTrainsFromCsv();
  
  return allTrains.where((train) {
    return train.sourceStation.toLowerCase().contains(fromStation.toLowerCase()) &&
           train.destStation.toLowerCase().contains(toStation.toLowerCase());
  }).toList();
}


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
      appBar: AppBar(
        title: const Text('Available Trains'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.withOpacity(0.1),
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
                  '${trains.length} trains found',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: trains.length,
              itemBuilder: (context, index) {
                final train = trains[index];
                return Card(
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
                            const Icon(Icons.arrow_forward),
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
                                // Navigate to the payment API page with the selected train info
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentAPIPage(
                                      trainNo: train.trainNo,
                                      fromStation: fromStation,
                                      toStation: toStation,
                                      selectedClass: selectedClass,
                                      selectedQuota: selectedQuota,
                                      journeyDate: DateTime.now(), // You might want to pass the actual selected date
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
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




class BookingPage extends StatefulWidget {
  final String username;

  const BookingPage({super.key, required this.username});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String selectedJourneyType = 'One Way';
  String selectedClass = '2A';
  String selectedQuota = 'GN';
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> stations = [];
  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();
  final FocusNode _fromFocusNode = FocusNode();
  final FocusNode _toFocusNode = FocusNode();
  String fromStationCode = '';
  String toStationCode = '';
  String fromStationName = '';
  String toStationName = '';
  bool isFromFocused = false;
  bool isToFocused = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadStations();
    _setupFocusListeners();
  }

  void _setupFocusListeners() {
    _fromFocusNode.addListener(() {
      setState(() {
        isFromFocused = _fromFocusNode.hasFocus;
        if (isFromFocused) isToFocused = false;
      });
    });
    _toFocusNode.addListener(() {
      setState(() {
        isToFocused = _toFocusNode.hasFocus;
        if (isToFocused) isFromFocused = false;
      });
    });
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    _fromFocusNode.dispose();
    _toFocusNode.dispose();
    super.dispose();
  }

  Future<void> loadStations() async {
    final String response = await rootBundle.loadString('assets/stations.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      stations = List<Map<String, dynamic>>.from(data);
    });
  }

  List<Map<String, dynamic>> getFilteredStations(String query) {
    if (query.isEmpty) return [];
    return stations
        .where((station) {
          final stationName = station['STATION NAME'].toString().toLowerCase();
          final stationCode = station['CODE'].toString().toLowerCase();
          final searchLower = query.toLowerCase();
          return stationName.contains(searchLower) ||
              stationCode.contains(searchLower);
        })
        .take(5)
        .toList(); // Limit to 5 suggestions for better performance
  }

  void openMapForSelection(bool isFromStation) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(
          isSelectingFromStation: isFromStation,
          onStationSelected: (code, name) {
            setState(() {
              if (isFromStation) {
                fromStationCode = code;
                fromStationName = name;
                fromController.text = code;
              } else {
                toStationCode = code;
                toStationName = name;
                toController.text = code;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildSuggestionsList(bool isFrom) {
    final filteredStations =
        getFilteredStations(isFrom ? fromController.text : toController.text);

    if (!isFromFocused && !isToFocused) return const SizedBox.shrink();
    if (filteredStations.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: isFrom ? 180 : 280, // Adjust these values based on your layout
      left: 20,
      right: 20,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filteredStations.length,
            itemBuilder: (context, index) {
              final station = filteredStations[index];
              return ListTile(
                title: Text(station['STATION NAME']),
                subtitle:
                    Text('${station['CODE']} - ${station['STATION ADDRESS']}'),
                onTap: () {
                  setState(() {
                    if (isFrom) {
                      fromController.text = station['CODE'];
                      fromStationCode = station['CODE'];
                      fromStationName = station['STATION NAME'];
                      _fromFocusNode.unfocus();
                    } else {
                      toController.text = station['CODE'];
                      toStationCode = station['CODE'];
                      toStationName = station['STATION NAME'];
                      _toFocusNode.unfocus();
                    }
                  });
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;
    return Scaffold(
      
      resizeToAvoidBottomInset: true, 
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'WELCOME BACK,\n${widget.username.toUpperCase()}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(Icons.person, color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Main Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(

                                  'Ticket Booking',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // from
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'From',
                                style: TextStyle(color: Colors.black),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.deepPurple),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: TextField(
                                        controller: fromController,
                                        focusNode: _fromFocusNode,
                                        decoration: const InputDecoration(
                                          hintText: 'Enter station name or code',
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.map, color: Colors.deepPurple),
                                    onPressed: () => openMapForSelection(true),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // "To" Column with full width
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'To',
                                style: TextStyle(color: Colors.black),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.deepPurple),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: TextField(
                                        controller: toController,
                                        focusNode: _toFocusNode,
                                        decoration: const InputDecoration(
                                          hintText: 'Enter station name or code',
                                          border: InputBorder.none,
                                        ),
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.map, color: Colors.deepPurple),
                                    onPressed: () => openMapForSelection(false),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Class', style: TextStyle(color: Colors.grey)),
                              DropdownButton<String>(
                                value: selectedClass,
                                isExpanded: true,
                                underline: Container(), // Removes the default underline
                                style: const TextStyle(color: Colors.black),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedClass = newValue!;
                                  });
                                },
                                items: <String>['2A', '3A', 'SL', 'CC', '2S', 'FC', '1A', '3E']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 25),
                      
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Quota', style: TextStyle(color: Colors.grey)),
                              DropdownButton<String>(
                                value: selectedQuota,
                                isExpanded: true,
                                underline: Container(), // Removes the default underline
                                style: const TextStyle(color: Colors.black),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedQuota = newValue!;
                                  });
                                },
                                items: <String>['GN', 'TQ', 'PT']
                                    .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),


                  //onst SizedBox(height: 20),

                  // Date Picker Row
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Select Date', style: TextStyle(color: Colors.grey)),
                        GestureDetector(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)), // Limit to 1 year
                            );

                            if (pickedDate != null && pickedDate != selectedDate) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${selectedDate.toLocal()}".split(' ')[0], // Show only YYYY-MM-DD
                                  style: const TextStyle(color: Colors.black, fontSize: 16),
                                ),
                                const Icon(Icons.calendar_today, color: Colors.deepPurple),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),




                  // Update your ElevatedButton onPressed function
                  ElevatedButton(
                    onPressed: () async {
                      // Validate inputs and proceed with search
                      if (fromStationCode.isEmpty || toStationCode.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select both stations')),
                        );
                        return;
                      }
                      
                      // Show loading indicator
                      setState(() {
                        isLoading = true;
                      });
                      
                      try {
                        // Search for matching trains
                        List<Train> matchingTrains = await searchTrains(fromStationCode, toStationCode);
                        
                        // Check if any trains were found
                        if (matchingTrains.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No trains found for this route')),
                          );
                        } else {
                          // Navigate to results page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrainResultsPage(
                                trains: matchingTrains,
                                fromStation: fromStationCode,
                                toStation: toStationCode,
                                selectedClass: selectedClass,
                                selectedQuota: selectedQuota,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error loading train data: ${e.toString()}')),
                        );
                      } finally {
                        // Hide loading indicator
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Search',
                          style: TextStyle(color: Colors.white),
                        ),
                  ),




                  const Spacer(),


                  // Add this near other buttons for testing only
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MapCalibrationPage()),
                      );
                    },
                    child: const Text('Calibrate Map'),
                  ),



                ],
              ),
            ),
            if (isFromFocused) _buildSuggestionsList(true),
            if (isToFocused) _buildSuggestionsList(false),
          ],
        ),
      ),
    );
  }
}