import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../models/route_model.dart';

class RouteMapScreen extends StatefulWidget {
  final RouteModel route;
  const RouteMapScreen({super.key, required this.route});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  late GoogleMapController _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setupMap();
  }

  void _setupMap() {
    final markIn = LatLng(widget.route.markInLat, widget.route.markInLng);
    final markOut = LatLng(widget.route.markOutLat, widget.route.markOutLng);

    _markers = {
      Marker(
        markerId: const MarkerId('mark_in'),
        position: markIn,
        infoWindow: InfoWindow(title: 'Mark In', snippet: widget.route.markInTime),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('mark_out'),
        position: markOut,
        infoWindow: InfoWindow(title: 'Mark Out', snippet: widget.route.markOutTime),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: [markIn, markOut],
        color: AppColors.primary,
        width: 4,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final markIn = LatLng(widget.route.markInLat, widget.route.markInLng);
    final markOut = LatLng(widget.route.markOutLat, widget.route.markOutLng);

    // Center camera between both points
    final centerLat = (markIn.latitude + markOut.latitude) / 2;
    final centerLng = (markIn.longitude + markOut.longitude) / 2;

    return Scaffold(
      appBar: AppBar(
        title: Text('Route - ${widget.route.date}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Summary bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: AppColors.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _infoItem(Icons.login, 'In', widget.route.markInTime, AppColors.success),
                _infoItem(Icons.logout, 'Out', widget.route.markOutTime, Colors.red.shade200),
                if (widget.route.distanceKm != null)
                  _infoItem(Icons.straighten, 'Distance',
                      '${widget.route.distanceKm!.toStringAsFixed(1)} km', Colors.white),
              ],
            ),
          ),

          // Map
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(centerLat, centerLng),
                zoom: 13,
              ),
              markers: _markers,
              polylines: _polylines,
              onMapCreated: (controller) => _mapController = controller,
              myLocationButtonEnabled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}