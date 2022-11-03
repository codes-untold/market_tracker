import 'dart:async';

import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:market_stack/constants.dart';
import 'package:market_stack/controller/networking.dart';
import 'package:market_stack/models/stock_data_response_model.dart.dart';
import 'package:market_stack/services/utilities.dart';
import 'package:market_stack/widgets/loader.dart';

import '../models/company_model.dart';
import '../widgets/bar_chart.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTime lowerDate = DateTime.now();
  DateTime upperDate = DateTime.now().add(const Duration(days: 7));

  bool isScreenBusy = false;
  int offset = 1;
  StockDataResponseModel? fetchedStockData;
  CompanyModel selectedStock =
      CompanyModel(name: "Apple Inc", stockTicker: "AAPL");
  late StreamSubscription<bool> stream;
  bool hasInternetConnection = true;

  @override
  void initState() {
    super.initState();
    // fetchData();
    listenForConnection();
  }

  void listenForConnection() {
    //recursive function to constantly check for internet connection
    stream = Stream<bool>.fromFuture(internetCheck()).listen((event) {
      setState(() => hasInternetConnection = event);
      listenForConnection();
    });
  }

  @override
  void dispose() {
    super.dispose();
    stream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xff070a18),
      body: SafeArea(
          child: Column(children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.only(bottomRight: Radius.circular(100))),
            child: Column(
              children: [
                hasInternetConnection
                    ? const SizedBox.shrink()
                    : Container(
                        height: size.height * 0.05,
                        width: double.infinity,
                        color: Colors.red,
                        child: const Center(
                          child: Text(
                            "NO INTERNET CONNECTION",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(children: [
                      EasyAutocomplete(
                        initialValue: selectedStock.name,
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xfffd5393)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xfffd5393)),
                          ),
                        ),
                        suggestions: stockList.map((e) => e.name).toList(),
                        onChanged: (value) {},
                        onSubmitted: (value) async {
                          offset = 1;
                          await fetchData(callback: () {
                            print("aaaa");
                            setState(() {
                              selectedStock = stockList
                                  .where((element) => element.name == value)
                                  .toList()
                                  .first;
                            });
                          });
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedStock.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                selectedStock.stockTicker,
                                style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              InkWell(
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: lowerDate,
                                      firstDate: DateTime(2015, 8),
                                      lastDate: DateTime(2101));
                                  if (picked != null && picked != lowerDate) {
                                    if (upperDate.compareTo(picked) == 0 ||
                                        upperDate
                                            .compareTo(picked)
                                            .isNegative) {
                                      Fluttertoast.showToast(
                                          msg:
                                              "Select a Date Before the Max. Date",
                                          gravity: ToastGravity.TOP);
                                    } else {
                                      setState(() {
                                        lowerDate = picked;
                                        fetchData();
                                      });
                                    }
                                  }
                                },
                                child: Text(
                                  DateFormat.MMMEd().format(lowerDate),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Text(
                                "  -  ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              InkWell(
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: upperDate,
                                      firstDate: DateTime(2015, 8),
                                      lastDate: DateTime(2101));
                                  if (picked != null && picked != lowerDate) {
                                    if (picked.compareTo(lowerDate) == 0 ||
                                        picked
                                            .compareTo(lowerDate)
                                            .isNegative) {
                                      Fluttertoast.showToast(
                                          msg:
                                              "Select a Date after the Min. Date",
                                          gravity: ToastGravity.TOP);
                                    } else {
                                      setState(() {
                                        upperDate = picked;
                                        fetchData();
                                      });
                                    }
                                  }
                                },
                                child: Text(
                                  DateFormat.MMMEd().format(upperDate),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      isScreenBusy
                          ? const Expanded(child: Center(child: CustomLoader()))
                          : Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  fetchedStockData == null
                                      ? SizedBox(
                                          height: size.height * 0.5,
                                          child: const Center(
                                            child: Text(
                                              "Unable to fetch Data , Try Again",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        )
                                      : BarChartSample2(
                                          fetchedStockData!.data!),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            customRow(
                                                const Color(0xff53fdd7), "Low"),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            customRow(
                                                const Color(0xffff5182), "High")
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                if (fetchedStockData == null) {
                                                  return;
                                                }
                                                if (offset == 1) {
                                                  return;
                                                }
                                                offset -= 6;
                                                fetchData();
                                              },
                                              child: const Icon(
                                                Icons.arrow_circle_left,
                                                color: Color(0xff070a18),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (fetchedStockData == null) {
                                                  return;
                                                }
                                                if (hasExceededPaginationLength()) {
                                                  return;
                                                }
                                                offset +=
                                                    6; //go forward by 6 days
                                                fetchData();
                                              },
                                              child: const Icon(
                                                Icons.arrow_circle_right,
                                                color: Color(0xff070a18),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 100,
          width: double.infinity,
          child: fetchedStockData == null
              ? const SizedBox.shrink()
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Row(children: [
                    Text(
                      "ADJ HIGH: ${fetchedStockData!.data![0].adjHigh ?? ""}",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "ADJ LOW: ${fetchedStockData!.data![0].adjLow ?? ""}",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ]),
                ),
        )
      ])),
      floatingActionButton: InkWell(
        onTap: () => fetchData(),
        child: Container(
          decoration: BoxDecoration(
              color: const Color(0xffff5182),
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: const Text(
            "Reload",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget customRow(Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 15,
          height: 15,
          color: color,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Future<void> fetchData({VoidCallback? callback}) async {
    setState(() {
      isScreenBusy = true;
    });
    Networking()
        .fetchStockData(selectedStock.stockTicker, formatDate(lowerDate),
            formatDate(upperDate), offset.toString())
        .then((StockDataResponseModel? data) {
      if (data != null) {
        fetchedStockData = data;
        if (callback != null) {
          callback();
        }
      } else {
        Fluttertoast.showToast(
            msg: "Error fetching Data - Try again", gravity: ToastGravity.TOP);
      }
      setState(() {
        isScreenBusy = false;
      });
    });
  }

  bool hasExceededPaginationLength() {
    return fetchedStockData!.pagination!.total! / 7 == offset;
  }
}
