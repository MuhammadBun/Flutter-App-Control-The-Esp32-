import 'package:web_socket_channel/io.dart';

class ConnectionToEsp32 {
  late IOWebSocketChannel channel;
  bool ledstatus = false; //boolean value to track LED status, if its ON or OFF

  bool connected = false; //boolean value to track if WebSocket is connected
   channelconnect() {
    //function to connect
    try {
      channel =
          IOWebSocketChannel.connect("ws://192.168.0.1:81"); //channel IP : Port
      channel.stream.listen(
        (message) {
          print(message);
             if (message == "connected") {
              connected = true; //message is "connected" from NodeMCU
            }  
         },
        onDone: () {
          //if WebSocket is disconnected
          print("Web socket is closed");
             connected = false;
         },
        onError: (error) {
          print(error.toString());
        },
      );
    } catch (_) {
      print("error on connecting to websocket.");
    }
  }

  Future<void> sendcmd(String cmd) async {
    if (connected == true) {
      channel.sink.add(cmd); //sending Command to NodeMCU
      print(cmd);
    } else {
      channelconnect();
      print("Websocket is not connected.");
    }
  }
}
