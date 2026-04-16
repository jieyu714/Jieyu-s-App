import 'package:flutter/material.dart';
import 'package:jieyu_app/api/BaseApi.dart';
import 'package:jieyu_app/api/DebtApi.dart';
import 'package:jieyu_app/utils/CustomTextField.dart';
import 'package:jieyu_app/utils/ProgressDialog.dart';
import 'package:jieyu_app/viewmodels/Record.dart';

class ContactsFragement extends StatefulWidget {
  const ContactsFragement({super.key});

  @override
  State<ContactsFragement> createState() => _ContactsFragementState();
}

class _ContactsFragementState extends State<ContactsFragement> {
  Map<String, List<dynamic>> _groupedContacts = {};

  final DebtApi _api = DebtApi();

  void _fetchContacts() async {
    await ProgressDialog().showLoading(context, minDuration: 2);
    
    try {
      final response = await _api.getContacts();

      if (response.isSuccess) {
        setState(() {
          final List<dynamic> rawData = response.data!;
          _groupedContacts = {};
          for (var contact in rawData) {
            String group = contact['group'] ?? "未分類";
            if (!_groupedContacts.containsKey(group)) {
              _groupedContacts[group] = [];
            }
            _groupedContacts[group]!.add(contact);
          }
        });
        if (!mounted) return;
        ProgressDialog().hide(context);
      } else {
        if (!mounted) return;
        ProgressDialog().showResult(context, message: response.message, isError: true);
      }
    } on ApiResponse catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: "伺服器錯誤，請稍後再試", isError: true);
    }
  }

  Widget _buildContactList() {
    if (_groupedContacts.isEmpty) {
      return Center(child: Text("目前尚無往來人員"));
    }

    final groups = _groupedContacts.keys.toList();

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final groupName = groups[index];
        final members = _groupedContacts[groupName]!;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            leading: Icon(Icons.folder_shared, color: Theme.of(context).primaryColor),
            title: Text(
              groupName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text("共 ${members.length} 人"),
            initiallyExpanded: true,
            children: members.map((contact) {
              final String name = contact['name'];
              final int balance = contact['totalBalance'];

              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Text(name[0].toUpperCase(), style: TextStyle(fontSize: 14)),
                ),
                title: Text(name),
                trailing: Text(
                  "${balance > 0 ? '+' : ''}$balance",
                  style: TextStyle(
                    color: balance > 0 ? Colors.green : (balance < 0 ? Colors.red : Colors.grey),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ContactDetailScreen(contact: contact),
                    ),
                  ).then((_) => _fetchContacts());
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchContacts());
  }

  void _addContact() {
    final TextEditingController groupController = TextEditingController();
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Center(
            child:Text("新增往來人員")
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  labelText: "群組",
                  hintText: "例如：家人、朋友、同事",
                  controller: groupController,
                  icon: Icons.group,
                  isRequird: true,
                ),
                SizedBox(height: 15),
                CustomTextField(
                  labelText: "姓名",
                  controller: nameController,
                  icon: Icons.person_add,
                  isRequird: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("取消"),
            ),
            ElevatedButton(
              onPressed: () async {
                final String group = groupController.text.trim();
                final String name = nameController.text.trim();

                if (group.isEmpty || name.isEmpty) {
                  ProgressDialog().showResult(context, message: "請填寫所有欄位", isError: true);
                  return;
                }

                Navigator.pop(dialogContext);

                if (!mounted) return;
                ProgressDialog().showLoading(context, title: "正在建立人員...", minDuration: 2);

                try {
                  await _api.addContact(group: group, name: name);

                  if (!mounted) return;
                  ProgressDialog().showResult(context, message: "人員建立成功", isSuccess: true, onClose: _fetchContacts);
                } on ApiResponse catch (e) {
                  if (!mounted) return;
                  ProgressDialog().showResult(context, message: e.message, isError: true);
                } catch (e) {
                  if (!mounted) return;
                  ProgressDialog().showResult(context, message: "伺服器錯誤，請稍後再試", isError: true);
                }
              },
              child: const Text("儲存"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => _fetchContacts(),
          child: _buildContactList()
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () => _addContact(),
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

class ContactDetailScreen extends StatefulWidget {
  final Map<String, dynamic> contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> with AutomaticKeepAliveClientMixin {
  List<RecordItem> _personalRecords = [];
  final DebtApi _api = DebtApi();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchPersonalData();
  }

  void _fetchPersonalData() async {
    try {
      final response = await _api.getRecords();
      if (response.isSuccess) {
        setState(() {
          _personalRecords = response.data!
              .where((r) => r.contactId == widget.contact["id"])
              .toList();
        });
      }
    } on ApiResponse catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      debugPrint(e.toString());
      ProgressDialog().showResult(context, message: "載入失敗", isError: true);
    }
  }

  Future<void> _deleteContact() async {
    ProgressDialog().showLoading(context, title: "刪除中...", minDuration: 2);
    
    try {
      final response = await _api.deleteContact(id: widget.contact["id"]);
      if (response.isSuccess) {
        if (!mounted) return;
        ProgressDialog().showResult(context, message: "刪除成功", isSuccess: true, onClose: () => Navigator.pop(context));
      } else {
        if (!mounted) return;
        ProgressDialog().showResult(context, message: response.message, isError: true);
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
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.contact["name"]} 的往來明細"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.redAccent,
            ), onPressed: () async{
              bool check = await ProgressDialog().showConfirm(context, title: '確認刪除', body: "確定要刪除 ${widget.contact["name"]} 的往來紀錄嗎？此操作無法復原");
              if (!check) return;
              await _deleteContact();
            }),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("目前結餘",
                style: TextStyle(
                  fontSize: 16
                  )
                ),
                Text(
                  "${widget.contact["totalBalance"] > 0 ? '+' : ''}${widget.contact["totalBalance"]}",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: widget.contact["totalBalance"] > 0 ? Colors.green : (widget.contact["totalBalance"] < 0 ? Colors.red : Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _personalRecords.isEmpty
                ? Center(
                  child: Text("尚無明細紀錄")
                ) : ListView.builder(
                    itemCount: _personalRecords.length,
                    itemBuilder: (context, index) {
                      final record = _personalRecords[index];
                      final bool isLend = record.type == 'lend';

                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        child: ListTile(
                          title: Text(
                            record.item,
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("日期: ${record.transactionDate.toIso8601String().split('T')[0]}"),
                              if (record.description != null && record.description!.isNotEmpty)
                                Text("備註: ${record.description}", maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "${isLend ? '+' : '-'}${record.amount} ${record.currency}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isLend ? Colors.green : Colors.red,
                                ),
                              ),
                              if (record.settlementDate != null) ...[
                                SizedBox(width: 8),
                                Icon(Icons.check_circle, color: Colors.blue, size: 16),
                              ]
                            ],
                          ),
                        )
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}