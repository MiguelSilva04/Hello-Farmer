import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:harvestly/core/models/store.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'package:image_picker/image_picker.dart';

import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

// ignore: must_be_immutable
class CreateStore extends StatefulWidget {
  bool? isFirstTime;
  CreateStore({super.key, this.isFirstTime});

  @override
  State<CreateStore> createState() => _CreateStoreState();
}

class _CreateStoreState extends State<CreateStore> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final sloganController = TextEditingController();
  final descriptionController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  final municipalityController = TextEditingController();
  String? backgroundImageUrl;
  String? imageUrl;
  List<DeliveryMethod> selectedDeliveryMethods = [];

  final allDeliveryMethods = DeliveryMethod.values;
  File? _imageFile;
  File? _backgroundImageFile;
  LatLng? coordinates;
  bool _isLoading = false;

  Future<void> _pickImage({required bool isBackground}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isBackground) {
          _backgroundImageFile = File(pickedFile.path);
        } else {
          _imageFile = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> submitStore() async {
    setState(() {
      _isLoading = true;
    });
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Formulário inválido.')));
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imagem principal não selecionada.')),
      );
      return;
    }

    if (_backgroundImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imagem de fundo não selecionada.')),
      );
      return;
    }

    if (coordinates == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Localização não selecionada.')));
      return;
    }

    if (selectedDeliveryMethods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhum método de entrega selecionado.')),
      );
      return;
    }
    try {
      await AuthService().addStore(
        name: nameController.text.trim(),
        subName: sloganController.text.trim(),
        description: descriptionController.text.trim(),
        city: cityController.text.trim(),
        municipality: municipalityController.text.trim(),
        address: addressController.text.trim(),
        imageFile: _imageFile!,
        backgroundImageFile: _backgroundImageFile!,
        deliveryMethods:
            selectedDeliveryMethods.map((m) => m.toDisplayString()).toList(),
        coordinates: coordinates!,
      );
    } catch (e) {
      print(e);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Criação de Banca",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
            ),
            if (widget.isFirstTime == true) ...[
              const SizedBox(height: 10),
              Text(
                "Ainda não tem nenhuma banca criada, preencha os dados abaixo para começar a usar a aplicação!",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            _buildTextField("Nome", nameController, validator: true),
            _buildTextField("Slogan", sloganController),
            _buildTextField(
              "Descrição",
              descriptionController,
              maxLines: 3,
              validator: true,
            ),
            _buildTextField(
              "Cidade",
              cityController,
              validator: true,
              enabled: false,
            ),
            _buildTextField(
              "Município",
              municipalityController,
              validator: true,
              enabled: false,
            ),
            _buildTextField(
              "Morada",
              addressController,
              validator: true,
              enabled: false,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.map),
              label: const Text("Selecionar Localização no Mapa"),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => MapPageProducer(
                          onLocationSelected: (position, placemark) {
                            setState(() {
                              coordinates = position;
                              addressController.text = placemark.street ?? '';
                              cityController.text = placemark.locality ?? '';
                              municipalityController.text =
                                  placemark.subAdministrativeArea ?? '';
                            });
                          },
                        ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            Text(
              "Foto da banca:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _imageFile != null
                ? Image.file(_imageFile!, height: 150)
                : Text("Nenhuma imagem selecionada."),
            if (_imageFile == null)
              TextButton.icon(
                onPressed: () => _pickImage(isBackground: false),
                icon: Icon(Icons.image),
                label: Text("Selecionar imagem principal"),
              ),

            const SizedBox(height: 16),
            Text(
              "Foto de fundo:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _backgroundImageFile != null
                ? Image.file(_backgroundImageFile!, height: 150)
                : Text("Nenhuma imagem selecionada."),
            if (_backgroundImageFile == null)
              TextButton.icon(
                onPressed: () => _pickImage(isBackground: true),
                icon: Icon(Icons.image_outlined),
                label: Text("Selecionar imagem de fundo"),
              ),
            const SizedBox(height: 20),
            Text(
              "Métodos de entrega preferidos:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              children:
                  allDeliveryMethods.map((method) {
                    final selected = selectedDeliveryMethods.contains(method);
                    return CheckboxListTile(
                      title: Text(method.toDisplayString()),
                      value: selected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            selectedDeliveryMethods.add(method);
                          } else {
                            selectedDeliveryMethods.remove(method);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: submitStore,
                    child: Text("Criar Banca"),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool validator = false,
    int maxLines = 1,
    bool? enabled,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator:
            validator
                ? (val) =>
                    val == null || val.trim().isEmpty
                        ? 'Campo obrigatório'
                        : null
                : null,
      ),
    );
  }
}

class MapPageProducer extends StatefulWidget {
  final Function(LatLng position, Placemark placemark) onLocationSelected;

  const MapPageProducer({super.key, required this.onLocationSelected});

  @override
  State<MapPageProducer> createState() => _MapPageProducerState();
}

class _MapPageProducerState extends State<MapPageProducer> {
  LatLng? _currentPosition;
  Marker? _selectedMarker;

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
        );

        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
      } catch (_) {}
    }
  }

  Future<void> _handleTap(LatLng tappedPoint) async {
    setState(() {
      _selectedMarker = Marker(
        markerId: const MarkerId('selected'),
        position: tappedPoint,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    });

    List<Placemark> placemarks = await placemarkFromCoordinates(
      tappedPoint.latitude,
      tappedPoint.longitude,
    );

    if (placemarks.isNotEmpty) {
      widget.onLocationSelected(tappedPoint, placemarks.first);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Selecionar Localização',
          style: TextStyle(fontSize: 25),
        ),
      ),
      body:
          _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                onMapCreated: (controller) {},
                initialCameraPosition: CameraPosition(
                  target: _currentPosition!,
                  zoom: 15,
                ),
                onTap: _handleTap,
                markers: {if (_selectedMarker != null) _selectedMarker!},
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
    );
  }
}
