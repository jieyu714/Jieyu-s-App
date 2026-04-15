import 'package:flutter/material.dart';
import 'package:jieyu_app/constants/Index.dart';
import 'package:jieyu_app/routes/Index.dart';
import 'package:jieyu_app/utils/AppVersion.dart';
import 'package:jieyu_app/utils/ProgressDialog.dart';
import 'package:jieyu_app/utils/sharedPreference.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;
  bool _darkMode = false;
  String _appVersion = "";
  Color? _currentThemeColor;

  final List<Color> _themeColors = [
  // --- 經典藍與水色系 ---
  Colors.lightBlueAccent,
  Colors.blue,
  const Color(0xFF0D47A1), // 深海藍 (Deep Blue)
  Colors.teal,
  const Color(0xFF00BFA5), // 綠松石色 (Turquoise)

  // --- 暖色與活力系 ---
  Colors.orange,
  Colors.deepOrangeAccent,
  const Color(0xFFD32F2F), // 經典紅 (Ruby Red)
  Colors.pinkAccent,
  Colors.amber,

  // --- 紫色與優雅系 ---
  Colors.purple,
  Colors.indigo,
  const Color(0xFF673AB7), // 深紫色 (Deep Purple)

  // --- 自然與高級灰色系 ---
  Colors.green,
  const Color(0xFF455A64), // 藍灰色 (Blue Grey)
  const Color(0xFF795548), // 咖啡色 (Brown)
];

  Widget _buildThemeColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("主題色"),
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _themeColors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              final color = _themeColors[index];
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentThemeColor = color;
                    PreferenceService().saveData(SharedPreferenceConstant.APP_THEME_COLOR, color.value.toString());
                    appThemeNotifier.value = color;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: _currentThemeColor == color
                      ? Border.all(color: Colors.black54, width: 3) 
                      : Border.all(color: Colors.transparent),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3)
                      )
                    ],
                  ),
                  child: _currentThemeColor == color
                    ? const Icon(Icons.check, color: Colors.white, size: 20) 
                    : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    getAppVersion().then((value) {
      setState(() {
        _appVersion = value;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _currentThemeColor = Theme.of(context).primaryColor;
      });
    });
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("設置"),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: ListView(
        children: [
          _buildSectionTitle("一般設置"),
          _buildSettingItem(
            icon: Icons.notifications_none,
            title: "推播通知",
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) => setState(() => _notificationsEnabled = value),
            ),
          ),
          _buildSettingItem(
            icon: Icons.dark_mode_outlined,
            title: "深色模式",
            trailing: Switch(
              value: _darkMode,
              onChanged: (value) => setState(() => _darkMode = value),
            ),
          ),
          Divider(indent: 20, endIndent: 20),
          _buildThemeColorSelector(),
          Divider(indent: 20, endIndent: 20),
          _buildSectionTitle("系統與政策"),
          _buildSettingItem(
            icon: Icons.privacy_tip_outlined,
            title: "隱私權政策",
            onTap: () {
            },
          ),
          _buildSettingItem(
            icon: Icons.info_outline,
            title: "版本更新",
            subtitle: "當前版本 $_appVersion",
            onTap: () {
              ProgressDialog().showLoading(context, title: "版本確認中...");
              Future.delayed(Duration(seconds: 2), () {
                if (!mounted) return;
                ProgressDialog().showResult(context, message: "已是最新版本", isInfo: true);
              });
            },
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}