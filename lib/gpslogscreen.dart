import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GpsLogScreen extends StatefulWidget {
  const GpsLogScreen({Key? key}) : super(key: key);

  @override
  State<GpsLogScreen> createState() => _GpsLogScreenState();
}

class _GpsLogScreenState extends State<GpsLogScreen> {
  static const EventChannel _channel = EventChannel('gps_logs');

  final List<String> _logs = [];
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = _channel.receiveBroadcastStream().listen(
      (event) {
        setState(() {
          _logs.insert(0, event.toString());
        });
      },
      onError: (error) {
        setState(() {
          _logs.insert(0, "❌ Error: $error");
        });
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GPS Service Logs"),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() => _logs.clear());
            },
          )
        ],
      ),
      body: ListView.builder(
        reverse: true,
        itemCount: _logs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              _logs[index],
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          );
        },
      ),
    );
  }
}
