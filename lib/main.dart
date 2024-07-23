import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:ussd_advanced/ussd_advanced.dart';

void main() {
  runApp(const MyApp());
}

class BackgroundService {
  static void onBackgroundMessage(SmsMessage message) {
    if (message.address == "OrangeMoney") {
      String body = message.body ?? "Error reading message body.";

      // Regex pattern to match the amount
      RegExp amountRegex = RegExp(r'(\d+(?:\.\d+)?) FCFA');
      Match? amountMatch = amountRegex.firstMatch(body);
      String amount = amountMatch?.group(0) ?? "Amount not found";

      // Regex pattern to match the transaction ID
      RegExp transIdRegex = RegExp(r'Trans ID: ([A-Z0-9.]+)');
      Match? transIdMatch = transIdRegex.firstMatch(body);
      String transId = transIdMatch?.group(1) ?? "Transaction ID not found";

      print("Amount: $amount");
      print("Transaction ID: $transId");
    } else {
      print("not from OrangeMoney");
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late TextEditingController _controller;
  String? _response;

  String _message = "";
  final telephony = Telephony.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> initPlatformState() async {
    final bool? result = await telephony.requestPhoneAndSmsPermissions;
    if (result != null && result) {
      telephony.listenIncomingSms(
          onNewMessage: onMessage,
          onBackgroundMessage: BackgroundService.onBackgroundMessage);
    }
  }

  void onMessage(SmsMessage message) {
    if (message.address == "OrangeMoney") {
      String body = message.body ?? "Error reading message body.";

      // Regex pattern to match the amount
      RegExp amountRegex = RegExp(r'(\d+(?:\.\d+)?) FCFA');
      Match? amountMatch = amountRegex.firstMatch(body);
      String amount = amountMatch?.group(0) ?? "Amount not found";

      // Regex pattern to match the transaction ID
      RegExp transIdRegex = RegExp(r'ID Trans: ([A-Z0-9.]+)');
      Match? transIdMatch = transIdRegex.firstMatch(body);
      String transId = transIdMatch?.group(1) ?? "Transaction ID not found";

      setState(() {
        _message = "Amount: $amount\nTransaction ID: $transId";
      });
    } else {
      setState(() {
        _message = "Error: SMS not from Orange Money";
      });
    }
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        // Mettre à jour le contenu du message lorsque l'application redevient active
        _message = "Dernier message reçu : $_message";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ussd Plugin example'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            // text input
            // TextField(
            //   controller: _controller,
            //   keyboardType: TextInputType.phone,
            //   decoration: const InputDecoration(labelText: 'Ussd code'),
            // ),
            Center(child: Text(_message)),

            // dispaly responce if any
            if (_response != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(_response!),
              ),

            // buttons
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    UssdAdvanced.sendUssd(code: "*144*2*1*56520669*1#", subscriptionId: 1);
                  },
                  child: const Text('norma\nrequest'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

