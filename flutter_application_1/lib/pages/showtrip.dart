import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/config.dart';
import 'package:flutter_application_1/model/response/trip_get_res.dart';
import 'package:flutter_application_1/pages/proflie.dart';
import 'package:flutter_application_1/pages/trip.dart';
import 'package:http/http.dart' as http;

class ShowtripPagState extends StatefulWidget {
  int cid = 0;
  ShowtripPagState({super.key, required this.cid});

  @override
  State<ShowtripPagState> createState() => _ShowtripPagStateState();
}

class _ShowtripPagStateState extends State<ShowtripPagState> {
  String url = '';
  List<TripGetResponse> tripGetResponses = [];
  late Future<void> loadData;

  @override
  void initState() {
    super.initState();
    loadData = getTrips();

    Configuration.getConfig().then((config) {
      url = config['apiEndpoint'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการทริป'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              log(value);
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(idx: widget.cid),
                  ),
                );
              } else if (value == 'logout') {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('ข้อมูลส่วนตัว'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('ออกจากระบบ'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ปลายทาง', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilledButton(
                        onPressed: getTrips,
                        child: const Text('ทั้งหมด'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          await filterTrips(zone: 'เอเชีย');
                        },
                        child: const Text('เอเชีย'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          await filterTrips(zone: 'ยุโรป');
                        },
                        child: const Text('ยุโรป'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          await filterTrips(
                            multiZone: ['ประเทศไทย', 'เอเชียตะวันออกเฉียงใต้'],
                          );
                        },
                        child: const Text('อาเซียน'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          await filterTrips(zone: 'ประเทศไทย');
                        },
                        child: const Text('ประเทศไทย'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: tripGetResponses.map((trip) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    trip.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        trip.coverimage,
                                        width: 200,
                                        height: 150,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.error,
                                                  size: 50,
                                                ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text("ประเทศ: ${trip.country}"),
                                          Text("ระยะเวลา: ${trip.duration}"),
                                          Text("ราคา: ${trip.price}"),
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: FilledButton(
                                              onPressed: () =>
                                                  gotoTrip(trip.idx),
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Colors.purple,
                                              ),
                                              child: const Text(
                                                'รายละเอียดเพิ่มเติม',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void gotoTrip(int idx) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TripPage(idx: idx)),
    );
  }

  Future<void> getTrips() async {
    var config = await Configuration.getConfig();
    url = config['apiEndpoint'];

    var res = await http.get(Uri.parse('$url/trips'));
    // log(res.body);

    tripGetResponses = tripGetResponseFromJson(res.body);
    log(tripGetResponses.length.toString());
  }

  Future<void> filterTrips({String? zone, List<String>? multiZone}) async {
    await getTrips();
    setState(() {
      if (zone != null) {
        tripGetResponses = tripGetResponses
            .where((trip) => trip.destinationZone == zone)
            .toList();
      } else if (multiZone != null) {
        tripGetResponses = tripGetResponses
            .where((trip) => multiZone.contains(trip.destinationZone))
            .toList();
      }
    });
  }
}
