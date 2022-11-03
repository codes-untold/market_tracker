class StockDataResponseModel {
  StockDataResponseModel({
    required this.pagination,
    required this.data,
  });
  late final Pagination? pagination;
  late final List<Data>? data;

  StockDataResponseModel.fromJson(Map<String, dynamic> json) {
    pagination = Pagination.fromJson(json['pagination']);
    data = List.from(json['data']).map((e) => Data.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['pagination'] = pagination!.toJson();
    _data['data'] = data!.map((e) => e.toJson()).toList();
    return _data;
  }
}

class Pagination {
  Pagination({
    required this.limit,
    required this.offset,
    required this.count,
    required this.total,
  });
  late final int? limit;
  late final int? offset;
  late final int? count;
  late final int? total;

  Pagination.fromJson(Map<String, dynamic> json) {
    limit = json['limit'];
    offset = json['offset'];
    count = json['count'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['limit'] = limit;
    _data['offset'] = offset;
    _data['count'] = count;
    _data['total'] = total;
    return _data;
  }
}

class Data {
  Data({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.adjHigh,
    required this.adjLow,
    required this.adjClose,
    required this.adjOpen,
    required this.adjVolume,
    required this.splitFactor,
    required this.dividend,
    required this.symbol,
    required this.exchange,
    required this.date,
  });
  late final dynamic open;
  late final dynamic high;
  late final dynamic low;
  late final dynamic close;
  late final dynamic volume;
  late final dynamic adjHigh;
  late final double? adjLow;
  late final dynamic adjClose;
  late final dynamic adjOpen;
  late final dynamic adjVolume;
  late final dynamic splitFactor;
  late final dynamic dividend;
  late final String? symbol;
  late final String? exchange;
  late final String? date;

  Data.fromJson(Map<String, dynamic> json) {
    open = json['open'];
    high = json['high'];
    low = json['low'];
    close = json['close'];
    volume = json['volume'];
    adjHigh = json['adj_high'];
    adjLow = json['adj_low'];
    adjClose = json['adj_close'];
    adjOpen = json['adj_open'];
    adjVolume = json['adj_volume'];
    splitFactor = json['split_factor'];
    dividend = json['dividend'];
    symbol = json['symbol'];
    exchange = json['exchange'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['open'] = open;
    _data['high'] = high;
    _data['low'] = low;
    _data['close'] = close;
    _data['volume'] = volume;
    _data['adj_high'] = adjHigh;
    _data['adj_low'] = adjLow;
    _data['adj_close'] = adjClose;
    _data['adj_open'] = adjOpen;
    _data['adj_volume'] = adjVolume;
    _data['split_factor'] = splitFactor;
    _data['dividend'] = dividend;
    _data['symbol'] = symbol;
    _data['exchange'] = exchange;
    _data['date'] = date;
    return _data;
  }
}
