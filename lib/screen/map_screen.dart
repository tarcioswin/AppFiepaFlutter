import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  final Offset? markerPosition;

  const MapScreen({super.key, this.markerPosition});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TransformationController _controller = TransformationController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
        _zoomToLocation();
    
    });
  }



void _zoomToLocation() {
  final Size viewportSize = MediaQuery.of(context).size;
  final Offset markerPosition = widget.markerPosition!;
  double scale = 2.5; // Adjust the zoom level here

  // Calculate the required translation to center the marker
  // Calculate center points for the marker at the given scale
  double targetCenterX = markerPosition.dx * scale;
  double targetCenterY = markerPosition.dy * scale;

  // Calculate the differences to center these points
  double diffX = viewportSize.width / 2 - targetCenterX;
  double diffY = viewportSize.height / 2 - targetCenterY;

  // Clamp these differences to make sure no part of the map goes out of bounds
  double maxXTranslation = (380 * scale - viewportSize.width);
  double maxYTranslation = (560 * scale - viewportSize.height);

  // Ensure translations do not expose the edges of the map
  double dx = diffX.clamp(-maxXTranslation, 0);
  double dy = diffY.clamp(-maxYTranslation, 0);

  _controller.value = Matrix4.identity()
    ..translate(dx, dy)
    ..scale(scale);
}




  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _controller,
      panEnabled: true,
      boundaryMargin: const EdgeInsets.all(100),
      minScale: 0.1,
      maxScale: 4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'lib/images/Mapa_final.png',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
          ),
          if (widget.markerPosition != null)
            Positioned(
              left: widget.markerPosition!.dx,
              top: widget.markerPosition!.dy,
              child: const Opacity(
                opacity: 0.8,
                child: Icon(Icons.location_pin, color: Colors.red, size: 30),
              ),
            ),
        ],
      ),
    );
  }
}

