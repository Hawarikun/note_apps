import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:note_apps/data/shared_preferences.dart';
import 'package:note_apps/model/notes.dart';

class AddNotesPage extends StatefulWidget {
  const AddNotesPage({super.key});

  @override
  State<AddNotesPage> createState() => _AddNotesPageState();
}

class _AddNotesPageState extends State<AddNotesPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  TextEditingController labelController = TextEditingController();
  List<String> labels = [];

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    labelController.dispose();
    super.dispose();
  }

  Future<void> addNotesApi() async {
    var api = "https://canihave.my.id:443/notes";
    var token = await LocalPrefsRepository().getToken();

    final response = await http.post(
      Uri.parse(api),
      headers: {
        "Accept": "application/json; charset=UTF-8",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: jsonEncode({
        'body': bodyController.text,
        'tags': labels,
        'title': titleController.text,
      }),
    );

    var data = jsonDecode(response.body);

    print(data.toString());

    if (response.statusCode == 201) {
      Future.delayed(
        const Duration(milliseconds: 300),
        () {
          Future.delayed(
            const Duration(milliseconds: 300),
            () {
              Navigator.pop(context);
            },
          );
          return ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Note Berhasil Ditambahkan"),
            ),
          );
        },
      );
    } else if (response.statusCode > 400 && response.statusCode < 500) {
      var body = jsonDecode(response.body);

      var massage = body['message'];

      Future.delayed(const Duration(milliseconds: 300), () {
        return ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(massage),
          ),
        );
      });
    } else {
      Future.delayed(const Duration(milliseconds: 300), () {
        return ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal menambahkan Note, Server sibuk"),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(labels.toString());
    debugPrint(titleController.text);
    debugPrint(bodyController.text);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Notes"),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet<void>(
                isScrollControlled: true,
                enableDrag: false,
                isDismissible: false,
                useSafeArea: true,
                context: context,
                builder: (context) => StatefulBuilder(
                  builder: (context, setState) => Padding(
                    padding: EdgeInsets.all(size.width * 0.06),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Label",
                                style: TextStyle(
                                  fontSize: size.height * 0.03,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close),
                            )
                          ],
                        ),
                        const Divider(),
                        SizedBox(height: size.height * 0.03),
                        TextFormField(
                          controller: labelController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            label: Text("Label Name"),
                            border: OutlineInputBorder(),
                          ),
                          // textInputAction:
                          //     TextInputAction.done, // Aktifkan tombol "Done"
                          onFieldSubmitted: (_) {
                            setState(() {
                              labels.add(labelController.text);
                              labelController.clear();
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: size.height * 0.01),
                        Text(
                          "Press 'Enter' on Keyboard  for create another label",
                          style: TextStyle(
                            fontSize: size.height * 0.0175,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Wrap(
                          spacing: size.width * 0.05,
                          children: labels.isEmpty
                              ? []
                              : List.generate(
                                  labels.length,
                                  (index) => Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: size.width * 0.02,
                                      vertical: size.width * 0.01,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.grey.shade300,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(labels[index]),
                                        SizedBox(width: size.width * 0.01),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              labels.removeAt(index);
                                            });
                                          },
                                          child: Icon(
                                            Icons.close,
                                            size: size.height * 0.02,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.label_outline_rounded),
          ),
          IconButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                addNotesApi();
              }
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(size.width * 0.006),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: titleController,
                  style: TextStyle(
                    fontSize: size.height * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Title Hire",
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: bodyController,
                  style: TextStyle(
                    fontSize: size.height * 0.02,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Body Hire",
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                SizedBox(height: size.height * 0.02),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: size.width * 0.02),
                  child: Wrap(
                    spacing: size.width * 0.05,
                    children: labels.isEmpty
                        ? []
                        : List.generate(
                            labels.length,
                            (index) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.02,
                                vertical: size.width * 0.01,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.grey.shade300,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    labels[index],
                                    style: TextStyle(
                                      fontSize: size.height * 0.02,
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.01),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        labels.removeAt(index);
                                      });
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: size.height * 0.02,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
