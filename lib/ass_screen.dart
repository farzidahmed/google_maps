import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapsAssignment extends StatefulWidget {
  const GoogleMapsAssignment({Key? key}) : super(key: key);

  @override
  State<GoogleMapsAssignment> createState() => _GoogleMapsAssignmentState();
}

class _GoogleMapsAssignmentState extends State<GoogleMapsAssignment> {
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  List<LatLng> polylineCoordinates = [];
  Set<Polyline> polylines = {};
  StreamSubscription<Position>? positionStream;

  @override
  void initState() {
    super.initState();
    startLocationUpdates();
  }

  void startLocationUpdates() {
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        // Update Marker
        markers = {
          Marker(
            markerId: const MarkerId("current_location"),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: InfoWindow(
              title: "My Current Location",
              snippet: "${position.latitude}, ${position.longitude}",
            ),
          ),
        };
        // Update Polyline
        polylineCoordinates.add(LatLng(position.latitude, position.longitude));
        polylines = {
          Polyline(
            polylineId: const PolylineId("route"),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 4,
          ),
        };
      });
    });
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Maps Assignment"),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(23.735035, 89.629469),
          zoom: 16,
        ),
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
        markers: markers,
        polylines: polylines,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: animateToUserLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Future<void> animateToUserLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 16,
      ),
    ));
  }
}
