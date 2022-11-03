import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:market_stack/constants.dart';
import 'package:market_stack/models/stock_data_response_model.dart.dart';

class Networking {
  static const baseUrl = "http://api.marketstack.com/v1/eod";

  Future<StockDataResponseModel?> fetchStockData(
      String stockTicker, String dateFrom, String dateTO, String offset) async {
    try {
      Uri uri = Uri.parse(
        '$baseUrl?access_key=$apiKey&symbols=$stockTicker& date_from =2022-4-02& date_to =2022-11-02&limit=7&offset=$offset',
        //limit set at 7 to display bars according to days of the week
      );
      var response = await http.get(uri);
      print(response.body);
      return StockDataResponseModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
