import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'bursa.dart';
import 'package:flutter_config/flutter_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig
  await FlutterConfig.loadEnvVariables();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bursa Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'DEEPAGI Sample'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<charts.Series<TimeSeriesSales, DateTime>> _counter;
  String status;
  String graphType;

  Future<http.Response> getLatestData() async {
    setState(() {
      status = 'Loading data for $graphType';
    });
    var client = new http.Client();
    var response = await client.get(
        'https://i-bursa.herokuapp.com/stocks?stocks=$graphType&id=${FlutterConfig.get('DEEPAGI_ID')}');
    //print(response.body);
    return response;
  }

  void _chooseInput() {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
            actions: [FlatButton(onPressed: _loadData, child: Text('Submit'))],
            content: Container(
                child: TextField(
              onChanged: (value) {
                setState(() {
                  graphType = value;
                });
              },
              decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'Insert Graph Type'),
            ))),
        barrierDismissible: true);
  }

  void _loadData() async {
    if (graphType.isNotEmpty) {
      Navigator.pop(context);
      var response = getLatestData();
      response.then((result) {
        List<charts.Series<TimeSeriesSales, DateTime>> bursaData;
        List<TimeSeriesSales> data = new List<TimeSeriesSales>();
        final jsonResponse = json.decode(result.body);
        var posts = Data.fromJson(jsonResponse['res']).res;
        posts.forEach((p) {
          final date = DateTime.fromMillisecondsSinceEpoch(p.date * 1000);
          data.add(new TimeSeriesSales(date, p.open));
        });
        bursaData = [
          new charts.Series<TimeSeriesSales, DateTime>(
            id: 'Sales',
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
            domainFn: (TimeSeriesSales sales, _) => sales.time,
            measureFn: (TimeSeriesSales sales, _) => sales.sales,
            data: data,
          )
        ];
        setState(() {
          _counter = bursaData;
        });
      });
    } else {
      setState(() {
        status = 'error data $graphType';
      });
    }
  }

  @override
  void initState() {
    status = 'click +';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(graphType != null ? graphType : widget.title),
      ),
      body: _counter == null
          ? Center(
              child: Text(status),
            )
          : Center(
              child: charts.TimeSeriesChart(
              _counter,
              animate: true,
              dateTimeFactory: const charts.LocalDateTimeFactory(),
            )),
      floatingActionButton: FloatingActionButton(
        onPressed: _chooseInput,
        tooltip: 'Graph',
        child: Icon(Icons.graphic_eq),
      ),
    );
  }
}
