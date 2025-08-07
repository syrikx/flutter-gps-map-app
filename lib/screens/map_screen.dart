import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<NaverMapController> _controller = Completer();
  Position? _currentPosition;
  Set<NMarker> _markers = {};
  StreamSubscription<Position>? _positionStreamSubscription;
  
  static const NCameraPosition _defaultLocation = NCameraPosition(
    target: NLatLng(37.5665, 126.9780), // 서울 기본 좌표
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _currentPosition = position;
        _updateMarker(position);
      });
      _moveCamera(position);
    }
  }

  void _startLocationUpdates() {
    _positionStreamSubscription = LocationService.getLocationStream().listen(
      (Position position) {
        setState(() {
          _currentPosition = position;
          _updateMarker(position);
        });
        _moveCamera(position);
      },
      onError: (error) {
        print('Location stream error: $error');
      },
    );
  }

  void _updateMarker(Position position) async {
    final marker = NMarker(
      id: 'current_location',
      position: NLatLng(position.latitude, position.longitude),
      caption: NOverlayCaption(
        text: '현재 위치\n위도: ${position.latitude.toStringAsFixed(4)}, 경도: ${position.longitude.toStringAsFixed(4)}',
      ),
    );
    
    if (_controller.isCompleted) {
      final controller = await _controller.future;
      await controller.clearOverlays();
      await controller.addOverlay(marker);
    }
    
    _markers = {marker};
  }

  Future<void> _moveCamera(Position position) async {
    final NaverMapController controller = await _controller.future;
    final NCameraUpdate cameraUpdate = NCameraUpdate.withParams(
      target: NLatLng(position.latitude, position.longitude),
      zoom: 16.0,
    );
    controller.updateCamera(cameraUpdate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS 위치 지도'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: _currentPosition != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('현재 위치 정보:', 
                           style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('위도: ${_currentPosition!.latitude.toStringAsFixed(6)}'),
                      Text('경도: ${_currentPosition!.longitude.toStringAsFixed(6)}'),
                      Text('정확도: ${_currentPosition!.accuracy.toStringAsFixed(2)}m'),
                    ],
                  )
                : const Text('위치 정보를 가져오는 중...'),
          ),
          Expanded(
            child: NaverMap(
              options: const NaverMapViewOptions(
                indoorEnable: true,
                locationButtonEnable: true,
                consumeSymbolTapEvents: false,
                initialCameraPosition: _defaultLocation,
              ),
              onMapReady: (NaverMapController controller) {
                _controller.complete(controller);
                if (_markers.isNotEmpty) {
                  controller.addOverlayAll(_markers);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}