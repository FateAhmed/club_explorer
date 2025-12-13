import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:explorify/utils/AppColors.dart';
import 'package:explorify/utils/AppDimens.dart';
import 'package:flutter_html/flutter_html.dart';

class NavigationScreen extends StatefulWidget {
  final List<maps.LatLng> routePoints;
  final List<String> pointNames;
  final String tourName;
  final int startIndex;

  const NavigationScreen({
    Key? key,
    required this.routePoints,
    required this.pointNames,
    required this.tourName,
    this.startIndex = 0,
  }) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> with TickerProviderStateMixin {
  maps.GoogleMapController? mapController;
  Position? currentLocation;
  int currentDestinationIndex = 0;
  List<maps.LatLng> navigationRoute = [];
  List<Map<String, dynamic>> turnByTurnDirections = [];
  bool isLoadingDirections = true;
  Timer? locationTimer;
  double distanceToDestination = 0.0;
  String currentInstruction = '';
  bool isArrived = false;

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
    currentDestinationIndex = widget.startIndex;
    _initializeNavigation();
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeNavigation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionDialog();
      return;
    }

    await _getCurrentLocation();
    await _getDirectionsToDestination();

    locationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        currentLocation = position;
      });

      _updateDistanceAndBearing();
      _checkArrival();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _updateDistanceAndBearing() {
    if (currentLocation != null && widget.routePoints.isNotEmpty) {
      maps.LatLng destination = widget.routePoints[currentDestinationIndex];

      double distance = Geolocator.distanceBetween(
        currentLocation!.latitude,
        currentLocation!.longitude,
        destination.latitude,
        destination.longitude,
      );

      setState(() {
        distanceToDestination = distance;
        currentInstruction = _getInstructionFromDistance(distance);
      });
    }
  }

  String _getInstructionFromDistance(double distance) {
    if (distance < 20) {
      return 'You have arrived at ${widget.pointNames[currentDestinationIndex]}!';
    } else if (distance < 100) {
      return 'Approaching ${widget.pointNames[currentDestinationIndex]}';
    } else if (distance < 500) {
      return 'Continue towards ${widget.pointNames[currentDestinationIndex]}';
    } else {
      return 'Navigate to ${widget.pointNames[currentDestinationIndex]}';
    }
  }

  void _checkArrival() {
    if (distanceToDestination < 50 && !isArrived) {
      setState(() {
        isArrived = true;
      });
      _showArrivalDialog();
    }
  }

  Future<void> _getDirectionsToDestination() async {
    if (currentLocation == null || widget.routePoints.isEmpty) {
      print('No current location or route points available');
      setState(() {
        isLoadingDirections = false;
      });
      return;
    }

    setState(() {
      isLoadingDirections = true;
    });

    try {
      maps.LatLng destination = widget.routePoints[currentDestinationIndex];
      String origin = '${currentLocation!.latitude},${currentLocation!.longitude}';
      String dest = '${destination.latitude},${destination.longitude}';

      print('Fetching directions from $origin to $dest');

      String url = 'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=$origin'
          '&destination=$dest'
          '&mode=driving'
          '&key=$apiKey';

      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Request timeout');
          setState(() {
            isLoadingDirections = false;
          });
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          List<maps.LatLng> routePoints = [];
          List<Map<String, dynamic>> directions = [];

          for (var route in data['routes']) {
            for (var leg in route['legs']) {
              for (var step in leg['steps']) {
                List<maps.LatLng> stepPoints = _decodePolyline(step['polyline']['points']);
                routePoints.addAll(stepPoints);

                directions.add({
                  'instruction': step['html_instructions'],
                  'distance': step['distance']['text'],
                  'duration': step['duration']['text'],
                  'maneuver': step['maneuver'] ?? 'straight',
                });
              }
            }
          }

          setState(() {
            navigationRoute = routePoints;
            turnByTurnDirections = directions;
            isLoadingDirections = false;
          });
        } else {
          // API returned no routes or error status
          print('No routes found or API error: ${data['status']}');

          // Create a simple straight line route as fallback
          List<maps.LatLng> fallbackRoute = [
            maps.LatLng(currentLocation!.latitude, currentLocation!.longitude),
            destination,
          ];

          List<Map<String, dynamic>> fallbackDirections = [
            {
              'instruction': 'Navigate to <b>${widget.pointNames[currentDestinationIndex]}</b>',
              'distance': '${distanceToDestination.toStringAsFixed(0)} m',
              'duration': '${(distanceToDestination / 1000 * 20).toStringAsFixed(0)} min',
              'maneuver': 'straight',
            },
          ];

          setState(() {
            navigationRoute = fallbackRoute;
            turnByTurnDirections = fallbackDirections;
            isLoadingDirections = false;
          });
        }
      } else {
        // HTTP error
        print('HTTP error: ${response.statusCode}');

        // Create a simple straight line route as fallback
        List<maps.LatLng> fallbackRoute = [
          maps.LatLng(currentLocation!.latitude, currentLocation!.longitude),
          destination,
        ];

        List<Map<String, dynamic>> fallbackDirections = [
          {
            'instruction': 'Navigate to <b>${widget.pointNames[currentDestinationIndex]}</b>',
            'distance': '${distanceToDestination.toStringAsFixed(0)} m',
            'duration': '${(distanceToDestination / 1000 * 20).toStringAsFixed(0)} min',
            'maneuver': 'straight',
          },
        ];

        setState(() {
          navigationRoute = fallbackRoute;
          turnByTurnDirections = fallbackDirections;
          isLoadingDirections = false;
        });
      }
    } catch (e) {
      print('Error getting directions: $e');

      // Create a simple straight line route as fallback
      if (currentLocation != null && widget.routePoints.isNotEmpty) {
        maps.LatLng destination = widget.routePoints[currentDestinationIndex];
        List<maps.LatLng> fallbackRoute = [
          maps.LatLng(currentLocation!.latitude, currentLocation!.longitude),
          destination,
        ];

        List<Map<String, dynamic>> fallbackDirections = [
          {
            'instruction': 'Navigate to <b>${widget.pointNames[currentDestinationIndex]}</b>',
            'distance': '${distanceToDestination.toStringAsFixed(0)} m',
            'duration': '${(distanceToDestination / 1000 * 20).toStringAsFixed(0)} min',
            'maneuver': 'straight',
          },
        ];

        setState(() {
          navigationRoute = fallbackRoute;
          turnByTurnDirections = fallbackDirections;
          isLoadingDirections = false;
        });
      } else {
        setState(() {
          isLoadingDirections = false;
        });
      }
    }
  }

  List<maps.LatLng> _decodePolyline(String encoded) {
    List<maps.LatLng> poly = [];
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

      final p = maps.LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  void _nextDestination() {
    if (currentDestinationIndex < widget.routePoints.length - 1) {
      setState(() {
        currentDestinationIndex++;
        isArrived = false;
        isLoadingDirections = true;
      });
      _getDirectionsToDestination();
    } else {
      _showTourCompletedDialog();
    }
  }

  void _showArrivalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Arrived at ${widget.pointNames[currentDestinationIndex]}!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: AppColors.primary1, size: 48),
            AppDimens.sizebox15,
            Text('You have successfully reached ${widget.pointNames[currentDestinationIndex]}.'),
            if (currentDestinationIndex < widget.routePoints.length - 1)
              Text('Ready to continue to the next stop?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('End Tour'),
          ),
          if (currentDestinationIndex < widget.routePoints.length - 1)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _nextDestination();
              },
              child: const Text('Next Stop'),
            ),
        ],
      ),
    );
  }

  void _showTourCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Tour Completed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.celebration, color: AppColors.primary1, size: 48),
            AppDimens.sizebox15,
            const Text('Congratulations! You have completed the entire tour.'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Finish'),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeNavigation();
            },
            child: const Text('Grant Permission'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Navigation',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Navigation Status Indicator
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // // Navigation Header
          // Container(
          //   width: double.infinity,
          //   padding: EdgeInsets.symmetric(vertical: 20),
          //   color: AppColors.primary1,
          //   child: Column(
          //     children: [
          //       // Navigation Progress Bar
          //       Container(
          //         margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //         child: LinearProgressIndicator(
          //           value: (currentDestinationIndex + 1) / widget.routePoints.length,
          //           backgroundColor: AppColors.white.withOpacity(0.3),
          //           valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
          //           minHeight: 4,
          //         ),
          //       ),

          //       // Navigation Status
          //       AnimatedBuilder(
          //         animation: _pulseAnimation,
          //         builder: (context, child) {
          //           return Container(
          //             margin: EdgeInsets.symmetric(horizontal: 20),
          //             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          //             decoration: BoxDecoration(
          //               color: AppColors.white.withOpacity(0.2),
          //               borderRadius: BorderRadius.circular(20),
          //             ),
          //             child: Row(
          //               mainAxisSize: MainAxisSize.min,
          //               children: [
          //                 Transform.scale(
          //                   scale: _pulseAnimation.value,
          //                   child: Icon(
          //                     Icons.navigation,
          //                     color: AppColors.white,
          //                     size: 16,
          //                   ),
          //                 ),
          //                 SizedBox(width: 8),
          //                 Text(
          //                   'Navigation Active',
          //                   style: TextStyle(
          //                     color: AppColors.white,
          //                     fontSize: 14,
          //                     fontWeight: FontWeight.bold,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           );
          //         },
          //       ),

          //       AppDimens.sizebox15,
          //       Text(
          //         widget.tourName,
          //         style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
          //       ),
          //       AppDimens.sizebox10,
          //       Text(
          //         '${currentDestinationIndex + 1} of ${widget.routePoints.length} stops',
          //         style: TextStyle(color: AppColors.white.withOpacity(0.8)),
          //       ),
          //     ],
          //   ),
          // ),

          // Navigation Instructions
          Container(
            padding: AppDimens.padding20,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
                  const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
              boxShadow: [
                BoxShadow(color: AppColors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current Instruction
                Container(
                  padding: AppDimens.padding15,
                  decoration: BoxDecoration(
                    color: AppColors.primary1.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary1.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.navigation, color: AppColors.primary1, size: 24),
                      AppDimens.sizebox15,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentInstruction,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            AppDimens.sizebox5,
                            Text(
                              '${distanceToDestination.toStringAsFixed(0)} meters to ${widget.pointNames[currentDestinationIndex]}',
                              style: TextStyle(color: AppColors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AppDimens.sizebox15,

                // Turn-by-turn directions
                if (turnByTurnDirections.isNotEmpty) ...[
                  Text('Turn-by-turn Directions',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  AppDimens.sizebox10,
                  Container(
                    height: 120,
                    child: ListView.builder(
                      itemCount: turnByTurnDirections.length,
                      itemBuilder: (context, index) {
                        final direction = turnByTurnDirections[index];
                        return Padding(
                          padding: AppDimens.verticalPadding5,
                          child: Row(
                            children: [
                              Icon(_getDirectionIcon(direction['maneuver']),
                                  color: AppColors.primary1, size: 20),
                              AppDimens.sizebox10,
                              Expanded(
                                child: Html(
                                  data: direction['instruction'],
                                  style: {
                                    "body": Style(
                                      fontSize: FontSize(14),
                                      color: AppColors.textsecondary,
                                    ),
                                    "b": Style(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textprimary,
                                    ),
                                    "div": Style(
                                      fontSize: FontSize(12),
                                      color: AppColors.grey,
                                    ),
                                  },
                                ),
                              ),
                              Text(direction['distance'], style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // Progress indicator
                AppDimens.sizebox15,
                LinearProgressIndicator(
                  value: (currentDestinationIndex + 1) / widget.routePoints.length,
                  backgroundColor: AppColors.grey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary1),
                ),
                AppDimens.sizebox5,
                Text(
                  'Tour Progress: ${currentDestinationIndex + 1} of ${widget.routePoints.length} stops',
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
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
                boxShadow: [BoxShadow(color: AppColors.grey.withOpacity(0.2), blurRadius: 10)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    maps.GoogleMap(
                      onMapCreated: (maps.GoogleMapController controller) {
                        mapController = controller;
                        // Apply dark map style
                        controller.setMapStyle(_mapStyle);
                      },
                      initialCameraPosition: maps.CameraPosition(
                        target: widget.routePoints.isNotEmpty
                            ? widget.routePoints[currentDestinationIndex]
                            : const maps.LatLng(36.1699, -115.1398),
                        zoom: 15,
                      ),
                      markers: {
                        if (currentLocation != null)
                          maps.Marker(
                            markerId: const maps.MarkerId('current_location'),
                            position: maps.LatLng(currentLocation!.latitude, currentLocation!.longitude),
                            icon: maps.BitmapDescriptor.defaultMarkerWithHue(maps.BitmapDescriptor.hueBlue),
                            infoWindow: const maps.InfoWindow(title: 'Your Location'),
                          ),
                        maps.Marker(
                          markerId: const maps.MarkerId('destination'),
                          position: widget.routePoints[currentDestinationIndex],
                          icon: maps.BitmapDescriptor.defaultMarkerWithHue(maps.BitmapDescriptor.hueRed),
                          infoWindow: maps.InfoWindow(title: widget.pointNames[currentDestinationIndex]),
                        ),
                      },
                      polylines: {
                        if (navigationRoute.isNotEmpty)
                          maps.Polyline(
                            polylineId: const maps.PolylineId('navigation_route'),
                            points: navigationRoute,
                            color: AppColors.primary1,
                            width: 5,
                          ),
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                    ),

                    // Loading overlay when fetching directions
                    if (isLoadingDirections)
                      Container(
                        color: Colors.black.withOpacity(0.3),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  color: AppColors.primary1,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Calculating route...',
                                  style: TextStyle(
                                    color: AppColors.textprimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDirectionIcon(String maneuver) {
    switch (maneuver) {
      case 'turn-left':
        return Icons.turn_left;
      case 'turn-right':
        return Icons.turn_right;
      case 'turn-slight-left':
        return Icons.turn_slight_left;
      case 'turn-slight-right':
        return Icons.turn_slight_right;
      case 'turn-sharp-left':
        return Icons.turn_sharp_left;
      case 'turn-sharp-right':
        return Icons.turn_sharp_right;
      case 'uturn-left':
      case 'uturn-right':
        return Icons.u_turn_left;
      case 'straight':
      default:
        return Icons.straight;
    }
  }
}
