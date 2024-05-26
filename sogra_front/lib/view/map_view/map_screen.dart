import 'dart:async';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:sogra_front/constants/image_assets.dart';
import 'package:sogra_front/constants/theme.dart';
import '../components/appbar_preffered_size.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng _currentLocation = LatLng(36.328690, 127.429920); // 디폴트 위치 설정
  final Set<Marker> _markers = {};
  BitmapDescriptor? customIcon;

  @override
  void initState() {
    super.initState();
    _setCurrentLocation();
    _loadCustomMarker();
    _fetchRestaurants();
  }

  Future<void> _loadCustomMarker() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      ImageAssets.marker,
    );
  }

  Future<void> _setCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
      return;
    }

    try {
      print('Getting current position...');
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('Current position: ${position.latitude}, ${position.longitude}');
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _updateCameraPosition();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _fetchRestaurants() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/restaurants'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        _markers.addAll(data.map((restaurant) {
          return Marker(
            markerId: MarkerId(restaurant['id'].toString()),
            position: LatLng(restaurant['latitude'], restaurant['longitude']),
            icon: customIcon ?? BitmapDescriptor.defaultMarker, // 커스텀 아이콘 사용
            infoWindow: InfoWindow(
              title: restaurant['name'],
              onTap: () {
                print(restaurant['id']);
                _showRestaurantDetails(restaurant['id'], restaurant['name']);
              },
            ),
          );
        }).toList());
      });
    } else {
      print('Failed to load restaurants');
    }
  }

  Future<void> _showRestaurantDetails(int restaurantId, String name) async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/restaurants/${restaurantId}/menus'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      print(data);

      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(name, style: textTheme().titleMedium),
                  SizedBox(height: 10),
                  if (data.isNotEmpty)
                    Column(
                      children: data.map((menu) {
                        return Column(
                          children: [
                            Image.network(menu['image_url'], width: 100, height: 100),
                            SizedBox(height: 10),
                            Text(menu['name'], style: textTheme().bodyMedium),
                            SizedBox(height: 20),
                          ],
                        );
                      }).toList(),
                    )
                  else
                    Text('No menu available', style: textTheme().bodyMedium),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('확인', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      print('Failed to load menu details');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Future<void> _updateCameraPosition() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(_currentLocation));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '델리만쥐',
          style: GoogleFonts.gugi(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        bottom: appBarBottomLine(),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _currentLocation,
          zoom: 15.0,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
