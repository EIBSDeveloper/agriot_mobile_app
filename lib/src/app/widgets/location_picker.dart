// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'location_control.dart';

final LocationController c = Get.put(LocationController());

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  LatLng? _selectedLocation;
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();

    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Location Services Disabled'),
              content: const Text(
                'Please turn on location services to continue.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    Position position = await Geolocator.getCurrentPosition();
    if (c.latitude.value > 0 && c.longitude.value > 0) {
      setState(() {
        _currentLocation = LatLng(c.latitude.value, c.longitude.value);
        _selectedLocation = _currentLocation;
      });
    } else {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _selectedLocation = _currentLocation;
      });
    }

    _getAddressFromLatLng(
      LatLng(_selectedLocation!.latitude, _selectedLocation!.longitude),
    );
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _selectedAddress =
              "${place.name}, ${place.locality}, ${place.country}";
        });
      }
    // ignore: empty_catches
    } catch (e) {
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 14),
      );
    }
  }

  void _onTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _getAddressFromLatLng(location);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20.0),
          topLeft: Radius.circular(20.0),
        ),
        color: Colors.white,
      ),
      padding: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Positioned.fill(
              child:
                  _currentLocation == null
                      ? Center(
                        child: LoadingAnimationWidget.waveDots(
                          color: Get.theme.primaryColor,
                          size: 50,
                        ),
                      )
                      : GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: _currentLocation!,
                          zoom: 14,
                        ),
                        onTap: _onTap,
                        markers: {
                          if (_selectedLocation != null)
                            Marker(
                              markerId: MarkerId('selected-location'),
                              position: _selectedLocation!,
                            ),
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: FloatingActionButton(
                backgroundColor: Colors.blue,
                child: const Icon(Icons.check),
                onPressed: () {
                  if (_selectedLocation != null) {
                    c.latitude.value = _selectedLocation!.latitude;
                    c.longitude.value = _selectedLocation!.longitude;
                    c.address.value = _selectedAddress ?? " ";

                    c.errLatitude.value = "";
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_selectedAddress ?? "Location selected!"),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
              ),
            ),
            if (_selectedAddress != null)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color.fromARGB(255, 0, 163, 38),
                  ),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          _selectedAddress.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void showDialogWithFields(context) {
  showDialog(
    context: context,
    builder: (_) {
      return Material(child: LocationPicker());
    },
  );
}
