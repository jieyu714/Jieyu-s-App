import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
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

  String _convertToDMS(double decimal, {required bool isLatitude}) {
      final direction = isLatitude
          ? (decimal >= 0 ? 'N' : 'S')
          : (decimal >= 0 ? 'E' : 'W');
      decimal = decimal.abs();
      final degrees = decimal.floor();
      final minutesDecimal = (decimal - degrees) * 60;
      final minutes = minutesDecimal.floor();
      final seconds = ((minutesDecimal - minutes) * 60).toStringAsFixed(2);
      return "$degrees°$minutes'$seconds\" $direction";
    }

    double _getDynamicTaiwanOffset(double latitude) {
      // 根據緯度動態修正台灣地區的海拔偏移量
      // 台灣北部約 -30m，南部約 -50m，中央約 -40m
      if (latitude >= 24.5) {
        return 30.0; // 北部
      } else if (latitude <= 21.5) {
        return 50.0; // 南部
      } else {
        return 40.0; // 中央
      }
    }

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

      // 1. 獲取最高精度位置 (Best For Navigation)
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (!mounted) return;

      // 2. 逆向地理編碼 (座標轉地址)
      String address = "未知地點";
      try {
        // localeIdentifier 設定為 zh_TW 確保回傳繁體中文
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, 
          position.longitude, 
        );
        if (placemarks.isNotEmpty) {
          Placemark p = placemarks[0];
          // 組合地址：縣市 + 行政區 + 道路
          address = "${p.administrativeArea}${p.locality}${p.street}";
        }
      } catch (e) {
        address = "無法解析地址 (可能無網路)";
      }

      // 3. 執行高度與座標格式化
      final String time = DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now());
      final String dmsLat = _convertToDMS(position.latitude, isLatitude: true);
      final String dmsLng = _convertToDMS(position.longitude, isLatitude: false);
      
      // 動態修正海拔
      double offset = _getDynamicTaiwanOffset(position.latitude);
      double mslAlt = position.altitude - offset;

      // 4. 更新 UI
      setState(() {
        _locationMessage = "時間: $time";
        _locationMessage += "\n座標: $dmsLat $dmsLng";
        _locationMessage += "\n海拔: ${mslAlt.toStringAsFixed(1)} m (±${position.altitudeAccuracy.toStringAsFixed(1)}m)";
        _locationMessage += "\n(原始 WGS84: ${position.altitude.toStringAsFixed(1)} m)";
        _locationMessage += "\n地點: $address";
      });
      print("位置獲取成功: $_locationMessage");

    } catch (e) {
      setState(() => _locationMessage = "定位失敗: $e");
    } finally {
      setState(() => _isLoading = false);
      ProgressDialog().hide(context);
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