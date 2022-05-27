import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import './BluetoothDeviceListEntry.dart';

import 'Calibrar.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({required this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  static final clientID = 0;
  var connection; //BluetoothConnection

  List<_Message> messages = [];
  //String _messageBuffer = '';

  bool isConnecting = true;
  bool isDisconnecting = false;

  String dataString = '0.0';

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected()) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: (isConnecting
              ? Text('Conectando... ')
              : isConnected()
                  ? Text('Conectado')
                  : Text('Não Conectado'))),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                    dataString,
                    style: TextStyle(
                      fontSize: 45,
                      fontStyle: FontStyle.normal,
                      color: Color.fromARGB(255, 81, 80, 85),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    //Navigator.push(context, MaterialPageRoute(),
                    //Navigator.of(context).pop(result.device);
                  },
                  child: Text("Calibrarhfghfghfg"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    Uint8List buffer = Uint8List(data.length);
    int bufferIndex = buffer.length;

    for (int i = data.length - 1; i >= 0; i--) {
      buffer[--bufferIndex] = data[i];
    }
    setState(() {
      dataString = String.fromCharCodes(buffer);
    });

    //if (dataString == 'runo') print("agora vai vaivai trabalhar!!");
    print(dataString);

    /*   bool ponto = dataString.contains('f');
    if (ponto == true) {
      data1 += dataString;
    } else if (ponto == false) {
      print(data1);
      data1 = "";
    } */

    //bool flag = dataString.contains('unqoMigliori');
    //if (flag)
    //print("pode cre!!");
    //else
    //print('nao tem!!');

    //_sendMessage('Eai esp blz?');
  }

  void _sendMessage(String text) async {
    text = text.trim();

    if (text.length > 0) {
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        //setState(() {
        //  messages.add(_Message(clientID, text));
        //});
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }

  bool isConnected() {
    return connection != null && connection.isConnected;
  }
}
