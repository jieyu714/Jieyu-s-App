import 'package:jieyu_app/api/BaseApi.dart';
import 'package:jieyu_app/constants/Index.dart';
import 'package:jieyu_app/viewmodels/Invoices.dart';

class InvoiceApi {
  BaseApi _api = BaseApi();

  Future<void> addInvoice({
    required String inputType,
    required String number,
    required double amount,
    required String consumptionDate,
    String? randomCode,
    String? buyerTaxId,
    String? sellerTaxId,
    String? encryptCode,
    String? originalInformation,
  }) async {
    await _api.request(
      HttpConstants.ADD_INVOICE,
      {
        "inputType": inputType,
        "number": number,
        "amount": amount,
        "consumptionDate": consumptionDate,
        "randomCode": randomCode,
        "buyerTaxId": buyerTaxId,
        "sellerTaxId": sellerTaxId,
        "encryptCode": encryptCode,
        "originalInformation": originalInformation,
      },
      null
    );
  }

  Future<ApiResponse<List<dynamic>>> getSystemWinningNumbers() async {
    return await _api.request(HttpConstants.GET_SYSTEM_WINNING_NUMBERS, {}, null);
  }

  Future<ApiResponse<List<dynamic>>> getUserWinningNumbers() async {
    return await _api.request(HttpConstants.GET_USER_WINNING_NUMBERS, {}, null);
  }

  Future<ApiResponse<Map<String, dynamic>>> updateWinningNumbers(String period, Map<String, List<String>> awards) async {
    return await _api.request(
      HttpConstants.UPDATE_WINNING_NUMBERS,
      {
        "period": period,
        "awards": awards
      },
      null
    );
  }

  Future<ApiResponse<List<InvoiceModel>>> getInvoices() async {
    return await _api.request(
      HttpConstants.GET_INVOICES,
      {},
      (data) => List<InvoiceModel>.from(data.map((x) => InvoiceModel.fromJson(x)))
    );
  }
}