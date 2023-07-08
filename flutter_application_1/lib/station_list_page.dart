import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StationListPage extends StatefulWidget {
  @override
  _StationListPageState createState() => _StationListPageState();
}

class _StationListPageState extends State<StationListPage> {
  late Future<List<dynamic>> provinces;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    provinces = fetchProvinces();
  }

  Future<List<dynamic>> fetchProvinces() async {
    final response = await http.get(
        Uri.parse('http://dev.farizdotid.com/api/daerahindonesia/provinsi'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<dynamic>.from(data['provinsi']);
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  List<dynamic> filterProvinces(List<dynamic> provinces, String query) {
    return provinces
        .where((province) =>
            province['nama'].toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void navigateToStationDetail(dynamic province) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StationDetailPage(province: province),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Province List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  provinces = fetchProvinces().then((data) {
                    return filterProvinces(data, value);
                  });
                });
              },
              decoration: InputDecoration(
                labelText: 'Search',
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: provinces,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          navigateToStationDetail(snapshot.data![index]);
                        },
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(snapshot.data![index]['nama']),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class StationDetailPage extends StatefulWidget {
  final dynamic province;
  final Color backgroundColor = Color(0xFF7895CB);

  StationDetailPage({Key? key, required this.province}) : super(key: key);

  @override
  _StationDetailPageState createState() => _StationDetailPageState();
}

class _StationDetailPageState extends State<StationDetailPage> {
  late Future<List<dynamic>> cities;

  @override
  void initState() {
    super.initState();
    cities = fetchCities();
  }

  Future<List<dynamic>> fetchCities() async {
    final response = await http.get(Uri.parse(
        'http://dev.farizdotid.com/api/daerahindonesia/kota?id_provinsi=${widget.province['id']}'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<dynamic>.from(data['kota_kabupaten']);
    } else {
      throw Exception('Failed to load cities');
    }
  }

  void navigateToCityDetail(dynamic city) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CityDetailPage(city: city),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.province['nama']),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: cities,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    navigateToCityDetail(snapshot.data![index]);
                  },
                  child: Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(snapshot.data![index]['nama']),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class CityDetailPage extends StatelessWidget {
  final dynamic city;
  final Color backgroundColor = Color(0xFF7895CB);

  CityDetailPage({Key? key, required this.city}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(city['nama']),
      ),
      body: Container(
        color: backgroundColor,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              city['nama'],
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: StationListPage(),
  ));
}
