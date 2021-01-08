class Data {
  List<Bursa> res;
  Data({this.res});
  factory Data.fromJson(List<dynamic> parsedJson) {
    List<Bursa> bursa = new List<Bursa>();
    bursa = parsedJson.map((i) => Bursa.fromJson(i)).toList();
    return new Data(res: bursa);
  }
}

class Bursa {
  double close;
  int date;
  double high;
  int index;
  double low;
  String name;
  double open;
  int vol;
  Bursa(
      {this.name,
      this.close,
      this.date,
      this.high,
      this.index,
      this.low,
      this.open,
      this.vol});

  factory Bursa.fromJson(Map<String, dynamic> json) {
    return new Bursa(
      close: json['close'],
      date: json['date'],
      high: json['high'],
      index: json['index'],
      low: json['low'],
      name: json['name'],
      open: json['open'],
      vol: json['vol'],
    );
  }
}

class TimeSeriesSales {
  final DateTime time;
  final double sales;

  TimeSeriesSales(this.time, this.sales);
}
