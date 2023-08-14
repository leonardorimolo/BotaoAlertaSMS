import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:geolocator/geolocator.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String locationMessage = 'Current Location of the User';
  late String lat;
  late String long;
  late TwilioFlutter twilioFlutter;

  void initState() {
    super.initState();

    // Configure o Twilio com suas credenciais
    twilioFlutter = TwilioFlutter(
      accountSid: "ACb11597cd343d55f02d8d6dc7670974cf",
      authToken: '43487098cb78d4d77792198e1404c0b7',
      twilioNumber: '+13134747784',
    );

    _liveLocation(); // Inicia o rastreamento em tempo real
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void _liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      lat = position.latitude.toString();
      long = position.longitude.toString();
    });
  }

  Future<void> _sendSMS(String lat, String long) async {
    await twilioFlutter.sendSMS(
        toNumber: '+5551995882108',
        messageBody:
            "Estou em perigo! Está é minha localização https://maps.google.com/?q=$lat+$long");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Botão de Alerta'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 250,
              height: 250,
              child: FilledButton.icon(
                icon: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: const Icon(
                    Icons.add_alert_sharp,
                    size: 200.0,
                  ),
                ),
                label: const Text(
                  '',
                  style: TextStyle(fontSize: 0),
                ),
                onPressed: () async {
                  _getCurrentLocation().then((value) async {
                    lat = value.latitude.toString();
                    long = value.longitude.toString();

                    _liveLocation();

                    try {
                      await _sendSMS(lat, long);
                      print(
                          "Estou em perigo! Esta é minha localização: https://maps.google.com/?q=$lat+$long");
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Alerta enviado com sucesso!"),
                      ));
                    } catch (e) {
                      print("Erro ao enviar alerta: $e");
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Erro ao enviar o alerta."),
                      ));
                    }
                  });
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll<Color>(Colors.red),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
