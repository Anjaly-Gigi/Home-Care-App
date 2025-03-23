import 'package:admin_homeservicemaintenance/components/form_validation.dart';
import 'package:admin_homeservicemaintenance/main.dart';
import 'package:admin_homeservicemaintenance/screens/Homepage.dart';
import 'package:flutter/material.dart';

class Mylogin extends StatefulWidget {
  const Mylogin({super.key});

  @override
  State<Mylogin> createState() => _MyloginState();
}

class _MyloginState extends State<Mylogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String n = '';
  String p = '';
  final formKey = GlobalKey<FormState>();
  bool _isVisible = true;

Future<void> login() async {
  try {
    final authResponse = await supabase.auth.signInWithPassword(
      password: passwordController.text,
      email: emailController.text,
    );

    final user = authResponse.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication failed. Please check your credentials.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    String id = user.id;
    final response = await supabase
        .from('tbl_admin')
        .select()
        .eq('id', id)
        .maybeSingle(); 

    
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Myhome(),
        ),
      );
  } catch (e) {
    print('error: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color.fromARGB(255, 182, 223, 255),
                      const Color.fromARGB(255, 190, 227, 255),
                      const Color.fromARGB(255, 182, 223, 255),
                    ],
                  ),
                ),
                child: Center(
                  child: Form(
                    key: formKey,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      width: 400,
                      height: 500,
                      padding: EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Welcome Back",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 24, 56, 111),
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Please enter details",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 24, 56, 111),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 30),
                          TextFormField(
                            validator: (value) => FormValidation.validateEmail(value),
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: "Enter your email",
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            validator: (value) => FormValidation.validatePassword(value),
                            controller: passwordController,
                            obscureText: _isVisible,
                            decoration: InputDecoration(
                              hintText: "Enter your password",
                              prefixIcon: Icon(Icons.password),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isVisible = !_isVisible;
                                  });
                                },
                                icon: Icon(_isVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                login();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 24, 56, 111),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.white],
                  ),
                  image: DecorationImage(
                    image: AssetImage('assets/home1.png'),
                    fit: BoxFit.contain,
                    opacity: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
