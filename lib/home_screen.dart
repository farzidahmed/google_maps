import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

///GPS -> current location->Lat long
/// GPS ->services permission=>yes
/// GPS->service on/of=>YEs
/// get data from gps
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? position;
  GoogleMapController? mapcontroller;

  Set<Polyline> polyline = {};
  List<LatLng> polylinetracking = [];
  Set<Marker> markers={};

// real time location update
  Future<void> currentpossiton() async {
    final isGranted = await isLocationPermissionGranted();
    if (isGranted) {
      final isServiceEnabled = await chkGpsServicelocationEnabled();
      if (isServiceEnabled) {
        Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
               timeLimit: Duration(seconds: 10),
                // distanceFilter: 3,
                accuracy: LocationAccuracy.high))
            .listen((poss) {
          print(poss);
          setState(() {
            position = poss;
          });
          if (mapcontroller != null && position != null) {
            movecameraCurrentPossition(position!);
          }
        });
        polylineupdate(position!);
      } else {
        Geolocator.openLocationSettings();
      }
    } else {
      final result = await requestpermissionLocation();
      if (result) {
        getcurrentLocation();
      } else {
        Geolocator.openAppSettings();
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentpossiton();
  }

  Future<void> getcurrentLocation() async {
    final isGranted = await isLocationPermissionGranted();
    if (isGranted) {
      final isServiceEnabled = await chkGpsServicelocationEnabled();
      if (isServiceEnabled) {
        Position p = await Geolocator.getCurrentPosition(
            locationSettings:
            const LocationSettings(timeLimit: Duration(seconds: 2)));
        print(p);
        position = p;
        setState(() {});
        if (mapcontroller != null) {
          movecameraCurrentPossition(p);
        }
      } else {
        Geolocator.openLocationSettings();
      }
    } else {
      final result = await requestpermissionLocation();
      if (result) {
        getcurrentLocation();
      } else {
        Geolocator.openAppSettings();
      }
    }
  }

  Future<bool> isLocationPermissionGranted() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }
    return false;
  }

  Future<bool> requestpermissionLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }
    return false;
  }

  Future<bool> chkGpsServicelocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  void onMapcreate(GoogleMapController controller) {
    mapcontroller = controller;
  }

  void movecameraCurrentPossition(Position position) {
    mapcontroller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        zoom: 16, target: LatLng(position.latitude, position.longitude))));
  }

  Set<Marker> createMarker() {
    if (position != null) {
      return {
        Marker(
          markerId: MarkerId("current location"),
          position: LatLng(position!.latitude, position!.longitude),
          infoWindow: InfoWindow(
            title: "my location",
            snippet: "${position!.latitude}, ${position!.longitude}",
          ),
        ),
      };
    }
    return {};
  }
  void _onMapTapped(LatLng tappedPoint) {
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId(tappedPoint.toString()),
          position: tappedPoint,
          infoWindow: InfoWindow(
            title: "Tapped Location",
            snippet: "${tappedPoint.latitude}, ${tappedPoint.longitude}",
          ),
        ),
      );
      polylinetracking.add(tappedPoint);
      polyline.add(
        Polyline(
          polylineId: const PolylineId("tracking_route"),
          points: polylinetracking,
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }


  void polylineupdate(Position position) {
    LatLng newpoint = LatLng(position.latitude, position.longitude);
    polylinetracking.add(newpoint);
    setState(() {
      polyline.add(Polyline(polylineId: PolylineId("tracking_route"),
        points: polylinetracking,
        color: Colors.blue,width: 5
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("My location"),
        ),
        body: position == null
            ? Center(child: CircularProgressIndicator(),)
            : GoogleMap(
          onMapCreated: onMapcreate,
          initialCameraPosition: CameraPosition(
            target: LatLng(position!.latitude, position!.longitude),
            zoom: 16.0,
          ),
          markers: createMarker(),
        polylines: polyline,
        onTap: _onMapTapped,)
    );
  }
}
