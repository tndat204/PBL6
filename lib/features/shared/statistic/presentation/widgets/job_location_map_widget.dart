import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pbl6/core/theme/app_pallete.dart';

import '../../domain/entities/statistic.dart';

class JobLocationMapWidget extends StatefulWidget {
  final List<LocationStat> locations;

  const JobLocationMapWidget({super.key, required this.locations});

  @override
  State<JobLocationMapWidget> createState() => _JobLocationMapWidgetState();
}

class _JobLocationMapWidgetState extends State<JobLocationMapWidget> {
  Set<Marker> _markers = {};
  
  // Controller riêng cho Custom Info Window
  final CustomInfoWindowController _customInfoWindowController = CustomInfoWindowController();
  
  static const CameraPosition _defaultLocation = CameraPosition(
    target: LatLng(16.0544, 108.2022),
    zoom: 10,
  );

  @override
  void initState() {
    super.initState();
    if (widget.locations.isNotEmpty) {
      _loadMarkers();
    }
  }

  @override
  void dispose() {
    _customInfoWindowController.dispose();
    super.dispose();
  }

  Future<void> _loadMarkers() async {
    Set<Marker> markers = {};
    for (var loc in widget.locations) {
      try {
        List<Location> locations = await locationFromAddress(loc.location);
        if (locations.isNotEmpty) {
          final latLng = LatLng(locations.first.latitude, locations.first.longitude);
          
          markers.add(
            Marker(
              markerId: MarkerId(loc.location),
              position: latLng,
              // Thay vì dùng InfoWindow mặc định, ta dùng onTap
              onTap: () {
                _customInfoWindowController.addInfoWindow!(
                  _buildCustomInfoWindow(loc), // Hàm vẽ giao diện đẹp ở dưới
                  latLng,
                );
              },
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            ),
          );
        }
      } catch (e) {
        debugPrint("Lỗi Geocoding địa chỉ: ${loc.location} - $e");
      }
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
      // Zoom đến vị trí đầu tiên nếu có
      if (markers.isNotEmpty) {
        // Lưu ý: Lúc này mapController chưa gán vào custom info window controller nên ko animate ngay ở đây được
        // Logic animate sẽ xử lý tốt nhất khi người dùng tương tác hoặc map đã load xong
      }
    }
  }

  // --- HÀM VẼ GIAO DIỆN INFO WINDOW ĐẸP ---
  Widget _buildCustomInfoWindow(LocationStat loc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          // Phần nội dung
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppPallete.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.work, color: AppPallete.primaryColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          loc.location,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${loc.jobCount} việc làm',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Mũi tên tam giác chỉ xuống (Decor cho giống speech bubble)
          // TrianglePainter() là custom class, nhưng để đơn giản ta dùng icon tam giác
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.locations.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _defaultLocation,
              markers: _markers,
              // --- QUAN TRỌNG: Cấu hình Controller ---
              onMapCreated: (GoogleMapController controller) {
                _customInfoWindowController.googleMapController = controller;
              },
              // --- QUAN TRỌNG: Đồng bộ vị trí popup khi map di chuyển ---
              onTap: (position) {
                _customInfoWindowController.hideInfoWindow!();
              },
              onCameraMove: (position) {
                _customInfoWindowController.onCameraMove!();
              },
              
              // --- CẤU HÌNH GESTURES (Để di chuyển được trên Emulator) ---
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true, // Cho phép kéo map
              tiltGesturesEnabled: true,
              rotateGesturesEnabled: true,
              
              // --- QUAN TRỌNG: Fix lỗi không kéo được map khi nằm trong SingleChildScrollView ---
              gestureRecognizers: Set()
                ..add(Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer())),
            ),
            
            // Widget hiển thị Popup đè lên Map
            CustomInfoWindow(
              controller: _customInfoWindowController,
              height: 85, // Chiều cao của popup
              width: 250, // Chiều rộng của popup
              offset: 50, // Khoảng cách từ marker lên popup
            ),

            // Nút tiêu đề góc trên
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map, size: 18, color: AppPallete.primaryColor),
                    SizedBox(width: 6),
                    Text(
                      "Bản Đồ Việc Làm",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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