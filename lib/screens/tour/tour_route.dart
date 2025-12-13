import 'package:explorify/screens/home/web_widget/web_widget.dart';
import 'package:explorify/screens/tour/navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:explorify/utils/AppColors.dart';
import 'package:explorify/utils/AppDimens.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class TourRouteScreen extends StatefulWidget {
  final String tourName;
  final String tourDuration;
  final String tourDistance;
  final String tourDescription;
  final List<LatLng> routePoints;
  final List<String> pointNames;
  final String tourId;
  const TourRouteScreen({
    super.key,
    required this.tourId,
    required this.tourName,
    required this.tourDuration,
    required this.tourDistance,
    required this.tourDescription,
    required this.routePoints,
    required this.pointNames,
  });

  @override
  State<TourRouteScreen> createState() => _TourRouteScreenState();
}

class _TourRouteScreenState extends State<TourRouteScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  bool isLoadingRoute = true;
  double currentZoom = 12.0;

  // Navigation variables
  Position? currentUserLocation;
  bool isNavigating = false;
  int currentDestinationIndex = 0;
  String navigationInstruction = '';
  double distanceToDestination = 0.0;
  Timer? locationTimer;
  bool isLocationEnabled = false;

  // Google Maps API Key - Replace with your actual API key
  static const String apiKey = 'AIzaSyBLTm_mUtLfjWxUZD5YB4_BNoYXz-AUw5U';

  // Dark map style
  static const String _mapStyle = '''[
    {
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "elementType": "labels.icon",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "administrative.country",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#9e9e9e"
        }
      ]
    },
    {
      "featureType": "administrative.land_parcel",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "administrative.locality",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#bdbdbd"
        }
      ]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#181818"
        }
      ]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#616161"
        }
      ]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#1b1b1b"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry.fill",
      "stylers": [
        {
          "color": "#2c2c2c"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#8a8a8a"
        }
      ]
    },
    {
      "featureType": "road.arterial",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#373737"
        }
      ]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#3c3c3c"
        }
      ]
    },
    {
      "featureType": "road.highway.controlled_access",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#4e4e4e"
        }
      ]
    },
    {
      "featureType": "road.local",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#616161"
        }
      ]
    },
    {
      "featureType": "transit",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#000000"
        }
      ]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#3d3d3d"
        }
      ]
    }
  ]''';

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _getRouteDirections();
    _initializeLocationServices();
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _getRouteDirections() async {
    if (widget.routePoints.length < 2) {
      setState(() {
        isLoadingRoute = false;
      });
      return;
    }

    try {
      // Build waypoints string for the API
      String waypoints = '';
      for (int i = 1; i < widget.routePoints.length - 1; i++) {
        waypoints += '${widget.routePoints[i].latitude},${widget.routePoints[i].longitude}|';
      }
      if (waypoints.isNotEmpty) {
        waypoints = waypoints.substring(0, waypoints.length - 1);
      }

      // Build the API URL
      String origin = '${widget.routePoints.first.latitude},${widget.routePoints.first.longitude}';
      String destination = '${widget.routePoints.last.latitude},${widget.routePoints.last.longitude}';

      String url = 'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=$origin'
          '&destination=$destination'
          '&waypoints=$waypoints'
          '&mode=driving'
          '&key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          List<LatLng> routePoints = [];

          // Extract route points from the response
          for (var route in data['routes']) {
            for (var leg in route['legs']) {
              for (var step in leg['steps']) {
                // Decode the polyline
                List<LatLng> stepPoints = _decodePolyline(step['polyline']['points']);
                routePoints.addAll(stepPoints);
              }
            }
          }

          setState(() {
            polylines.clear();
            polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                points: routePoints,
                color: AppColors.primary1,
                width: 5,
                patterns: [PatternItem.dot, PatternItem.gap(10)],
              ),
            );
            isLoadingRoute = false;
          });
        } else {
          // Fallback to straight lines if API fails
          _createStraightLineRoute();
        }
      } else {
        // Fallback to straight lines if API fails
        _createStraightLineRoute();
      }
    } catch (e) {
      // Fallback to straight lines if API fails
      _createStraightLineRoute();
    }
  }

  void _createStraightLineRoute() {
    setState(() {
      polylines.clear();
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: widget.routePoints,
          color: AppColors.primary1,
          width: 5,
          patterns: [PatternItem.dot, PatternItem.gap(10)],
        ),
      );
      isLoadingRoute = false;
    });
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      final p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  void _initializeMap() async {
    await _updateMarkers();
  }

  // Location and Navigation Methods
  Future<void> _initializeLocationServices() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDialog();
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showPermissionDialog();
        return;
      }

      // Get initial location
      setState(() {
        isLocationEnabled = true;
      });

      await _getCurrentLocation();
    } catch (e) {
      print('Error initializing location services: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentUserLocation = position;
      });

      // Update distance to current destination
      _updateDistanceToDestination();
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void _updateDistanceToDestination() {
    if (currentUserLocation != null && widget.routePoints.isNotEmpty) {
      LatLng destination = widget.routePoints[currentDestinationIndex];
      double distance = Geolocator.distanceBetween(
        currentUserLocation!.latitude,
        currentUserLocation!.longitude,
        destination.latitude,
        destination.longitude,
      );

      setState(() {
        distanceToDestination = distance;
        navigationInstruction = _getNavigationInstruction(distance);
      });
    }
  }

  String _getNavigationInstruction(double distance) {
    if (distance < 50) {
      return 'You have arrived at ${widget.pointNames[currentDestinationIndex]}!';
    } else if (distance < 200) {
      return 'Approaching ${widget.pointNames[currentDestinationIndex]}';
    } else if (distance < 1000) {
      return 'Continue towards ${widget.pointNames[currentDestinationIndex]}';
    } else {
      return 'Navigate to ${widget.pointNames[currentDestinationIndex]}';
    }
  }

  void _startNavigation() {
    if (!isLocationEnabled) {
      _showLocationServiceDialog();
      return;
    }

    // Navigate to the dedicated navigation screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NavigationScreen(
          routePoints: widget.routePoints,
          pointNames: widget.pointNames,
          tourName: widget.tourName,
          startIndex: 0,
        ),
      ),
    );
  }

  void _stopNavigation() {
    setState(() {
      isNavigating = false;
    });
    locationTimer?.cancel();
  }

  void _nextDestination() {
    if (currentDestinationIndex < widget.routePoints.length - 1) {
      setState(() {
        currentDestinationIndex++;
      });
      _updateDistanceToDestination();
    } else {
      // Tour completed
      _showTourCompletedDialog();
    }
  }

  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text('Please enable location services to use navigation features.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text('This app needs location permission to provide navigation features.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeLocationServices();
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  void _showNavigationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Navigating to ${widget.pointNames[currentDestinationIndex]}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(navigationInstruction),
              const SizedBox(height: 10),
              Text('Distance: ${distanceToDestination.toStringAsFixed(0)} meters'),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: (currentDestinationIndex + 1) / widget.routePoints.length,
                backgroundColor: AppColors.grey.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary1),
              ),
              const SizedBox(height: 10),
              Text('${currentDestinationIndex + 1} of ${widget.routePoints.length} stops'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _stopNavigation();
              },
              child: const Text('Stop Navigation'),
            ),
            if (distanceToDestination < 50)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _nextDestination();
                  if (isNavigating) {
                    _showNavigationDialog();
                  }
                },
                child: const Text('Next Stop'),
              ),
          ],
        ),
      ),
    );
  }

  void _showTourCompletedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tour Completed!'),
        content: const Text('Congratulations! You have completed the tour.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _stopNavigation();
            },
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateMarkers() async {
    // Calculate marker size based on zoom level
    double markerSize = _calculateMarkerSize(currentZoom);

    Set<Marker> newMarkers = {};

    // Add markers for each route point
    for (int i = 0; i < widget.routePoints.length; i++) {
      final customIcon = await _createCustomMarker(i + 1, markerSize);
      newMarkers.add(
        Marker(
          markerId: MarkerId('point_$i'),
          position: widget.routePoints[i],
          infoWindow: InfoWindow(
            title: '${i + 1}. ${widget.pointNames[i]}',
            snippet: '${widget.routePoints[i].latitude}, ${widget.routePoints[i].longitude}',
          ),
          icon: customIcon,
          // Add custom label
          onTap: () {
            // Show custom info window with number
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${i + 1}. ${widget.pointNames[i]}'),
                backgroundColor: AppColors.primary1,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      );
    }

    setState(() {
      markers = newMarkers;
    });
  }

  double _calculateMarkerSize(double zoom) {
    // Inverse relationship: smaller zoom = bigger markers
    // Zoom range: 8-18, Marker size range: 40-80 (increased min size)
    double minZoom = 8.0;
    double maxZoom = 18.0;
    double minSize = 60.0;
    double maxSize = 80.0;

    // Clamp zoom to valid range
    zoom = zoom.clamp(minZoom, maxZoom);

    // Calculate size inversely proportional to zoom
    double normalizedZoom = (zoom - minZoom) / (maxZoom - minZoom);
    double size = maxSize - (normalizedZoom * (maxSize - minSize));

    // Ensure minimum size constraint
    size = size.clamp(minSize, maxSize);

    return size;
  }

  // Create custom numbered marker
  Future<BitmapDescriptor> _createCustomMarker(int number, double size) async {
    // Create a custom painter for the marker
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final center = Offset(size / 2, size / 2);
    final radius = size * 0.4; // 40% of size for circle radius

    // Draw circle background
    final paint = Paint()
      ..color = AppColors.primary1
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);

    // Draw border
    final borderPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.04; // 4% of size for border width

    canvas.drawCircle(center, radius, borderPaint);

    // Draw number
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TextStyle(
          color: AppColors.white,
          fontSize: size * 0.32, // 32% of size for font
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textprimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.tourName,
          style: TextStyle(
            color: AppColors.textprimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tour Details Section
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppDimens.sizebox15,
                Row(
                  children: [
                    Icon(Icons.access_time, color: AppColors.primary1, size: 16),
                    AppDimens.sizebox5,
                    Text(
                      widget.tourDuration,
                      style: TextStyle(color: AppColors.grey, fontSize: 14),
                    ),
                    AppDimens.sizebox10,
                    Icon(Icons.straighten, color: AppColors.primary1, size: 16),
                    AppDimens.sizebox2,
                    Text(
                      widget.tourDistance,
                      style: TextStyle(color: AppColors.grey, fontSize: 14),
                    ),
                  ],
                ),
                AppDimens.sizebox10,
                Text(
                  widget.tourDescription,
                  maxLines: 3,
                  style: TextStyle(
                    color: AppColors.textsecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Map Section
          Expanded(
            flex: 2,
            child: Container(
              margin: AppDimens.padding15,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    // Apply dark map style
                    controller.setMapStyle(_mapStyle);
                  },
                  onCameraMove: (CameraPosition position) {
                    // Update zoom level and markers
                    if (position.zoom != currentZoom) {
                      setState(() {
                        currentZoom = position.zoom;
                      });
                      _updateMarkers();
                    }
                  },
                  initialCameraPosition: CameraPosition(
                    target: widget.routePoints.isNotEmpty
                        ? widget.routePoints.first
                        : const LatLng(36.1699, -115.1398),
                    zoom: 12,
                  ),
                  markers: markers,
                  polylines: polylines,
                  myLocationEnabled: isLocationEnabled,
                  myLocationButtonEnabled: isLocationEnabled,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  mapType: MapType.normal,
                ),
              ),
            ),
          ),
          AppDimens.sizebox5,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tour Stops (${widget.routePoints.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textprimary,
                  ),
                ),
                AppDimens.sizebox15,
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: widget.routePoints.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(widget.routePoints[index], 15),
                          );

                          // Show a brief highlight
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${index + 1}. ${widget.pointNames[index]}'),
                              backgroundColor: AppColors.primary1,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Padding(
                          padding: AppDimens.verticalPadding8,
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary1,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary1.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              AppDimens.sizebox15,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.pointNames[index],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    AppDimens.sizebox5,
                                    Text(
                                      '${widget.routePoints[index].latitude.toStringAsFixed(4)}, ${widget.routePoints[index].longitude.toStringAsFixed(4)}',
                                      style: TextStyle(
                                        color: AppColors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Add a small arrow icon to indicate it's tappable
                              Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.grey,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                AppDimens.sizebox10,
                // Navigation and Booking Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isLocationEnabled ? _startNavigation : _initializeLocationServices,
                        icon: Icon(
                          Icons.navigation,
                          color: AppColors.white,
                        ),
                        label: FittedBox(
                          child: Text(
                            'Start Navigation',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary1,
                          padding: AppDimens.padding15,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                    AppDimens.sizebox15,
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(() => WebViewPage(
                              url: 'https://app-club-explorer.ahmadt.com/tour/tour-detail/${widget.tourId}'));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          padding: AppDimens.padding15,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: AppColors.primary1),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          'Book Now',
                          style: TextStyle(
                            color: AppColors.primary1,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppDimens.sizebox30,
        ],
      ),
    );
  }
}
