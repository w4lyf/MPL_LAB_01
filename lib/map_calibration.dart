import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MapCalibrationPage extends StatefulWidget {
  const MapCalibrationPage({super.key});

  @override
  State<MapCalibrationPage> createState() => _MapCalibrationPageState();
}

class _MapCalibrationPageState extends State<MapCalibrationPage> {
  final TransformationController _transformationController = TransformationController();
  final List<Map<String, dynamic>> _calibratedStations = [];
  String _stationCode = '';
  String _stationName = '';
  double _tapX = 0;
  double _tapY = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Calibration Tool'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCoordinates,
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: (details) {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final Offset localPosition = box.globalToLocal(details.globalPosition);
              
              // Calculate position relative to the current transformation
              final Matrix4 matrix = _transformationController.value;
              final double scale = matrix.getMaxScaleOnAxis();
              final Offset translation = Offset(matrix.getTranslation().x, matrix.getTranslation().y);
              
              // Adjust coordinates based on transformation
              final adjustedX = (localPosition.dx - translation.dx) / scale;
              final adjustedY = (localPosition.dy - translation.dy) / scale;
              
              setState(() {
                _tapX = adjustedX;
                _tapY = adjustedY;
              });
              
              _showAddStationDialog();
            },
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 4.0,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              child: Stack(
                children: [
                  // The base map image
                  Image.asset(
                    'assets/railway_map.png',
                    fit: BoxFit.contain,
                  ),
                  
                  // Existing calibrated stations
                  ..._calibratedStations.map((station) => Positioned(
                    left: station['x'],
                    top: station['y'],
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          station['code'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ),
          
          // Instructions overlay
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Tap on the map to add station markers\nUse pinch to zoom and drag to navigate\nPress save icon when done',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Station'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Position: (${_tapX.toStringAsFixed(1)}, ${_tapY.toStringAsFixed(1)})'),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Station Code (e.g., NDLS)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _stationCode = value.toUpperCase();
              },
            ),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Station Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _stationName = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_stationCode.isNotEmpty && _stationName.isNotEmpty) {
                setState(() {
                  _calibratedStations.add({
                    'code': _stationCode,
                    'name': _stationName,
                    'x': _tapX,
                    'y': _tapY,
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCoordinates() async {
  try {
    final jsonData = jsonEncode(_calibratedStations);
    
    // Add this line to print the JSON data to console
    print('Station coordinates JSON: $jsonData');
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/station_coordinates.json');
    await file.writeAsString(jsonData);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved ${_calibratedStations.length} stations to ${file.path}'),
        backgroundColor: Colors.green,
      ),
    );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving coordinates: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}