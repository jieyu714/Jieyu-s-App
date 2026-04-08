import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:jieyu_app/utils/ProgressDialog.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {

  bool _isLoading = false;
  String _locationMessage = "點擊圖標獲取位置";

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      ProgressDialog().showLoading(context, title: "獲取位置中...", message: "請稍候...");
    });
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw "定位服務未啟用，請開啟定位服務";
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw "定位權限被拒絕，無法取得位置";
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw "定位權限被永久拒絕，無法取得位置";
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 10),
        ),
      );

      setState(() {
        _locationMessage = "時間: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}";
        _locationMessage += "\n經度: ${position.longitude}\n緯度: ${position.latitude}";
      });
    } catch (e) {
      setState(() {
        _locationMessage = "無法取得位置: $e";
      });
    } finally {
      setState(() {
        ProgressDialog().hide(context);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("地點"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_locationMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                if (!_isLoading) {
                  _getCurrentLocation();
                }
              },
              child: Icon(Icons.location_on, size: 100, color: Colors.red)
            ),
          ],
        ),
      ),
    );
  }
}