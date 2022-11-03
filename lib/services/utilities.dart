import 'dart:io';

String formatDate(DateTime date) {
  return date.toString().substring(0, 11);
}

String textFormatter(String amount) {
  String priceInText = "";
  int counter = 0;
  for (int i = (amount.length - 1); i >= 0; i--) {
    counter++;
    String str = amount[i];
    if ((counter % 3) != 0 && i != 0) {
      priceInText = "$str$priceInText";
    } else if (i == 0) {
      priceInText = "$str$priceInText";
    } else {
      priceInText = ",$str$priceInText";
    }
  }
  return priceInText.trim();
}

Future<bool> internetCheck() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    return false;
  }

  return false;
}
