import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:band_names/src/models/band.dart';
import 'package:band_names/src/services/socket_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.on('active-bands', _handleActiveBands);
    super.initState();
  }

  void _handleActiveBands(dynamic data) {
    bands = (data as List).map((band) => Band.fromMap(band)).toList();
    log('Se actualiza lista, cantididad de bandas: ${bands.length}');
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BandNames', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.onLine
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.offline_bolt, color: Colors.red)),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          _showGraph(),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: bands.length,
              itemBuilder: (context, index) => _createItemBand(bands[index]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        onPressed: _addNewBand,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _createItemBand(Band banda) {
    final socketService = Provider.of<SocketService>(context);

    return Dismissible(
      key: Key(banda.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => socketService.emit('delete-band', {'id': banda.id}),
      background: Container(
        padding: const EdgeInsets.only(left: 8.0),
        color: Colors.redAccent,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(children: const <Widget>[
            Icon(Icons.delete, color: Colors.white),
            Text('Borrar', style: TextStyle(color: Colors.white)),
          ]),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent[100],
          child: Text(
            banda.name.substring(0, 2),
            style: TextStyle(color: Colors.black.withOpacity(0.5)),
          ),
        ),
        title: Text(banda.name),
        trailing: Text(
          '${banda.votes}',
          style: const TextStyle(fontSize: 20),
        ),
        onTap: () => socketService.emit('vote-band', {'id': banda.id}),
      ),
    );
  }

  _addNewBand() {
    final textController = TextEditingController();

    if (!Platform.isIOS) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Nombre nueva banda:'),
            content: TextField(
              controller: textController,
            ),
            actions: <Widget>[
              MaterialButton(
                textColor: Colors.blue,
                elevation: 5,
                onPressed: () => addBandToList(textController.text),
                child: const Text('Agregar'),
              ),
            ],
          );
        },
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Nombre nueva banda:'),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => addBandToList(textController.text),
                child: const Text('Agregar'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      );
    }
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      //Se puede agregar la banda a la lista
      socketService.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = {};
    for (var band in bands) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    }

    final List<Color> colorList = [
      Colors.blue,
      Colors.blueAccent,
      Colors.yellow,
      Colors.yellowAccent,
      Colors.red,
      Colors.redAccent,
      Colors.pink,
      Colors.pinkAccent,
    ];

    return SizedBox(
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        colorList: colorList,
        initialAngleInDegree: 0,
        chartType: ChartType.ring,
        ringStrokeWidth: 32,
        centerText: "HYBRID",
        legendOptions: const LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          //legendShape: _BoxShape.circle,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: const ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 1,
        ),
        // gradientList: ---To add gradient colors---
        // emptyColorGradient: ---Empty Color gradient---
      ),
    );
  }
}
