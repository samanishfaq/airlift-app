import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class CustomGoogleMap extends StatefulWidget {
  final LatLng? destination;
  final bool showPolyline;

  const CustomGoogleMap({
    super.key,
    this.destination,
    this.showPolyline = false,
  });

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  final Completer<GoogleMapController> _controller = Completer();
  final Location _location = Location();

  LatLng? currentLocation;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  String? _mapStyle;

  static const LatLng defaultLocation = LatLng(28.4202, 70.2950);

  final PolylinePoints polylinePoints = PolylinePoints(
    apiKey: "AIzaSyB9mKzXeEcTfsM59wggm6uQeYeMtT-P9vg",
  );

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _initLocation();
  }

  // 🔁 VERY IMPORTANT: updates when destination changes
  @override
  void didUpdateWidget(covariant CustomGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.destination != oldWidget.destination) {
      _updateMarkersAndRoute();
    }
  }

  Future<void> _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assests/mapstyle/darktheme.json');
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
    }

    if (permission != PermissionStatus.granted) return;

    final loc = await _location.getLocation();
    currentLocation = LatLng(loc.latitude!, loc.longitude!);

    _updateMarkersAndRoute();
  }

  Future<void> _updateMarkersAndRoute() async {
    if (currentLocation == null) return;

    markers.clear();
    polylines.clear();

    // Current location marker
    markers.add(
      Marker(
        markerId: const MarkerId("current"),
        position: currentLocation!,
        infoWindow: const InfoWindow(title: "Your Location"),
      ),
    );

    // Destination marker
    if (widget.destination != null) {
      markers.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: widget.destination!,
          infoWindow: const InfoWindow(title: "Destination"),
        ),
      );

      if (widget.showPolyline) {
        await _drawRoute();
      }
    }

    if (mounted) setState(() {});
  }

  Future<void> _drawRoute() async {
    if (currentLocation == null || widget.destination == null) return;

    final result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(
          currentLocation!.latitude,
          currentLocation!.longitude,
        ),
        destination: PointLatLng(
          widget.destination!.latitude,
          widget.destination!.longitude,
        ),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          color: Colors.blue,
          width: 5,
          points: result.points
              .map((e) => LatLng(e.latitude, e.longitude))
              .toList(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: defaultLocation,
        zoom: 14,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      markers: markers,
      polylines: polylines,
      onMapCreated: (controller) {
        controller.setMapStyle(_mapStyle);
        _controller.complete(controller);
      },
    );
  }
}
