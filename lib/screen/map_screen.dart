import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';


class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LatLng topLeftGps = const LatLng(-1.4530233355107522, -48.49105804071296);
  final LatLng bottomRightGps  = const LatLng(-1.4527351437516183, -48.49184892633416);
  final Size mapSize = const Size(380, 740);

  StreamSubscription<Position>? positionStream;
  Offset markerPosition = const Offset(195, 325); // Center of the map as initial position

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    positionStream?.cancel(); // Ensure to cancel the stream to prevent memory leaks
    super.dispose();
  }



Future<void> _startLocationUpdates() async {
  // Check for location service
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are disabled, handle accordingly
    return;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, handle accordingly
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle accordingly
    return;
  }

  // Permissions are granted, proceed with location updates
  positionStream = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3, // Notify for every 10 meters of movement.
    ),
  ).listen((Position position) {
    LatLng currentGpsPosition = LatLng(position.latitude, position.longitude);
    Offset newMarkerPosition = gpsToPixel(currentGpsPosition);

    setState(() {
      markerPosition = newMarkerPosition;
    });

    if (kDebugMode) {
      print('Current GPS Position: Latitude: ${position.latitude}, Longitude: ${position.longitude}');
      print('Marker Position: X: ${newMarkerPosition.dx}, Y: ${newMarkerPosition.dy}');
    }
  });
}




Offset gpsToPixel(LatLng gpsPosition) {
  // Middle of the image in GPS coordinates and its corresponding pixel position
  const LatLng centerGps = LatLng(-1.45288, -48.49146);
  const Offset centerPixel = Offset(170, 320);

  // Calculate scale factors using the distance between the center and top-left/bottom-right GPS points
  double longitudeScale = mapSize.height / 2 / (centerGps.longitude - topLeftGps.longitude);
  double latitudeScale = mapSize.width / 2 / (topLeftGps.latitude - centerGps.latitude);


  // Calculate the pixel offsets from the center point, but swap the application of latitude and longitude scale factors
  double yPixelOffsetFromCenter = (gpsPosition.longitude - centerGps.longitude) * longitudeScale;
  double xPixelOffsetFromCenter = (centerGps.latitude -  gpsPosition.latitude) * latitudeScale;

  // Determine the actual pixel position by adding the offsets to the center pixel position
  // Swap the xPixel and yPixel calculations to reflect the axis inversion
  double yPixel = centerPixel.dy + yPixelOffsetFromCenter;
  double xPixel = centerPixel.dx - xPixelOffsetFromCenter; // Subtract because screen coordinates increase to the right in a standard setup but increase upwards in our inverted setup

   return Offset(mapSize.width-xPixel, mapSize.height -(yPixel));
}






  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      panEnabled: true,
      boundaryMargin: const EdgeInsets.all(80),
      minScale: 0.5,
      maxScale: 4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('lib/images/Mapa.jpg', width: 500, height: 1000),
          Positioned(
            left: markerPosition.dx,
            top: markerPosition.dy,
            child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
          ),
        ],
      ),
    );
  }
}
