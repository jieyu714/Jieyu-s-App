import 'package:flutter/material.dart';
import 'package:jieyu_app/api/BaseApi.dart';
import 'package:jieyu_app/api/InvoiceApi.dart';
import 'package:jieyu_app/utils/CustomTextField.dart';
import 'package:jieyu_app/utils/DateTimePicker.dart';
import 'package:jieyu_app/utils/ProgressDialog.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:barcode_widget/barcode_widget.dart' as bw;

class InvoiceEntryFragement extends StatefulWidget {
  InvoiceEntryFragement({super.key});

  @override
  State<InvoiceEntryFragement> createState() => _InvoiceEntryFragementState();
}

class _InvoiceEntryFragementState extends State<InvoiceEntryFragement> {
  bool _isScannerMode = false;
  
  String? _leftQrPart;
  String? _rightQrPart;
  bool _isProcessing = false;
  bool _showForceSubmit = false;

  final String _carrierCode = "/LANNNHE";
  final InvoiceApi _api = InvoiceApi();

  void _toggleMode() {
    setState(() {
      _isScannerMode = !_isScannerMode;
      _leftQrPart = null;
      _rightQrPart = null;
      _isProcessing = false;
    });
  }

  void _showManualEntrySheet() {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController numController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (builderContext) => StatefulBuilder(
        builder: (dialogContext, setModalState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 25, right: 25, top: 20,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        color: Colors.grey[300]
                      )
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        "手動補登發票",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        )
                      )
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      labelText: "發票號碼",
                      controller: numController,
                      icon: Icons.confirmation_number_outlined,
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      labelText: "消費金額",
                      controller: amountController,
                      textInputType: TextInputType.number,
                      icon: Icons.attach_money,
                    ),
                    SizedBox(height: 20),
                    CustomTextField(
                      labelText: "日期",
                      controller: dateController,
                      readOnly: true,
                      icon: Icons.calendar_today_outlined,
                      onTap: () async {
                        DateTime? picked = await DateTimePicker().selectDate(context, initialDate: selectedDate);
                        if (picked != null) {
                          setState(() {
                            dateController.text = picked.toIso8601String().substring(0, 10);
                            selectedDate = picked;
                          });
                        }
                      }
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (numController.text.isEmpty || amountController.text.isEmpty) {
                            ProgressDialog().showResult(context, message: "請填寫完整資訊", isError: true);
                            return;
                          } else if (!RegExp(r'^[A-Z]{2}\d{8}$').hasMatch(numController.text.toUpperCase())) {
                            ProgressDialog().showResult(context, message: "發票號碼格式錯誤", isError: true);
                            return;
                          }

                          try {
                            _isProcessing = true;
                            Navigator.pop(context);
                            ProgressDialog().showLoading(context, message: "儲存中...", minDuration: 2);

                            await _api.addInvoice(
                              inputType: "manual",
                              number: numController.text.toUpperCase(),
                              amount: double.parse(amountController.text),
                              consumptionDate: dateController.text
                            );

                            if (!mounted) return;
                            ProgressDialog().showResult(context, message: "發票已成功儲存", isSuccess: true);
                          } on ApiResponse catch (e) {
                            if (!mounted) return;
                            ProgressDialog().showResult(context, message: e.message, isError: true);
                          } catch (e) {
                            if (!mounted) return;
                            ProgressDialog().showResult(context, message: "伺服器異常，請聯繫管理員", isError: true);
                          } finally {
                            _isProcessing = false;
                          }
                        },
                        child: Text("確認儲存", style: TextStyle(fontSize: 16)),
                      )
                    ),
                    SizedBox(height: 30),
                  ]
                )
              )
            )
          )
        )
      )
    );
  }

  Map<String, dynamic>? _parseInvoiceData(String rawData) {
    try {
      if (rawData.length < 77) return null;
      String number = rawData.substring(0, 10);

      String rocDate = rawData.substring(10, 17);
      int year = int.parse(rocDate.substring(0, 3)) + 1911;
      int month = int.parse(rocDate.substring(3, 5));
      int day = int.parse(rocDate.substring(5, 7));
      String consumptionDate = "$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";

      String randomCode = rawData.substring(17, 21);

      String hexAmount = rawData.substring(29, 37);
      int amount = int.parse(hexAmount, radix: 16);

      String buyerTaxId = rawData.substring(37, 45);
      String sellerTaxId = rawData.substring(45, 53);
      String encryptCode = rawData.substring(53, 77);

      return {
        "number": number,
        "consumptionDate": consumptionDate,
        "randomCode": randomCode,
        "amount": amount.toDouble(),
        "buyerTaxId": buyerTaxId,
        "sellerTaxId": sellerTaxId,
        "encryptCode": encryptCode,
        "originalInformation": rawData,
      };
    } catch (e) {
      debugPrint("解析錯誤: $e");
      return null;
    }
  }

  void _handleInvoiceSubmit() async {
    if (_leftQrPart == null) return;

    _isProcessing = true;
    setState(() {
      _showForceSubmit = false;
    });

    try {
      ProgressDialog().showLoading(context, message: "儲存中...", minDuration: 2);

      final data = _parseInvoiceData(_leftQrPart!);
      
      _leftQrPart = null;
      _rightQrPart = null;

      await _api.addInvoice(
        inputType: "scan",
        number: data!["number"],
        consumptionDate: data["consumptionDate"],
        amount: data["amount"],
        randomCode: data["randomCode"],
        buyerTaxId: data["buyerTaxId"],
        sellerTaxId: data["sellerTaxId"],
        encryptCode: data["encryptCode"],
        originalInformation: data["originalInformation"],
      );

      if (!mounted) return;
      ProgressDialog().showResult(context, message: "發票 ${data['number']} 儲存成功", isSuccess: true, onClose: () {
        Future.delayed(Duration(seconds: 1), () => _isProcessing = false);
      });
    } on ApiResponse catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: e.message, isError: true, onClose: () {
        Future.delayed(Duration(seconds: 1), () => _isProcessing = false);
      });
    } catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: "系統錯誤", isError: true, onClose: () {
        Future.delayed(Duration(seconds: 1), () => _isProcessing = false);
      });
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: _isScannerMode
              ? Stack(
                  children: [
                    ScannerView(
                      key: ValueKey("scannerView"),
                      onDetected: (code) async {
                        if (_isProcessing) return;
                        bool isLeft = _parseInvoiceData(code) != null;
                        bool isRight = code.startsWith('**');
                        
                        if (_leftQrPart == null && isLeft) {
                          _leftQrPart = code;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("已讀取主資訊，請掃描右邊的QR Code"),
                              duration: Duration(seconds: 1)
                            ),
                          );
                          setState(() {
                            _showForceSubmit = true;
                          });
                          return;
                        } else if (_leftQrPart != null && isRight) {
                          _rightQrPart = code;
                        } else {
                          return;
                        }

                        _handleInvoiceSubmit();
                      }
                    ),
                    if (_showForceSubmit) Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleInvoiceSubmit(),
                          icon: Icon(Icons.send_rounded),
                          label: Text(
                            "右側QR CODE掃不到？直接儲存",
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            )
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: StadiumBorder(),
                            elevation: 8,
                          ),
                        ),
                      ),
                    ),
                  ]
                ) : _buildBarcodeView(key: ValueKey("barcodeView"))
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: Offset(0, -5),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _toggleMode,
                  icon: Icon(_isScannerMode ? Icons.qr_code_2 : Icons.camera_alt),
                  label: Text(
                    _isScannerMode ? "顯示載具條碼" : "開啟相機掃描",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isScannerMode 
                        ? Colors.grey[200] 
                        : Theme.of(context).primaryColor,
                    foregroundColor: _isScannerMode 
                        ? Colors.black87 
                        : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                ),
              ),
              AnimatedSize(
                duration: Duration(milliseconds: 300),
                child: _isScannerMode
                    ? Column(
                        children: [
                          SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCircleAction(Icons.edit_note, "手動補登", () {
                                _showManualEntrySheet();
                              }),
                              _buildCircleAction(Icons.history, "最近掃描", () {
                                // TODO: 跳轉至列表頁
                              }),
                            ],
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarcodeView({required Key key}) {
    return Container(
      key: key,
      width: double.infinity,
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("我的發票載具", 
            style: TextStyle(fontSize: 16, color: Colors.grey, letterSpacing: 1.2)),
          SizedBox(height: 30),
          bw.BarcodeWidget(
            barcode: bw.Barcode.code39(),
            data: _carrierCode,
            width: 300,
            height: 100,
            drawText: false,
          ),
          SizedBox(height: 15),
          Text(
            _carrierCode,
            style: TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Icon(icon, color: Theme.of(context).primaryColor, size: 28),
            ),
            SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          ],
        ),
      ),
    );
  }
}

class ScannerView extends StatefulWidget {
  final Function(String) onDetected;
  ScannerView({super.key, required this.onDetected});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  late MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      formats: [BarcodeFormat.qrCode]
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
              widget.onDetected(barcodes.first.rawValue!);
            }
          },
        ),
        _buildOverlay(context),
        Positioned(
          top: 20,
          right: 20,
          child: CircleAvatar(
            backgroundColor: Colors.black26,
            child: IconButton(
              icon: Icon(Icons.flash_on, color: Colors.white),
              onPressed: () => _scannerController.toggleTorch(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: Theme.of(context).primaryColor,
          borderRadius: 12,
          borderLength: 30,
          borderWidth: 8,
          cutOutSize: 260,
        ),
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderRadius;
  final double borderLength;
  final double borderWidth;
  final double cutOutSize;

  QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderRadius = 10,
    this.borderLength = 30,
    this.borderWidth = 10,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path()..addRect(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final cutOutRect = Rect.fromCenter(
      center: Offset(width / 2, height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius))),
      ),
      paint,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path()
      ..moveTo(cutOutRect.left, cutOutRect.top + borderLength)
      ..lineTo(cutOutRect.left, cutOutRect.top + borderRadius)
      ..arcToPoint(Offset(cutOutRect.left + borderRadius, cutOutRect.top), radius: Radius.circular(borderRadius))
      ..lineTo(cutOutRect.left + borderLength, cutOutRect.top)

      ..moveTo(cutOutRect.right - borderLength, cutOutRect.top)
      ..lineTo(cutOutRect.right - borderRadius, cutOutRect.top)
      ..arcToPoint(Offset(cutOutRect.right, cutOutRect.top + borderRadius), radius: Radius.circular(borderRadius))
      ..lineTo(cutOutRect.right, cutOutRect.top + borderLength)

      ..moveTo(cutOutRect.right, cutOutRect.bottom - borderLength)
      ..lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius)
      ..arcToPoint(Offset(cutOutRect.right - borderRadius, cutOutRect.bottom), radius: Radius.circular(borderRadius))
      ..lineTo(cutOutRect.right - borderLength, cutOutRect.bottom)

      ..moveTo(cutOutRect.left + borderLength, cutOutRect.bottom)
      ..lineTo(cutOutRect.left + borderRadius, cutOutRect.bottom)
      ..arcToPoint(Offset(cutOutRect.left, cutOutRect.bottom - borderRadius), radius: Radius.circular(borderRadius))
      ..lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}