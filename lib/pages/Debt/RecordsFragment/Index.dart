import 'package:flutter/material.dart';
import 'package:jieyu_app/api/BaseApi.dart';
import 'package:jieyu_app/api/DebtApi.dart';
import 'package:jieyu_app/utils/CustomDropdownFiled.dart';
import 'package:jieyu_app/utils/CustomTextField.dart';
import 'package:jieyu_app/utils/DateTimePicker.dart';
import 'package:jieyu_app/utils/ProgressDialog.dart';
import 'package:jieyu_app/viewmodels/Record.dart';

class RecordsFragment extends StatefulWidget {
  const RecordsFragment({super.key});

  @override
  State<RecordsFragment> createState() => _RecordsFragmentState();
}

class _RecordsFragmentState extends State<RecordsFragment> with AutomaticKeepAliveClientMixin {
  List<dynamic> _contacts = []; 
  List<dynamic> _records = [];

  final DebtApi _api = DebtApi();

  @override
  bool get wantKeepAlive => true;
  
  void _fetchData() async {
    await ProgressDialog().showLoading(context, minDuration: 2);
    
    try {
      final responseContact = await _api.getContacts();
      final responseRecord = await _api.getRecords();

      if (responseContact.isSuccess && responseRecord.isSuccess) {
        setState(() {
          _contacts = responseContact.data!;
          _records = responseRecord.data!;
        });
        if (!mounted) return;
        ProgressDialog().hide(context);
      } else {
        if (!mounted) return;
        ProgressDialog().showResult(context, message: responseContact.isSuccess ? responseRecord.message : responseContact.message, isError: true);
      }
    } on ApiResponse catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: "伺服器錯誤，請稍後再試", isError: true);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_fetchData);
  }

  void _showRecordDialog({RecordItem? record}) {
    String? selectedContactId = record?.contactId.toString();
    String selectedType = record == null ? 'lend' : record.type;
    String selectedCurrency = record == null ? 'NTD' : record.currency;
    DateTime? transactionDate = record?.transactionDate;
    DateTime? settlementDate = record?.settlementDate;

    final TextEditingController itemController = TextEditingController(text: record?.item);
    final TextEditingController transactionDateController = TextEditingController(text: transactionDate?.toIso8601String().split('T')[0]);
    final TextEditingController amountController = TextEditingController(text: record?.amount.toString());
    final TextEditingController descController = TextEditingController(text: record?.description);
    final TextEditingController paymentMethodController = TextEditingController(text: record?.paymentMethod);
    final TextEditingController settlementDateController = TextEditingController(text: settlementDate?.toIso8601String().split('T')[0]);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (buildContext, setDialogState) {
            return AlertDialog(
              title: Center(
                child: Text("${record == null ? "新增" : "修改"}帳務紀錄")
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomDropdownField<String>(
                      labelText: "往來對象",
                      isRequired: true,
                      value: selectedContactId,
                      items: _contacts.map((c) => c['id'].toString()).toList(),
                      itemLabelBuilder: (id) {
                        final contact = _contacts.firstWhere((c) => c['id'].toString() == id);
                        return "[${contact['group']}] ${contact['name']}";
                      },
                      onChanged: (val) => setDialogState(() => selectedContactId = val),
                    ),
                    SizedBox(height: 15),
                    CustomDropdownField<String>(
                      labelText: "帳務類型",
                      value: selectedType,
                      items: ['lend', 'borrow'],
                      itemLabelBuilder: (val) => val == 'lend' ? "我借給對方" : "我向對方借",
                      onChanged: (val) => setDialogState(() => selectedType = val!),
                    ),
                    SizedBox(height: 15),
                    CustomTextField(
                      labelText: "交易日期",
                      controller: transactionDateController,
                      readOnly: true,
                      isRequird: true,
                      onTap: () async {
                        final DateTime? picked = await DateTimePicker().selectDate(context, initialDate: transactionDate);
                        if (picked != null) {
                          setDialogState(() {
                            transactionDate = picked;
                            transactionDateController.text = picked.toIso8601String().split('T')[0];
                          });
                        }
                      }
                    ),
                    SizedBox(height: 15),
                    CustomTextField(
                      labelText: "項目名稱",
                      controller: itemController,
                      isRequird: true,
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: CustomDropdownField<String>(
                            labelText: "幣別",
                            value: selectedCurrency,
                            items: ['NTD', 'USD', 'JPY'],
                            onChanged: (val) => setDialogState(() => selectedCurrency = val!),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            labelText: "金額",
                            controller: amountController,
                            isRequird: true,
                            textInputType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      labelText: "結清日期",
                      controller: settlementDateController,
                      readOnly: true,
                      onTap: () async {
                        final DateTime? picked = await DateTimePicker().selectDate(context, initialDate: settlementDate);
                        if (picked != null) {
                          settlementDate = picked;
                          setDialogState(() => settlementDateController.text = picked.toIso8601String().split('T')[0]);
                        }
                      },
                    ),
                    SizedBox(height: 15),
                    CustomTextField(
                      labelText: "支付方式",
                      hintText: "例如：現金、LinePay、轉帳",
                      controller: paymentMethodController,
                    ),
                    SizedBox(height: 15),
                    CustomTextField(
                      labelText: "備註",
                      controller: descController,
                      maxLines: null,
                      textInputAction: TextInputAction.newline,
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text("取消")
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedContactId == null || transactionDateController.text.isEmpty || itemController.text.isEmpty || amountController.text.isEmpty) {
                      ProgressDialog().showResult(context, message: "請填寫所有必填欄位", isError: true);
                      return;
                    } else if (!RegExp(r"^\d+$").hasMatch(amountController.text)) {
                      ProgressDialog().showResult(context, message: "金額輸入錯誤", isError: true);
                      return;
                    } else if (settlementDateController.text.isNotEmpty ^ paymentMethodController.text.isNotEmpty) {
                      ProgressDialog().showResult(context, message: "請填寫完整的結清資訊", isError: true);
                      return;
                    }

                    Navigator.pop(dialogContext);
                    if (!mounted) return;
                    ProgressDialog().showLoading(context, title: "${record == null ? "新增" : "更改"}中...", minDuration: 2);
                    debugPrint("開始${record == null ? "新增" : "修改"}紀錄：settledDate=${settlementDate.toString()}");
                    try {
                      if (record == null) {
                        await _api.addRecord(
                          contactId: int.parse(selectedContactId!),
                          transactionDate: transactionDate!,
                          type: selectedType,
                          item: itemController.text,
                          amount: int.parse(amountController.text),
                          currency: selectedCurrency,
                          description: descController.text,
                          paymentMethod: paymentMethodController.text,
                          settlementDate: settlementDate,
                        );
                      } else {
                        await _api.updateRecord(
                          id: record.id!,
                          contactId: int.parse(selectedContactId!),
                          transactionDate: transactionDate!,
                          type: selectedType,
                          item: itemController.text,
                          amount: int.parse(amountController.text),
                          currency: selectedCurrency,
                          description: descController.text,
                          paymentMethod: paymentMethodController.text,
                          settlementDate: settlementDate,
                        );
                      }

                      if (!mounted) return;
                      ProgressDialog().showResult(context, message: "${record == null ? "新增" : "更改"}成功", isSuccess: true, onClose: _fetchData);
                    } on ApiResponse catch (e) {
                      if (!mounted) return;
                      ProgressDialog().showResult(context, message: e.message, isError: true);
                    } catch (e) {
                      if (!mounted) return;
                      debugPrint(e.toString());
                      ProgressDialog().showResult(context, message: "伺服器異常，請聯繫管理員", isError: true);
                    }
                  },
                  child: Text("儲存"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _deleteRecord (
    int id
  ) async {
    try {
      ProgressDialog().showLoading(context, title: "刪除任務中...", minDuration: 2);
      await _api.deleteRecord(
        id: id
      );

      if (!mounted) return;
      ProgressDialog().showResult(context, message: "刪除任務成功", isSuccess: true,
        onClose: () {
          _fetchData();
        }
      );
    } on ApiResponse catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: "刪除任務失敗，請稍後再試", isError: true);
    }
  }

  void _showActionSheet(RecordItem record) {
    showModalBottomSheet(
      context: context,
      builder: (dialogContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text("修改紀錄"),
              onTap: () {
                Navigator.pop(context);
                _showRecordDialog(record: record);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("刪除紀錄"),
              onTap: () async {
                bool check = await ProgressDialog().showConfirm(context, title: "刪除確認", body: "確認要刪除此紀錄嗎");
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!check) return;
                _deleteRecord(record.id ?? 0);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordList() {
    if (_records.isEmpty) {
      return Center(
        child: Text("目前尚無帳務紀錄")
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        
        final contact = _contacts.firstWhere(
          (c) => c['id'] == record.contactId,
          orElse: () => {"name": "未知人員"}
        );

        final bool isLend = record.type == 'lend';
        
        return Card(
          margin: EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (record.settlementDate != null)
                  Icon(Icons.check_circle, color: Colors.blue, size: 16),
                Text(
                  "${record.item} (${contact['name']})",
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
              ]
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("日期: ${record.transactionDate?.toIso8601String().split('T')[0] ?? "未知日期"}"),
                if (record.description != null && record.description!.isNotEmpty)
                  Text("備註: ${record.description}", maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
            trailing: Text(
              "${isLend ? '+' : '-'}${record.amount} ${record.currency}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isLend ? Colors.green : Colors.red,
              ),
            ),
            onTap: () => _showActionSheet(record),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => _fetchData(),
          child: _buildRecordList()
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () => _showRecordDialog(),
            shape: CircleBorder(),
            backgroundColor: Color.lerp(Theme.of(context).primaryColor, Colors.white, 0.2),
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          )
        )
      ],
    );
  }
}