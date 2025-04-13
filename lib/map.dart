import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Station {
  final String code;
  final String name;
  final double x;
  final double y;

  Station({
    required this.code, 
    required this.name, 
    required this.x, 
    required this.y
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      code: json['code'],
      name: json['name'],
      x: double.parse(json['x'].toString()),
      y: double.parse(json['y'].toString()),
    );
  }
}

class MapPage extends StatefulWidget {
  final Function(String code, String name) onStationSelected;
  final bool isSelectingFromStation;
  
  const MapPage({
    super.key, 
    required this.onStationSelected,
    required this.isSelectingFromStation,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<Station> stations = [];
  bool isLoading = true;
  final TransformationController _transformationController = TransformationController();
  
  // Track the image dimensions
  Size _imageSize = Size.zero;
  final GlobalKey _imageKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _loadStationCoordinates();
    
    // Add a post-frame callback to measure the image size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateImageSize();
    });
  }
  
  void _updateImageSize() {
    final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _imageSize = renderBox.size;
      });
    }
  }

  Future<void> _loadStationCoordinates() async {
    try {
      final String response = await rootBundle.loadString('assets/station_coordinates.json');
      final List<dynamic> data = json.decode(response);
      
      setState(() {
        stations = data.map((station) => Station.fromJson(station)).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading station coordinates: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSelectingFromStation 
            ? 'Select Departure Station' 
            : 'Select Arrival Station'
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
          
        children: [
          SizedBox(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5,
              maxScale: 4.0,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      
                      // The base map image with key to measure its size
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 1.5,  
                            height: MediaQuery.of(context).size.height * 1.5,
                        child: Image.asset(
                          'assets/railway_map.png',
                          key: _imageKey,
                          fit: BoxFit.contain,
                          //width: MediaQuery.of(context).size.width,  // Set to screen width
                         // height: MediaQuery.of(context).size.height,  // Set to screen height
                        ),
                      ),
                      
                      // Only show stations after the image size is determined
                      if (!isLoading && _imageSize != Size.zero)
                        ...stations.map((station) {
                          return Positioned(
                            left: station.x,
                            top: station.y,
                            child: GestureDetector(
                              onTap: () {
                                widget.onStationSelected(station.code, station.name);
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(1),
                                  shape: BoxShape.circle,
                                  //border: Border.all(color: Colors.white, width: 1),
                                ),
                       
                              ),
                            ),
                          );
                        }),
                    ],
                  );
                },
              ),
            ),
          ),
          
          // Loading indicator
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          
          // Help text
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
                child: Text(
                  'Tap on a station to select it as your ${widget.isSelectingFromStation ? 'departure' : 'arrival'} station',
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          
          // Zoom controls
          Positioned(
            right: 16,
            bottom: 80,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'zoomIn',
                  onPressed: () {
                    final Matrix4 matrix = _transformationController.value.clone();
                    matrix.scale(1.25);
                    _transformationController.value = matrix;
                  },
                  backgroundColor: Colors.deepPurple,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoomOut',
                  onPressed: () {
                    final Matrix4 matrix = _transformationController.value.clone();
                    matrix.scale(0.8);
                    _transformationController.value = matrix;
                  },
                  backgroundColor: Colors.deepPurple,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}