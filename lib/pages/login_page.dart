import 'package:flutter/material.dart';
import 'package:flutter_firebase_day1/pages/home_page.dart';
import 'package:flutter_firebase_day1/pages/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  GoogleSignIn googleSignIn = GoogleSignIn(
    clientId:
        '194165858330-vt8ls1j8vu1uqgeb5n8d3d3mrmu9r8j3.apps.googleusercontent.com',
  );

  Future signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // print('google user is null');
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final login = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      // print(login);
      // print(googleUser);

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print("Google Signin error $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Welcome back",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  "Login to your account",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "Enter your email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r"^[^@]+@[^@]+\.[^@]+").hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Enter your password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: const Icon(Icons.password),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your password";
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 15),
                isLoading? CircularProgressIndicator() :
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {

                      if (_formKey.currentState!.validate()) {
                        setState(() {
                        isLoading = true;
                      });
                        try {
                          isLoading = true;
                          final credential = await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );
                          isLoading= false;
                          await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
                          Navigator.of(context).pushReplacementNamed("/home");
                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'user-not-found') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("User not found")),
                            );
                          } else if (e.code == 'wrong-password') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Password is Wrong")),
                            );
                          }
                        }finally {
                          if (mounted) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      }
                    },
                    child: const Text("Login",style: TextStyle(color: Colors.black87,fontSize: 16),),
                  ),
                ),
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20,),
                isLoading? CircularProgressIndicator() :
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.blueGrey,
                    ),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        final GoogleSignInAccount? googleUser = await googleSignIn
                            .signIn();
                        // final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
                        if (googleUser == null) {
                          // print('google user is null');
                          return null;
                        }

                        final GoogleSignInAuthentication googleAuth =
                            await googleUser.authentication;

                        final credential = GoogleAuthProvider.credential(
                          accessToken: googleAuth.accessToken,
                          idToken: googleAuth.idToken,
                        );

                        final login = await FirebaseAuth.instance
                            .signInWithCredential(credential);
                        // print(login);
                        // print(googleUser);
                        await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
                        Navigator.pushReplacementNamed(context, '/home');
                      } catch (e) {
                        print("Google Signin error $e");
                        return null;
                      } finally {
                        // لازم نرجّع isLoading = false سواء العملية نجحت أو فشلت
                        if (mounted) {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      }
                    },
                    child: Text(
                      'Sign in with Google',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),

                  ),
                ),
                SizedBox(height: 20,),
                isLoading? CircularProgressIndicator() :
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.blueGrey,
                    ),
                    onPressed: () async {
                      try {
                        final LoginResult loginResult = await FacebookAuth.instance.login();

                        if (loginResult.status == LoginStatus.success) {
                          final AccessToken? accessToken = loginResult.accessToken;

                          final OAuthCredential facebookAuthCredential =
                          FacebookAuthProvider.credential(accessToken!.tokenString);

                          await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          print('Facebook login failed: ${loginResult.message}');
                        }
                      } catch (e) {
                        print("Facebook Signin error: $e");
                      }
                    },
                    child: Text(
                      'Sign in with facebook',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
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
