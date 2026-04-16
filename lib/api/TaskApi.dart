import 'package:jieyu_app/api/BaseApi.dart';
import 'package:jieyu_app/constants/Index.dart';
import 'package:jieyu_app/viewmodels/Task.dart';

class TaskApi {
  final BaseApi _baseApi = BaseApi();

  Future<ApiResponse<List<TaskItem>>> getTask({
    required String username
  }) async {
    return _baseApi.request<List<TaskItem>>(
      HttpConstants.GET_TASK,
      {},
      (data) => (data as List).map((e) => TaskItem.fromJson(e)).toList()
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> addTask({
    required String title,
    String detail = "",
    DateTime? startTime,
    DateTime? deadTime
  }) async {
    return _baseApi.request<Map<String, dynamic>>(
      HttpConstants.ADD_TASK,
      {
        "title": title,
        "detail": detail,
        "startTime": startTime?.toIso8601String(),
        "deadTime": deadTime?.toIso8601String()
      },
      null
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateTask({
    required int id,
    required String title,
    required String detail,
    required DateTime? startTime,
    required DateTime? deadTime,
    required DateTime? completedAt
  }) async {
    return _baseApi.request<Map<String, dynamic>>(
      HttpConstants.UPDATE_TASK,
      {
        "id": id,
        "title": title,
        "detail": detail,
        "startTime": startTime?.toIso8601String(),
        "deadTime": deadTime?.toIso8601String(),
        "completedAt": completedAt?.toIso8601String()
      },
      null
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteTask({
    required int id
  }) async {
    return _baseApi.request<Map<String, dynamic>>(
      HttpConstants.DELETE_TASK,
      {
        "id": id
      },
      null
    );
  }
}