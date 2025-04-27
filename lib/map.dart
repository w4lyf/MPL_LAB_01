import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class Station {                                         // model of station class
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
  final Function(String code, String name) onStationSelected;  // pass back selected station info, and update the label based on departure/arrival mode.
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
  final TransformationController _transformationController = TransformationController();          // for zoom controls
  
  Size _imageSize = Size.zero;
  final GlobalKey _imageKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _loadStationCoordinates();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateImageSize();
    });
  }
  
  void _updateImageSize() {
    final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;  // to update imagekey based on screen size
    if (renderBox != null) {
      setState(() {
        _imageSize = renderBox.size;
      });
    }
  }

  Future<void> _loadStationCoordinates() async {            // Loads station data from a JSON file and updates image size after render
    try {
      final String response = await rootBundle.loadString('assets/station_coordinates.json'); // Reads JSON asset, parses it into a list of Station objects.
      final List<dynamic> data = json.decode(response);                                        // Faster and simpler for static data.
      
      setState(() {
        stations = data.map((station) => Station.fromJson(station)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(                                     // app bar with title based on from or to selected
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
                  return Stack(                                             // allows overlays (coordinate points in this case)
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 1.5,  
                            height: MediaQuery.of(context).size.height * 1.5,
                        child: Image.asset(
                          'assets/railway_map.png',
                          key: _imageKey,                                   // load img with the key set for size
                          fit: BoxFit.contain,
                        ),
                      ),

                      if (!isLoading && _imageSize != Size.zero)
                        ...stations.map((station) {                         // call station points to place on map
                          return Positioned(
                            left: station.x,
                            top: station.y,
                            child: GestureDetector(
                              onTap: () {
                                widget.onStationSelected(station.code, station.name);  // return
                                Navigator.pop(context);                       // navigate to previous page if station selected
                              },
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade900,
                                  shape: BoxShape.circle,
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
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          Positioned(                           // information text
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black,
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
          
          Positioned(                                 // zoom controls
            right: 16,
            bottom: 80,
            child: Column(
              children: [
                FloatingActionButton.small(           // floating button
                  heroTag: 'zoomIn',
                  onPressed: () {
                    final Matrix4 matrix = _transformationController.value.clone();
                    matrix.scale(1.25);              // zoom in scale
                    _transformationController.value = matrix;     // update controller
                  },
                  backgroundColor: Colors.deepPurple,
                  child: const Icon(Icons.add),     // + icon
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoomOut',
                  onPressed: () {
                    final Matrix4 matrix = _transformationController.value.clone();
                    matrix.scale(0.8);              // zoom out scale
                    _transformationController.value = matrix;
                  },
                  backgroundColor: Colors.deepPurple,
                  child: const Icon(Icons.remove),    // - icon
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}