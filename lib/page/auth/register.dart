import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController? usernameController;
  TextEditingController? nameController;
  TextEditingController? passwordController;
  bool isObscure = true;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    usernameController = TextEditingController();
    nameController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Future<void> registerApi(
        String username, String password, String fullname) async {
      var api = "https://canihave.my.id:443/users";

      final response = await http.post(
        Uri.parse(api),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'fullname': fullname,
        }),
      );

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
                content: Text("Register Berhasil"),
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
              content: Text("Register Gagal, Server sibuk"),
            ),
          );
        });
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(size.width * 0.035),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Register",
                  style: TextStyle(
                    fontSize: size.height * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                Text(
                  "And start taking notes your idea",
                  style: TextStyle(
                    fontSize: size.height * 0.02,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: size.height * 0.03),

                /// form
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Username
                      Text(
                        "Username",
                        style: TextStyle(
                          fontSize: size.height * 0.02,
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),
                      TextFormField(
                        controller: usernameController,
                        decoration: const InputDecoration(
                          hintText: "Masukan Username",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          // value = 'hdr.rw.agus@gmail.com';
                          if (value == "") {
                            return "Username harus diisi";
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: size.height * 0.02),

                      /// nama
                      Text(
                        "Nama",
                        style: TextStyle(
                          fontSize: size.height * 0.02,
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: "Masukan Nama Anda",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          // value="Abcd@1234";
                          if (value == "") {
                            return "Nama harus diisi";
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: size.height * 0.02),

                      /// password
                      Text(
                        "Password",
                        style: TextStyle(
                          fontSize: size.height * 0.02,
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),
                      TextFormField(
                        controller: passwordController,
                        obscureText: isObscure,
                        decoration: InputDecoration(
                          hintText: "Masukan Password",
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isObscure = !isObscure;
                              });
                            },
                            icon: Icon(
                              isObscure == true
                                  ? Icons.remove_red_eye
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: (value) {
                          // value="Abcd@1234";
                          if (value == "") {
                            return "Password harus diisi";
                          }
                          if (value!.length < 8) {
                            return "Password harus memiliki 8 karakter";
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: size.height * 0.075),

                      /// button
                      SizedBox(
                        height: size.height * 0.06,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              registerApi(
                                usernameController!.text,
                                passwordController!.text,
                                nameController!.text,
                              );
                            }
                            FocusScope.of(context).unfocus();
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(
                              fontSize: size.height * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      /// Text button
                      SizedBox(height: size.height * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Punya Akun?",
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(fontSize: size.height * 0.02),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
