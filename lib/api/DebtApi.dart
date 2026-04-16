import 'package:flutter/material.dart';
import 'package:jieyu_app/api/BaseApi.dart';
import 'package:jieyu_app/constants/Index.dart';
import 'package:jieyu_app/viewmodels/Record.dart';

class DebtApi {
  BaseApi _baseApi = BaseApi();

  Future<ApiResponse<List<dynamic>>> getContacts() async {
    return _baseApi.request<List<dynamic>>(HttpConstants.GET_CONTACTS, {}, null);
  }

  Future<ApiResponse<Map<String, dynamic>>> addContact({
    required String group,
    required String name
  }) async {
    return _baseApi.request<Map<String, dynamic>>(
      HttpConstants.ADD_CONTACT,
      {
        "group": group,
        "name": name
      },
      null
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateContact({
    required int id,
    required String group,
    required String name
  }) async {
    return _baseApi.request<Map<String, dynamic>>(
      HttpConstants.UPDATE_CONTACT,
      {
        "id": id,
        "group": group,
        "name": name
      },
      null
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteContact({
    required int id
  }) async {
    return _baseApi.request<Map<String, dynamic>>(
      HttpConstants.DELETE_CONTACT,
      {
        "id": id
      },
      null
    );
  }

  Future<ApiResponse<List<RecordItem>>> getRecords() async {
    return _baseApi.request<List<RecordItem>>(
      HttpConstants.GET_RECORDS,
      {},
      (data) => (data as List).map((e) => RecordItem.fromJson(e)).toList()
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> addRecord({
    required int contactId,
    required DateTime transactionDate,
    required String type,
    required String item,
    required int amount,
    required String currency,
    required String description,
    required String paymentMethod,
    DateTime? settlementDate
  }) async {
    return _baseApi.request<Map<String, dynamic>>(
      HttpConstants.ADD_RECORD,
      {
        "contactId": contactId,
        "transactionDate": transactionDate.toIso8601String().split('T')[0],
        "type": type,
        "item": item,
        "amount": amount,
        "currency": currency,
        "description": description,
        "paymentMethod": paymentMethod,
        "settlementDate": settlementDate?.toIso8601String().split('T')[0]
      },
      null
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateRecord({
    required int id,
    required int contactId,
    required DateTime transactionDate,
    required String type,
    required String item,
    required int amount,
    required String currency,
    required String description,
    required String paymentMethod,
    DateTime? settlementDate
  }) async {
    debugPrint("紀錄：${settlementDate?.toIso8601String().split('T')[0]}");
    return _baseApi.request<Map<String, dynamic>>(
      HttpConstants.UPDATE_RECORD,
      {
        "id": id,
        "contactId": contactId,
        "transactionDate": transactionDate.toIso8601String().split('T')[0],
        "type": type,
        "item": item,
        "amount": amount,
        "currency": currency,
        "description": description,
        "paymentMethod": paymentMethod,
        "settlementDate": settlementDate?.toIso8601String().split('T')[0]
      },
      null
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteRecord({
    required int id
  }) async {
    return _baseApi.request<Map<String, dynamic>>(
      HttpConstants.DELETE_RECORD,
      {
        "id": id
      },
      null
    );
  }
}