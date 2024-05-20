// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart'
    hide Colors; // Corrected import

class MapScreen extends StatefulWidget {
  final Offset? markerPosition;

  const MapScreen({super.key, this.markerPosition});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final TransformationController _controller = TransformationController();
  final double _zoomInFactor = 2.5;

  AnimationController? _blinkController;
  Animation<double>? _blinkAnimation;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
      // Repeats the animation forward and then in reverse
      animationBehavior: AnimationBehavior.preserve,
    )..repeat(reverse: true);

    _blinkAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_blinkController!);

    // Ensure the map is centered on the marker position after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _zoomToLocation();
    });
  }

  @override
  void dispose() {
    _blinkController?.dispose();
    super.dispose();
  }

  // Handles double tap to zoom in at the center of the current view.
  void _onDoubleTapDown(TapDownDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition =
        renderBox.globalToLocal(details.globalPosition);

    // Get the current scale and calculate the new scale
    final double currentScale = _controller.value.getMaxScaleOnAxis();
    final double newScale = currentScale * _zoomInFactor;

    // Calculate the focal point for the new scale
    final Matrix4 transformationMatrix = _controller.value.clone();
    final Vector3 translation = transformationMatrix.getTranslation();

    // Shift the center of the viewport to the tap location
    final double centerX = localPosition.dx;
    final double centerY = localPosition.dy;

    // Adjust the matrix to center on the tap location and scale
    transformationMatrix.setIdentity();
    transformationMatrix.translate(
        translation.x +
            (centerX - translation.x) -
            (centerX - translation.x) * _zoomInFactor,
        translation.y +
            (centerY - translation.y) -
            (centerY - translation.y) * _zoomInFactor);
    transformationMatrix.scale(newScale);

    // Apply the new transformation
    _controller.value = transformationMatrix;
  }

  // Zoom to the initial location based on the marker position.
  void _zoomToLocation() {
    if (widget.markerPosition == null) return;

    final Size viewportSize = MediaQuery.of(context).size;
    final Offset markerPosition = widget.markerPosition!;
    double scale = 1.5;

    // Calculate target center positions scaled by 'scale'
    double targetCenterX = markerPosition.dx * scale;
    double targetCenterY = markerPosition.dy * scale;

    // Calculate differences from viewport center
    double diffX = viewportSize.width / 2 - targetCenterX;
    double diffY = viewportSize.height / 2 - targetCenterY;

    // Dynamic translation limits based on the viewport and map dimensions
    double mapWidth = viewportSize.width *
        scale; // Assuming the map width scales with the viewport
    double mapHeight = viewportSize.height *
        scale; // Assuming the map height scales with the viewport

    // Calculate maximum translations
    double maxXTranslation = mapWidth - viewportSize.width;
    double maxYTranslation = mapHeight - viewportSize.height;

    // Apply clamping to ensure the map edges do not go beyond the viewport edges
    double clampedX = diffX.clamp(-maxXTranslation, 0);
    double clampedY = diffY.clamp(-maxYTranslation, 0);

    _controller.value = Matrix4.identity()
      ..translate(clampedX, clampedY, 0)
      ..scale(scale);
  }

  // Calculate vertical adjustment for marker position based on screen height and marker's dy.
  double calculateYAdjustment(double screenHeight, double markerDy) {
    if (screenHeight < 550) {
      if (markerDy > 530) {
        return -47;
      } else if (markerDy > 420)
        return -40;
      else if (markerDy > 250)
        return -35;
      else if (markerDy > 120)
        return -20;
      else
        return -20; // Default for very low dy values or unspecified conditions
    } else if (screenHeight >= 550 && screenHeight < 650) {
      if (markerDy > 530) {
        return -35;
      } else if (markerDy > 420)
        return -30;
      else if (markerDy > 250)
        return -30;
      else if (markerDy > 120)
        return -14;
      else
        return -10; // Default for very low dy values or unspecified conditions
    } else if (screenHeight >= 650 && screenHeight < 750) {
      if (markerDy > 530) {
        return -20;
      } else if (markerDy > 420)
        return -20;
      else if (markerDy > 250)
        return -10;
      else if (markerDy > 120)
        return -14;
      else
        return -10; // Default for very low dy values or unspecified conditions
    } else if (screenHeight >= 750 && screenHeight < 880) {
      return 2;
    } else {
      return 10; // Default for larger screens
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    double baseWidth = 411;
    double baseHeight = 866;
    double xProportion = (widget.markerPosition?.dx ?? 0) / baseWidth;
    double yProportion = (widget.markerPosition?.dy ?? 0) / baseHeight;

    double yAdjustment =
        calculateYAdjustment(screenSize.height, widget.markerPosition?.dy ?? 0);

    return GestureDetector(
      onDoubleTapDown: _onDoubleTapDown,
      child: InteractiveViewer(
        transformationController: _controller,
        panEnabled: true,
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.1,
        maxScale: 4,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'lib/images/Mapa.png',
              width: screenSize.width,
              height: screenSize.height,
              fit: BoxFit.fill,
            ),
            if (widget.markerPosition != null)
              Positioned(
                left: xProportion * screenSize.width,
                top: yProportion * screenSize.height + yAdjustment,
                child: FadeTransition(
                  opacity: _blinkAnimation!,
                  child: const Icon(Icons.location_pin,
                      color: Colors.red, size: 30),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
