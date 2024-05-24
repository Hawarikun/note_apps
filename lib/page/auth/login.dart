import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:note_apps/data/shared_preferences.dart';
import 'package:note_apps/page/auth/register.dart';
import 'package:note_apps/page/home/home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController? usernameController;
  TextEditingController? passwordController;
  bool isObscure = true;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    Future<void> loginApi(
      String username,
      String password,
    ) async {
      var api = "https://canihave.my.id:443/authentications";

      final response = await http.post(
        Uri.parse(api),
        headers: <String, String>{
          "Content-Type": "application/json; charset=UTF-8",
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print(response.statusCode);

      if (response.statusCode == 201) {
        Future.delayed(
          const Duration(milliseconds: 300),
          () {
            Future.delayed(
              const Duration(milliseconds: 300),
              () {
                var data = jsonDecode(response.body);

                /// save token
                LocalPrefsRepository().saveToken(data["data"]["accessToken"]);

                /// go to home
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
            );
            return ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Login Berhasil"),
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
              content: Text("Login Gagal, Server sibuk"),
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
                  "Let's Login",
                  style: TextStyle(
                    fontSize: size.height * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                Text(
                  "And notes your idea",
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
                          if (value == "") {
                            return "Nama harus diisi";
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
                              loginApi(
                                usernameController!.text,
                                passwordController!.text,
                              );
                            }
                            FocusScope.of(context).unfocus();
                          },
                          child: Text(
                            "Login",
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
                            "Tidak Punya Akun?",
                            style: TextStyle(fontSize: size.height * 0.02),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: Text(
                              "Register",
                              style: TextStyle(
                                fontSize: size.height * 0.02,
                              ),
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
