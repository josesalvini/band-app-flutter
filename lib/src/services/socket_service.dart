import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/socket_io_client.dart';
import 'dart:developer';

enum ServerStatus { onLine, offLine, connecting }

const List events = [
  'connect',
  'connect_error',
  'connect_timeout',
  'connecting',
  'disconnect',
  'error',
  'reconnect',
  'reconnect_attempt',
  'reconnect_failed',
  'reconnect_error',
  'reconnecting',
  'ping',
  'pong'
];

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.connecting;
  late io.Socket _socket;

  ServerStatus get serverStatus => _serverStatus;
  io.Socket get socket => _socket;

  //publicar la funcion emit
  Function get emit => _socket.emit;
  Function get on => _socket.on;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    // Dart client
    try {
      _socket = io.io(
          //'http://192.168.1.223:3001',
          //'http://192.168.100.4:3001',
          //'http://10.0.2.2:3001',
          //'http://localhost:3001',
          'https://sockets-io-server-flutter.herokuapp.com/',
          OptionBuilder()
              .setTransports(['websocket']) // for Flutter or Dart VM
              .enableAutoConnect() // disable auto-connection
              .build());

      //_socket.connect();
      //log('socket.connected ${socket.connected}');
      //_socket.emit('msg', {'name': 'Jose Salvini'});

      _socket.onConnect((data) {
        log('onConnect ${_socket.id}');
        _serverStatus = ServerStatus.onLine;
        notifyListeners();
      });

      _socket.onDisconnect((_) {
        log('onDisconnect ${_socket.id}');
        _serverStatus = ServerStatus.offLine;
        notifyListeners();
      });

      _socket.on('connect_error', (data) {
        log('connect_error ${data.toString()}');
      });
    } catch (e) {
      log('Exception: ${e.toString()}');
    }
  }
}
