import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jieyu_app/api/BaseApi.dart';
import 'package:jieyu_app/api/InvoiceApi.dart';
import 'package:jieyu_app/constants/Index.dart';
import 'package:jieyu_app/utils/CustomTextField.dart';
import 'package:jieyu_app/utils/ProgressDialog.dart';
import 'package:jieyu_app/utils/SecurityStorageService.dart';

class WinningInvoiceFragment extends StatefulWidget {
  const WinningInvoiceFragment({super.key});

  @override
  State<WinningInvoiceFragment> createState() => _WinningInvoiceFragmentState();
}

class _WinningInvoiceFragmentState extends State<WinningInvoiceFragment> with AutomaticKeepAliveClientMixin {
  String _selectedPeriod = "";
  bool _isLoading = false;
  String _permission = "user";

  @override
  bool get wantKeepAlive => true;

  final Map<String, Map<String, dynamic>> _awardConfig = {
    '特別獎': {'color': Colors.redAccent, 'amount': 10000000},
    '特獎': {'color': Colors.orangeAccent, 'amount': 2000000},
    '頭獎': {'color': Colors.blueAccent, 'amount': 200000},
    '增開六獎': {'color': Colors.blueGrey, 'amount': 200},
  };

  final InvoiceApi _api = InvoiceApi();

  List<dynamic> _systemWinningNumbers = [];
  List<dynamic> _userWinningNumbers = [];
  Map<String, Map<String, List<String>>> _groupedSystemWinningNumbers = {};

  Future<void> fetchWinningNumbers() async {
    ProgressDialog().showLoading(context, message: "獲取中獎號碼中...", minDuration: 2);
    setState(() => _isLoading = true);
    
    try {
      _systemWinningNumbers = (await _api.getSystemWinningNumbers()).data ?? [];
      _userWinningNumbers = (await _api.getUserWinningNumbers()).data ?? [];

      Map<String, Map<String, List<String>>> tempGrouped = {};
      for (var item in _systemWinningNumbers) {
        String period = item['period'] ?? '未知期別';
        String awardType = item['awardType'] ?? '未知獎項';
        String number = item['number'] ?? '';
        
        if (!tempGrouped.containsKey(period)) {
          tempGrouped[period] = {};
          _selectedPeriod = max(int.parse(_selectedPeriod.isEmpty ? "0" : _selectedPeriod), int.parse(period)).toString();
        }
        if (!tempGrouped[period]!.containsKey(awardType)) {
          tempGrouped[period]![awardType] = [];
        }
        tempGrouped[period]![awardType]!.add(number);
      }

      setState(() {
        debugPrint(_groupedSystemWinningNumbers.toString());
        _groupedSystemWinningNumbers = tempGrouped;
      });

      if (!mounted) return;
      ProgressDialog().hide(context);
    } on ApiResponse catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      debugPrint(e.toString());
      ProgressDialog().showResult(context, message: "伺服器錯誤，請稍後再試", isError: true);
    }

    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      fetchWinningNumbers();
      _permission = (await SecurityStorageService().readData(SecurityStorageServiceConstant.PERMISSION))!;
      debugPrint("User permission: $_permission");
    });
  }

  Widget _buildUserWinningCard() {
    List<dynamic> currentPeriodWinningNumbers = _userWinningNumbers.where((item) => item['period'] == _selectedPeriod).toList();
    if (currentPeriodWinningNumbers.isEmpty) {
      return SizedBox.shrink();
    }

    int totalPrize = currentPeriodWinningNumbers.fold(0, (sum, item) => sum + (item['prizeAmount'] as int));

    return TweenAnimationBuilder<double>(
      key: ValueKey(_selectedPeriod),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          )
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFF5F6D),
              Color(0xFFFFC371)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: Offset(0, 5)
            )
          ]
        ),
        child: Column(
          children: [
            Icon(Icons.stars, color: Colors.white, size: 48),
            SizedBox(height: 12),
            Text(
              "太幸運了！本期您中獎了",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold
              )
            ),
            SizedBox(height: 8),
            Text(
              "NT\$ ${totalPrize.toString()}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold
              )
            ),
            Divider(color: Colors.white54, height: 30),
            Column(
              children: _userWinningNumbers.map((inv) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${inv['number']} (${inv['prizeType']})",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                      Text(
                        "+ \$${inv['prizeAmount']}",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500
                        ),
                      )
                    ]
                  )
                );
              }).toList()
            )
          ]
        )
      )
    );
  }

  Widget _buildPrizeCard(String title, List<String> numbers, int amount, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: color,
              width: 8
            )
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey
              )
            ),
            SizedBox(height: 10),
            ...List.generate(numbers.length, (index) {
              return Text(
                numbers[index],
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold, 
                  color: color, 
                  letterSpacing: 4
                )
              );
            }),
            Divider(height: 1),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "獎金 NT\$ ${amount.toString()}",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudPrizeInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_done,
            color: Colors.blueAccent
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "雲端發票專屬獎將由系統自動對獎完成，若中獎將會另行通知！",
              style: TextStyle(
                color: Colors.blueAccent,
                
                fontWeight: FontWeight.bold
              )
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPeriodSelector() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: Center(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          onChanged: (val) => setState(() => _selectedPeriod = val!),
          items: [
            ...List.generate(_groupedSystemWinningNumbers.keys.length, (index) {
              String period = _groupedSystemWinningNumbers.keys.elementAt(index);
              return DropdownMenuItem(
                value: period,
                child: Text("${period.substring(0, 3)}年 ${period.substring(3, 5)}-${(int.parse(period.substring(3, 5)) + 1).toString().padLeft(2, '0')}月"));
            }),
          ],
        ),
      ),
    );
  }

  List<String> _generatePeriodList() {
    List<String> periods = [];
    for (int year = 100; year <= 200; year++) {
      for (int month = 1; month <= 12; month += 2) {
        periods.add("$year${month.toString().padLeft(2, '0')}");
      }
    }
    return periods;
  }

  void _showEditWinningNumbers() {
    final List<String> allPeriods = _generatePeriodList();
    
    DateTime now = DateTime.now();
    int rocYear = now.year - 1911;
    int targetMonth = (now.month % 2 == 0 ? now.month - 1 : now.month) - 2;
    rocYear = targetMonth <= 0 ? rocYear - 1 : rocYear;
    targetMonth = (targetMonth + 12) % 12;
    String defaultPeriod = "$rocYear${targetMonth.toString().padLeft(2, '0')}";

    int initialIndex = allPeriods.indexOf(defaultPeriod);
    if (initialIndex == -1) initialIndex = allPeriods.length - 1;

    String tempPeriod = allPeriods[initialIndex];
    
    final Map<String, List<TextEditingController>> awardControllers = {
      '特別獎': [TextEditingController()],
      '特獎': [TextEditingController()],
      '頭獎': [TextEditingController(), TextEditingController(), TextEditingController()],
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (builderContext) {
        return StatefulBuilder(
          builder: (BuildContext dialogContext, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("管理員批次編輯", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 15),
                    SizedBox(
                      height: 100,
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: initialIndex),
                        itemExtent: 35,
                        onSelectedItemChanged: (index) => tempPeriod = allPeriods[index],
                        children: allPeriods.map((p) => Center(child: Text("${p.substring(0, 3)}年 ${p.substring(3)}月"))).toList(),
                      ),
                    ),
                    Divider(),
                    ...awardControllers.entries.expand((entry) {
                      String awardName = entry.key;
                      return entry.value.asMap().entries.map((item) {
                        int idx = item.key;
                        TextEditingController controller = item.value;
                        
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: CustomTextField(
                            labelText: "$awardName ${awardName == '頭獎' ? (idx + 1) : ''}",
                            controller: controller,
                            textInputType: TextInputType.number,
                            maxLength: 8,
                            // 增加視覺提示顏色
                            icon : Icons.confirmation_number
                          ),
                        );
                      });
                    }),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          for (var controllers in awardControllers.values) {
                            for (var c in controllers) {
                              if (!RegExp(r"^\d{8}$").hasMatch(c.text)) {
                                ProgressDialog().showResult(context, message: "所有獎項均需輸入8位數字", isError: true);
                                return;
                              }
                            }
                          }
                          await _saveAllWinningNumbers(tempPeriod, awardControllers);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("儲存本期所有號碼", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveAllWinningNumbers(String targetPeriod, Map<String, List<TextEditingController>> controllers) async {
    try {
      ProgressDialog().showLoading(context, message: "更新中...", minDuration: 2);
      Navigator.pop(context); 

      Map<String, List<String>> batchData = {};
      
      controllers.forEach((awardType, controllersList) {
        batchData[awardType] = controllersList
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList();
      });

      await _api.updateWinningNumbers(targetPeriod, batchData);
      
      if (!mounted) return;
      setState(() => _selectedPeriod = targetPeriod);
      ProgressDialog().showResult(context, message: "號碼已同步完成", isSuccess: true, onClose: () => fetchWinningNumbers());
    } on ApiResponse catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: "伺服器錯誤，請稍後再試", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Column(
            children: [
              if (_groupedSystemWinningNumbers.isNotEmpty) _buildPeriodSelector(),
              if (_userWinningNumbers.isNotEmpty) _buildUserWinningCard(),
              Expanded(
                child: _isLoading 
                  ? Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: EdgeInsets.all(16),
                      children: [
                        if (_groupedSystemWinningNumbers.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              "目前暫無中獎號碼資訊",
                              style: TextStyle(
                                color: Colors.grey
                                )
                              ),
                          )
                        ),
                        if (_groupedSystemWinningNumbers[_selectedPeriod] != null)
                        ..._groupedSystemWinningNumbers[_selectedPeriod]!.entries.map((entry) {
                          String awardType = entry.key;
                          List<String> numbers = entry.value;
                          int amount = _awardConfig[awardType]?['amount'] ?? 0;
                          Color color = _awardConfig[awardType]?['color'] ?? Colors.grey;

                          return _buildPrizeCard(awardType, numbers, amount, color);
                        }),
                        SizedBox(height: 20),
                        _buildCloudPrizeInfo(),
                      ],
                    ),
              ),
            ]
          ),
          if (_permission == "admin" || _permission == "owner") Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () => _showEditWinningNumbers(),
              shape: CircleBorder(),
              backgroundColor: Color.lerp(Theme.of(context).primaryColor, Colors.white, 0.2),
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          )
        ]
      ),
    );
  }
}