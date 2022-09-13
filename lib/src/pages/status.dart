import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:band_names/src/services/socket_service.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Status socket: ${socketService.serverStatus}')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //emitir: emitir-mensaje
          //{nombre: 'Flutter', mensaje: 'Hola desde Flutter'}
          socketService.socket.emit(
            'emitir-mensaje',
            {'nombre': 'Flutter', 'mensaje': 'Hola desde Flutter'},
          );
        },
        child: const Icon(
          Icons.message,
          size: 32,
        ),
      ),
    );
  }
}
