import 'package:flutter/cupertino.dart';

class TaskItem {
  int id;
  String title;
  String detail = "";
  DateTime? startTime;
  DateTime? deadTime;
  DateTime? completedAt;
  DateTime? createdAt;
  Color? color;
  IconData? icon;

  TaskItem({
    required this.id,
    required this.title,
    required this.detail,
    required this.startTime,
    required this.deadTime,
    required this.completedAt,
    required this.createdAt,
    this.color,
    this.icon
  });

  bool get isCompleted => completedAt != null;

  bool get isOverdue => deadTime != null && !isCompleted && DateTime.now().isAfter(deadTime!);

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json["id"],
      title: json["title"],
      detail: json["detail"] ?? "",
      startTime: json["startTime"] != null ? DateTime.parse(json["startTime"]) : null,
      deadTime: json["deadTime"] != null ? DateTime.parse(json["deadTime"]) : null,
      completedAt: json["completedAt"] != null ? DateTime.parse(json["completedAt"]) : null,
      createdAt: json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null
    );
  }
}