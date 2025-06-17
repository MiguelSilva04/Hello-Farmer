import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:harvestly/components/producer/store_page.dart';
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
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  dynamic _selectedStore;

  void _goToStore(LatLng coords) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(coords));
  }

  void _loadMarkers(List producers) {
    final newMarkers = <Marker>{};
    int markerId = 0;

    for (final producer in producers) {
      for (final store in producer.stores) {
        final coords = store.coordinates;
        if (coords != null) {
          newMarkers.add(
            Marker(
              markerId: MarkerId('store_$markerId'),
              position: coords,
              onTap: () {
                setState(() {
                  _selectedStore = store;
                });
                _goToStore(coords);
              },
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen,
              ),
            ),
          );
          markerId++;
        }
      }
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    _loadMarkers(authNotifier.producerUsers);
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
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
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: _currentPosition!,
            zoom: 14,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: _markers,
          onTap: (LatLng position) {
            setState(() {
              _selectedStore = null;
            });
          },
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 20,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child:
                _selectedStore != null
                    ? Card(
                      key: ValueKey(_selectedStore),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Theme.of(context).colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      _selectedStore.imageUrl != null &&
                                              _selectedStore.imageUrl.isNotEmpty
                                          ? NetworkImage(
                                            _selectedStore.imageUrl,
                                          )
                                          : AssetImage(
                                                'assets/images/simpleLogo.png',
                                              )
                                              as ImageProvider,
                                  backgroundColor: Theme.of(context).colorScheme
                                      .secondaryContainer,
                                  onBackgroundImageError: (_, __) {},
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedStore.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_selectedStore.description != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(_selectedStore.description),
                              ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.store),
                                label: const Text('Ver Banca'),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              StorePage(store: _selectedStore),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
