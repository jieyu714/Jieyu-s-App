import 'package:jieyu_app/api/BaseApi.dart';
import 'package:jieyu_app/constants/Index.dart';

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
}