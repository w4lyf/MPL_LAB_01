import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'map.dart';
import 'train_model.dart';
import 'train_utils.dart';
import 'train_results.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
  void _setupFocusListeners() {                                      // Detects whether user is typing in “from” or “to” field (used to show suggestion box)
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
      stations = List<Map<String, dynamic>>.from(data);                           // Load and store stations from csv in List
    });
  }

  List<Map<String, dynamic>> getFilteredStations(String query) {
    if (query.isEmpty) return [];
    return stations
        .where((station) {
          final stationName = station['STATION NAME'].toString().toLowerCase();
          final stationCode = station['CODE'].toString().toLowerCase();
          final searchLower = query.toLowerCase();                             
          return stationName.contains(searchLower) || stationCode.contains(searchLower);
        })
        .take(5)                                                                // return first 5 results for perfromance
        .toList();                                                              // convert to list
  }

  void openMapForSelection(bool isFromStation) async {
    await Navigator.push(                                                       // Navigation to map page
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
    final filteredStations = getFilteredStations(isFrom ? fromController.text : toController.text);    // get filtered stations list
    if (!isFromFocused && !isToFocused) return const SizedBox.shrink();
    if (filteredStations.isEmpty) return const SizedBox.shrink();
    return Positioned(                                                                               
      top: isFrom ? 180 : 280,
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
              return ListTile(                                                                        // Display contents of list as Tiles
                title: Text(station['STATION NAME']),
                subtitle: Text('${station['CODE']} - ${station['STATION ADDRESS']}'),
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(                                                   // Allows overlaying elements like suggestion boxes on top of main content
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(                                                  // Header
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'WELCOME BACK',
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
                        // From section
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
                        // "To" section 
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
                              DropdownButton<String>(                          // Tap-to-open dropdown + onChanged triggers UI update.
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
                            DateTime? pickedDate = await showDatePicker(               // triggers date picker, setState updates the date shown
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
                  ElevatedButton(
                    onPressed: () async {
                      // Validate inputs and proceed with search
                      if (fromStationCode.isEmpty || toStationCode.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select both stations')),
                        );
                        return;
                      }      
                      try {
                        List<Train> matchingTrains = await searchTrains(fromStationCode, toStationCode);    // fn defined in train_utils.dart                  
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
                              builder: (context) => TrainResultsPage(             // Navigate to train results page
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
                     } 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child:
                      const Text(
                          'Search',
                          style: TextStyle(color: Colors.white),
                        ),
                  ),
                ],
              ),
            ),
            if (isFromFocused) _buildSuggestionsList(true),                   // Suggests stations as user types.
            if (isToFocused) _buildSuggestionsList(false),
          ],
        ),
      ),
    );
  }
}