import 'package:admin_homeservicemaintenance/components/form_validation.dart';
import 'package:flutter/material.dart';

class Mylogin extends StatefulWidget {
  const Mylogin({super.key});

  @override
  State<Mylogin> createState() => _MyloginState();
}

class _MyloginState extends State<Mylogin> {
  final TextEditingController emailController =TextEditingController();
  final TextEditingController passwordController =TextEditingController();
  final formKey =  GlobalKey<FormState>();
  bool _isVisible = true;

    String email = '';
    String password = '';

  void submit(){
  
    setState(() {
      email = emailController.text;
      password =passwordController.text; 
      
    });
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
                    color:Colors.white
                    // const Color.fromARGB(255, 211, 233, 255)
                    ),
                child: Center(
                  child: Form(
                    key: formKey,
                    child: SizedBox(
                      width: 400,
                      height: 500,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Welcome Back",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color:const Color(0xFFFF9800),
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                        
                          SizedBox(
                            height: 10,
                          ),
                    
                          Text(
                            "Login to Continue",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: const Color.fromARGB(255, 24, 56, 111))
                                //const Color(0xFF1A73E8)),
                          ),
                          
                          SizedBox(
                            height: 30,
                          ),
                          
                          Text(
                            "Email Address",
                            textAlign:TextAlign.start,
                            style: TextStyle(
                                color: const Color.fromARGB(255, 24, 56, 111)),
                            
                          ),
                            SizedBox(
                            height: 10,
                          ),
                    
                          TextFormField(
                            validator: (value) => FormValidation.validateEmail(value),
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                
                                borderSide: BorderSide(
                                  color:  const Color.fromARGB(255, 24, 56, 111),
                                  width: 1,
                          
                                )
                              ),
                    
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:const Color.fromARGB(255, 24, 56, 111),
                                  width: 2,
                                )
                              ),
                               
                            ),
                          ),
                    
                          
                            SizedBox(
                            height: 20,
                          ),
                    
                          Text(
                            "Password",
                            textAlign:TextAlign.start,
                            style: TextStyle(
                                color: const Color.fromARGB(255, 24, 56, 111)),
                            
                          ),
                    
                            SizedBox(
                            height: 10,
                          ),
                    
                          TextFormField(
                            controller: passwordController,
                            validator:(value)=> FormValidation.validatePassword(value),
                            obscureText: _isVisible,
                            // keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:  const Color.fromARGB(255, 24, 56, 111),
                                  width: 1,
                                  
                                )
                              ),
                                suffixIcon: IconButton(onPressed: (){
                                  setState(() {
                                    _isVisible=!_isVisible;
                                  });
                                }, icon: Icon( _isVisible ? Icons.visibility_off : Icons.visibility)),
                               focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: const Color.fromARGB(255, 24, 56, 111),
                                  width: 2,
                                )
                              ),
                    
                            ),
                          ),
                    
                             SizedBox(
                            height: 30,
                          ),
                    
                          ElevatedButton(onPressed: (){
                              if(formKey.currentState!.validate())  {
                                print("Validated");
                                submit();
                              }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: ContinuousRectangleBorder(),
                            backgroundColor: const Color(0xFFFF9800)
                          ), child: Padding(
                            padding: const EdgeInsets.all(9.0),
                            child: Text("Sign in",style: TextStyle(color: const Color.fromARGB(255, 24, 56, 111)),),
                          ),),
                    
                              SizedBox(
                            height: 20,
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
                  color: 
                  //  const Color(0xFFBBE3EF),
                  const Color.fromARGB(255, 211, 233, 255),
                  image: DecorationImage(image: AssetImage('assets/rem.png')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
