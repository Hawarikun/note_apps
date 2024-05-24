import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:note_apps/data/shared_preferences.dart';
import 'package:note_apps/model/notes.dart';
import 'package:note_apps/page/auth/login.dart';
import 'package:note_apps/page/notes/add_notes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Notes>?> loginApi() async {
    var api = "https://canihave.my.id:443/notes";

    final token = await LocalPrefsRepository().getToken();

    print(token);

    final response = await http.get(
      Uri.parse(api),
      headers: <String, String>{
        "Accept": "application/json; charset=UTF-8",
        "Authorization": "Bearer $token",
      },
    );

    print(response.statusCode);

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      Map<String, dynamic> data = jsonDecode(response.body);
      var items = data['data']['notes'];

      return List.generate(
        items.length,
        (index) => Notes.fromJson(
          items[index],
        ),
      );
    } else {
      Map<String, dynamic> data = jsonDecode(response.body);
      print(data);

      return null;
    }
  }

  @override
  void initState() {
    // loginApi();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Yakin mau logout?"),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        await LocalPrefsRepository().deleteToken();
                        Future.delayed(const Duration(milliseconds: 300), () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        });
                      },
                      child: const Text("Yes"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("No"),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Notes>?>(
        future: loginApi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                  child: Text('No data found'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Text('Refresh'),
                )
              ],
            );
          } else {
            List<Notes> notes = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(size.width * 0.03),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(notes[index].title),
                    subtitle: Text(notes[index].body),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNotesPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
