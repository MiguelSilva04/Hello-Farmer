import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class StoreLocation {
  final LatLng position;
  final String description;
  late AuthNotifier authProvider;

  StoreLocation({required this.position, required this.description});
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? _currentPosition;

  Set<Marker> get _markers {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    final producers = authNotifier.producerUsers;

    final markers = <Marker>{};
    int markerId = 0;

    for (final producer in producers) {
      for (final store in producer.stores) {
        final coords = store.coordinates;
        if (coords != null) {
          markers.add(
            Marker(
              markerId: MarkerId('producer_store_$markerId'),
              position: coords,
              infoWindow: InfoWindow(
                title: store.name,
                snippet: store.description ?? 'Loja do produtor',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
            ),
          );
          markerId++;
        }
      }
    }

    return markers;
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
    Provider.of<AuthNotifier>(context, listen: false).loadAllUsers();
  }

  Future<void> _determinePosition() async {
    var status = await Permission.location.request();

    if (status.isGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ).timeout(const Duration(seconds: 10));

        if (mounted) {
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao obter localização: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissão de localização negada.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _currentPosition == null
        ? const Center(child: CircularProgressIndicator())
        : GoogleMap(
          onMapCreated: (controller) {},
          initialCameraPosition: CameraPosition(
            target: _currentPosition!,
            zoom: 15,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: _markers,
        );
  }
}
