import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main.dart';

class LocationResult {
  final LatLng latLng;
  final String address;

  const LocationResult({required this.latLng, required this.address});
}

class MapLocationPicker extends StatefulWidget {
  const MapLocationPicker({super.key});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  final MapController _mapController = MapController();

  // Default: Pakistan center
  LatLng _selectedLocation = const LatLng(30.3753, 69.3451);
  String _selectedAddress = 'Tap on map to select location';
  bool _isLoadingAddress = false;
  bool _isLoadingGPS = false;

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Nominatim se reverse geocoding
  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _isLoadingAddress = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json',
      );
      final response = await http.get(url, headers: {'Accept-Language': 'en'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _selectedAddress = data['display_name'] ?? 'Unknown location';
        });
      }
    } catch (_) {
      setState(() => _selectedAddress = 'Could not fetch address');
    } finally {
      setState(() => _isLoadingAddress = false);
    }
  }

  /// Nominatim se search
  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5',
      );
      final response = await http.get(url, headers: {'Accept-Language': 'en'});
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _searchResults = data.map((e) => {
            'display_name': e['display_name'],
            'lat': double.parse(e['lat']),
            'lon': double.parse(e['lon']),
          }).toList();
        });
      }
    } catch (_) {
      setState(() => _searchResults = []);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  /// GPS se current location
  Future<void> _goToCurrentLocation() async {
    setState(() => _isLoadingGPS = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnack('Location services are disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnack('Location permission denied');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnack('Location permission permanently denied');
        return;
      }

      final pos = await Geolocator.getCurrentPosition();
      final point = LatLng(pos.latitude, pos.longitude);
      setState(() => _selectedLocation = point);
      _mapController.move(point, 15);
      await _reverseGeocode(point);
    } catch (e) {
      _showSnack('Could not get location');
    } finally {
      setState(() => _isLoadingGPS = false);
    }
  }

  void _showSnack(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _onMapTap(TapPosition _, LatLng point) {
    setState(() {
      _selectedLocation = point;
      _searchResults = [];
      _searchController.clear();
    });
    _reverseGeocode(point);
  }

  void _selectSearchResult(Map<String, dynamic> result) {
    final point = LatLng(result['lat'], result['lon']);
    setState(() {
      _selectedLocation = point;
      _selectedAddress = result['display_name'];
      _searchResults = [];
      _searchController.text = result['display_name'];
    });
    _mapController.move(point, 15);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ModernAppBar(title: 'Select Location'),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 6,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.f_y_p',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 48,
                    height: 48,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 48,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Search bar
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search location...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchResults = []);
                                  },
                                )
                              : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (v) => _searchLocation(v),
                  ),
                ),

                // Search results dropdown
                if (_searchResults.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final r = _searchResults[i];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.place_outlined, size: 20),
                          title: Text(
                            r['display_name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          onTap: () => _selectSearchResult(r),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // GPS button
          Positioned(
            right: 12,
            bottom: 140,
            child: FloatingActionButton.small(
              heroTag: 'gps',
              backgroundColor: Theme.of(context).colorScheme.surface,
              onPressed: _isLoadingGPS ? null : _goToCurrentLocation,
              child: _isLoadingGPS
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, color: AppTheme.primaryColor),
            ),
          ),

          // Bottom address card + confirm button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Selected Location',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const Spacer(),
                      if (_isLoadingAddress)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedAddress,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  GradientButton(
                    text: 'Confirm Location',
                    icon: Icons.check_circle_outline,
                    width: double.infinity,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    onPressed: () {
                      Navigator.pop(
                        context,
                        LocationResult(
                          latLng: _selectedLocation,
                          address: _selectedAddress,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
