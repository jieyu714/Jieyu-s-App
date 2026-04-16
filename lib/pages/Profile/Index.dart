import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jieyu_app/api/AuthApi.dart';
import 'package:jieyu_app/api/BaseApi.dart';
import 'package:jieyu_app/constants/Index.dart';
import 'package:jieyu_app/utils/CustomDropdownFiled.dart';
import 'package:jieyu_app/utils/CustomTextField.dart';
import 'package:jieyu_app/utils/DateTimePicker.dart';
import 'package:jieyu_app/utils/PasswordHelper.dart';
import 'package:jieyu_app/utils/ProgressDialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = "";
  String _email = "";
  String _gender = "";
  String _phone = "";
  String _city = "", _district = "", _detailAddress = "";
  DateTime? _birthday;
  bool isChanging = false;

  Map<String, dynamic> _taiwanData = {};
  List<String> _cityList = [];

  final AuthApi _api = AuthApi();

  Widget _buildItem(String title, String value, IconData icon, {Function? onTap}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blueGrey
        ),
        title: Text(
          title,
            style: TextStyle(
              fontWeight: FontWeight.w500
            )
          ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 20
            ),
          ]),
        onTap: () => {
          if (onTap != null) {
            onTap()
          }
        },
      )
    );
  }

  Future<void> _getUserInfo({bool isInitialization = false}) async {

    if (isInitialization) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ProgressDialog().showLoading(context, minDuration: 1);
      });
    } else {
      ProgressDialog().showLoading(context, minDuration: 1);
    }

    final res = await _api.getUserInfo();

    if (!mounted) {
      return;
    } else if (res.data != null) {
      setState(() {
        _username = res.data!["name"];
        _gender = res.data!["gender"] ?? "";
        if (res.data!["birthday"] != null) {
          _birthday = DateTime.parse(res.data!["birthday"]);
        }
        _email = res.data!["email"] ?? "";
        _phone = res.data!["phone"] ?? "";
        if (res.data!["address"] != null) {
          List<String> parts = res.data!["address"].split(' ');
          if (parts.length >= 3) {
            _city = parts[0];
            _district = parts[1];
            _detailAddress = parts.sublist(2).join(' ');
          } else {
            _detailAddress = res.data!["address"];
          }
        }
      });
      
      if (!mounted) return;
      ProgressDialog().hide(context);
    } else {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: "個人資料載入失敗", isError: true, onClose: () {
        Navigator.pop(context);
      });
    }
  }

  Future<Map<String, Map<String, dynamic>>> loadTaiwanData() async {
    final String jsonString = await rootBundle.loadString('assets/json/taiwan_districts.json');
    
    final data = jsonDecode(jsonString);
    
    return Map<String, Map<String, dynamic>>.from(data['台灣']);
  }

  void _editUsername() {
    final TextEditingController nameController = TextEditingController(text: _username);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Center(
            child: Text("修改使用者名稱")
          ),
          content: CustomTextField(
            labelText: "使用者名稱",
            controller: nameController,
            maxLength: 20,
            hintText: "必須以大寫字母開頭，長度5-20，允許大小寫字母、數字和_",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("取消"),
            ),
            ElevatedButton(
              onPressed: () async {
                final String newName = nameController.text.trim();

                if (newName.isEmpty) {
                  ProgressDialog().showResult(context, message: "請輸入使用者名稱", isError: true);
                  return;
                } else if (newName.length < 5) {
                  ProgressDialog().showResult(context, message: "使用者名稱長度至少為5個字元", isError: true);
                  return;
                } else if (!newName.startsWith(RegExp(r"[A-Z]"))) {
                  ProgressDialog().showResult(context, message: "使用者名稱必須以大寫字母開頭", isError: true);
                  return;
                } else if (!RegExp(RegexConstant.USERNAME).hasMatch(newName)) {
                  ProgressDialog().showResult(context, message: "使用者名稱出現不允許的字符", isError: true);
                  return;
                }

                Navigator.pop(dialogContext);
                
                if (isChanging || newName == _username) return;
                isChanging = true;

                ProgressDialog().showLoading(context, title: "更新中...", minDuration: 1);

                try {
                  await _api.updateUserInfo(
                    name: newName,
                    gender: _gender,
                    birthday: _birthday,
                    phone: _phone,
                    address: "$_city $_district $_detailAddress"
                  );

                  if (!mounted) return;
                  ProgressDialog().showResult(context, message: "名稱更新成功", isSuccess: true, onClose: _getUserInfo);
                } on ApiResponse catch (e) {
                  if (!mounted) return;
                  ProgressDialog().showResult(context, message: e.message, isError: true);
                } catch (e) {
                  if (mounted) {
                    ProgressDialog().showResult(context, message: "使用者名稱更新失敗，請稍後再試", isError: true);
                  }
                } finally {
                  isChanging = false;
                }
              },
              child: const Text("儲存"),
            ),
          ],
        );
      },
    );
  }

  void _showEmail() {
    ProgressDialog().showResult(context, message: _email, isInfo: true);
  }

  void _editGender() {
    final List<List> genderList = [
      ["男性", Icons.male],
      ["女性", Icons.female],
      ["其他", Icons.more_horiz]
    ];

    showModalBottomSheet(
      context: context,
      builder: (dialogContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  "修改生理性別",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                    )
                  ),
              ),
              ...List.generate(genderList.length, (index) {
                return _buildItem(genderList[index][0], "", genderList[index][1], onTap: () async {
                  Navigator.of(dialogContext).pop();

                  if (genderList[index][0] == _gender) return;
                  
                  if (isChanging) return;
                  isChanging = true;

                  if (!mounted) return;
                  ProgressDialog().showLoading(context, title: "更新中...", minDuration: 1);

                  try {
                    await _api.updateUserInfo(
                      name: _username,
                      gender: genderList[index][0],
                      birthday: _birthday,
                      phone: _phone,
                      address: "$_city $_district $_detailAddress"
                    );
                    if (!mounted) return;
                    ProgressDialog().showResult(context, message: "更新性別成功", isSuccess: true, onClose: _getUserInfo);
                  } catch (e) {
                    if (!mounted) return;
                    ProgressDialog().showResult(context, message: "更新性別失敗", isError: true);
                  } finally {
                    isChanging = false;
                  }
                });
              })
            ]
          )
        );
      }
    );
  }

  Future<void> _editBirthday() async {
    final DateTime? picked = await DateTimePicker().selectDate(context);

    if (picked != null && picked != _birthday) {
      if (isChanging) return;
      isChanging = true;

      if (!mounted) return;
      ProgressDialog().showLoading(context, title: "更新中...", minDuration: 1);

      try {
        await _api.updateUserInfo(
          name: _username,
          gender: _gender,
          birthday: picked,
          phone: _phone,
          address: "$_city $_district $_detailAddress"
        );

        if (!mounted) return;
        ProgressDialog().showResult(context, message: "更新生日成功", isSuccess: true, onClose: _getUserInfo);
      } catch (e) {
        if (!mounted) return;
        ProgressDialog().showResult(context, message: "更新生日失敗", isError: true);
      } finally {
        isChanging = false;
      }
    }
  }

  void _editPhone() {
    final TextEditingController phoneController = TextEditingController(text: _phone);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Center(
            child: Text("修改電話號碼")
          ),
          content: CustomTextField(
            labelText: "手機號碼",
            controller: phoneController,
            textInputType: TextInputType.phone,
            maxLength: 10,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("取消")
            ),
            ElevatedButton(
              onPressed: () async {
                final String newPhone = phoneController.text.trim();
                
                if (newPhone.isEmpty) {
                  ProgressDialog().showResult(context, message: "請輸入手機號碼", isError: true);
                  return;
                } else if (newPhone.length != 10 || !RegExp(RegexConstant.PHONE).hasMatch(newPhone)) {
                  ProgressDialog().showResult(context, message: "手機格式不正確", isError: true);
                  return;
                }

                Navigator.pop(dialogContext);
                if (isChanging || newPhone == _phone) return;

                isChanging = true;
                ProgressDialog().showLoading(context, title: "更新中...");

                try {
                  await _api.updateUserInfo(
                    name: _username,
                    gender: _gender,
                    birthday: _birthday,
                    phone: newPhone,
                    address: "$_city $_district $_detailAddress"
                  );
                  
                  if (!mounted) return;
                  ProgressDialog().showResult(context, message: "更新成功", isSuccess: true, onClose: _getUserInfo);
                } catch (e) {
                  if (!mounted) return;
                  ProgressDialog().showResult(context, message: "更新失敗", isError: true);
                } finally {
                  isChanging = false;
                }
              },
              child: const Text("儲存"),
            ),
          ],
        );
      },
    );
  }

  void _editAddress() {
    String selectedCity = _city.isNotEmpty && _cityList.contains(_city) ? _city : _cityList.first;
    Map<String, dynamic> districtsMap = Map<String, dynamic>.from(_taiwanData[selectedCity]);
    List<String> districtList = districtsMap.keys.toList();
    String selectedDistrict = _district.isNotEmpty && districtList.contains(_district) 
        ? _district 
        : districtList.first;

    final TextEditingController detailController = TextEditingController(text: _detailAddress);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              title: Center(
                child: Text("修改聯絡地址")
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomDropdownField(
                      labelText: "縣市",
                      value: selectedCity,
                      items: _cityList,
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          selectedCity = value;
                          districtsMap = Map<String, dynamic>.from(_taiwanData[selectedCity]);
                          districtList = districtsMap.keys.toList();
                          selectedDistrict = districtList.first;
                        });
                      }
                    ),
                    SizedBox(height: 15),
                    CustomDropdownField(
                      labelText: "行政區",
                      value: districtList.contains(selectedDistrict) ? selectedDistrict : null,
                      items: districtList,
                      onChanged: (value) => setDialogState(() => selectedDistrict = value!),
                    ),
                    SizedBox(height: 15),
                    CustomTextField(
                      labelText: "詳細地址",
                      controller: detailController,
                    ),
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
                    final String detail = detailController.text.trim();
                    if (selectedCity == _city && selectedDistrict == _district && detail == _detailAddress) {
                      Navigator.pop(dialogContext);
                      return;
                    } else if (detail.isEmpty) {
                      ProgressDialog().showResult(context, message: "請輸入詳細地址", isError: true);
                      return;
                    }

                    Navigator.pop(dialogContext);
                    if (isChanging) return;
                    isChanging = true;

                    await ProgressDialog().showLoading(context, title: "地址更新中...", minDuration: 1);

                    try {
                      await _api.updateUserInfo(
                        name: _username,
                        gender: _gender,
                        birthday: _birthday,
                        phone: _phone,
                        address: "$selectedCity $selectedDistrict $detail",
                      );

                      if (!mounted) return;
                      setState(() {
                        _city = selectedCity;
                        _district = selectedDistrict;
                        _detailAddress = detail;
                      });
                      if (!mounted) return;
                      ProgressDialog().showResult(context, message: "地址更新成功", isSuccess: true, onClose: () => _getUserInfo());
                    } catch (e) {
                      if (!mounted) return;
                      ProgressDialog().showResult(context, message: "更新失敗", isError: true);
                    } finally {
                      isChanging = false;
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

  void _editPassword() {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("修改密碼"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  labelText: "舊密碼",
                  controller: oldPasswordController,
                  obscureText: true,
                ),
                SizedBox(height: 15),
                CustomTextField(
                  labelText: "新密碼",
                  controller: newPasswordController,
                  hintText: "長度至少8，允許大小寫字母、數字和!@?_",
                  obscureText: true,
                ),
                SizedBox(height: 15),
                CustomTextField(
                  labelText: "確認新密碼",
                  controller: confirmPasswordController,
                  obscureText: true,
                ),
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
                final String oldPassword = oldPasswordController.text.trim();
                final String newPassword = newPasswordController.text.trim();
                final String confirmPassword = confirmPasswordController.text.trim();

                if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                  ProgressDialog().showResult(context, message: "請填寫所有欄位", isError: true);
                  return;
                } else if (newPassword != confirmPassword) {
                  ProgressDialog().showResult(context, message: "新密碼與確認密碼不符", isError: true);
                  return;
                } else if (newPassword.length < 8) {
                  ProgressDialog().showResult(context, message: "新密碼長度至少需 8 位", isError: true);
                  return;
                } else if (!RegExp(RegexConstant.PASSWORD).hasMatch(newPassword)) {
                  ProgressDialog().showResult(context, message: "新密碼出現不允許的字符", isError: true);
                  return;
                } else if (oldPassword == newPassword) {
                  ProgressDialog().showResult(context, message: "新舊密碼不能相同", isError: true);
                  return;
                }

                Navigator.pop(dialogContext);
                
                if (!mounted) return;
                if (isChanging) return;
                isChanging = true;

                await ProgressDialog().showLoading(context, title: "處理中...", minDuration: 2);

                try {
                  await _api.changePassword(
                    oldPasswordHash: PasswordHelper().hashPassword(oldPassword),
                    newPassword: newPassword,
                    newPasswordHash: PasswordHelper().hashPassword(newPassword)
                  );

                  if (!mounted) return;
                  ProgressDialog().showResult(context, message: "密碼修改成功，請重新登入", isSuccess: true, onClose: () async {
                    await _api.logout(context);
                    if (!mounted) return;
                    Navigator.pushNamedAndRemoveUntil(context, "/login", (Route<dynamic> router) => false);
                  }
                  );
                } on ApiResponse catch (e) {
                  if (!mounted) return;
                  ProgressDialog().showResult(context, message: e.message, isError: true);
                } catch (e) {
                  if (!mounted) return;
                  ProgressDialog().showResult(context, message: "伺服器錯誤，請稍後再試", isError: true);
                } finally {
                  isChanging = false;
                }
              },
              child: const Text("儲存"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _initAddressData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/json/taiwan_districts.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);
      setState(() {
        _taiwanData = Map<String, dynamic>.from(data['台灣']);
        _cityList = _taiwanData.keys.toList();
      });
    } catch (e) {
      debugPrint("載入地區資料失敗: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _initAddressData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("個人資料"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildItem("使用者名稱", _username, Icons.person, onTap: _editUsername),
            _buildItem("電子信箱", _email.length > 10 ? "${_email.substring(0, 10)}..." : _email, Icons.mail, onTap: _showEmail),
            _buildItem("手機號碼", _phone.isEmpty ? "未設置" : _phone, Icons.phone, onTap: _editPhone),
            _buildItem("生理性別", _gender.isEmpty ? "未設置" : _gender, Icons.male, onTap: _editGender),
            _buildItem("生日", _birthday == null ? "未設置" : _birthday!.toString().substring(0, 10).replaceAll("-", "/"), Icons.calendar_today, onTap: _editBirthday),
            _buildItem("住址", "$_city $_district...", Icons.location_city, onTap: _editAddress),
            _buildItem("密碼", "", Icons.lock, onTap: _editPassword),
          ]
        )
      )
    );
  }
}