import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/config.dart';
import '../model/response/trip_idx_get_res.dart';

class TripPage extends StatefulWidget {
  final int idx;
  const TripPage({super.key, required this.idx});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> {
  late Future<TripIdxGetResponse> futureTrip;

  @override
  void initState() {
    super.initState();
    futureTrip = loadDataAsync();
  }

  Future<TripIdxGetResponse> loadDataAsync() async {
    var config = await Configuration.getConfig();
    final url = config['apiEndpoint'];
    final res = await http.get(Uri.parse('$url/trips/${widget.idx}'));
    log(res.body);
    return tripIdxGetResponseFromJson(res.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trip Detail")),
      body: FutureBuilder<TripIdxGetResponse>(
        future: futureTrip,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final trip = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ชื่อทริป
                Text(
                  trip.name ?? '',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),

                Text(
                  trip.country ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                ),

                // รูป cover
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    trip.coverimage ?? '',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'ราคา: ${trip.price?.toString() ?? '-'} บาท',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color.fromARGB(255, 86, 87, 86),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  'โซน : ${trip.destinationZone ?? '-'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blueAccent,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                // ประเทศ
                const SizedBox(height: 16),
                // Buttot
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      trip.detail ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.center,
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                    child: const Text('จองเลย!!!'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
