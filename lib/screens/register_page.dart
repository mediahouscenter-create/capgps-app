import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:http/http.dart';
import 'package:maktrogps/config/static.dart';
import 'package:maktrogps/screens/sign_in.dart';

import 'package:maktrogps/ui/reusable/cache_image_network.dart';

import '../data/datasources.dart';



class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameCTR = TextEditingController();
  final TextEditingController _phoneCTR = TextEditingController();
  //final TextEditingController _passwordCTR = TextEditingController();

  //final TextEditingController _confirmPasswordCTR = TextEditingController();
  //email
  final TextEditingController _emailCtr = TextEditingController();

  bool _isPasswordVisible = true;
  // toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  final Color _underlineColor = const Color(0xFFCCCCCC);

  //global key for form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //register function

  void _register() async {
    if (_formKey.currentState!.validate()) {
      // if all are valid then go to success screen

      //show loading indicator
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });

      try {

        Response result = await gpsapis.getRegister(
            _nameCTR.text, _emailCtr.text,_phoneCTR.text, "123456");

        print(result);
        print(result);
        var data = json.decode(result.body);

        if (data['status'] == 0) {
          Navigator.pop(context);
          var errorMessages = data['errors']['email'][0];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessages),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (data['status'] == 1) {
         // Navigator.pop(context);


          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration Successful'),
              backgroundColor: Colors.green,
            ),
          );

         String password= data['item']["password_to_email"].toString();

         String text=  'Your App Login and password\n\n'+
             'email:  '+_emailCtr.text+
             '\n\n password:  '+password;


          Response result = await gpsapis.sendwhatsappsms(
              _phoneCTR.text,text);
         print(password);
         print(password);

          Navigator.pop(context);
          //navigate to setup device page
          // Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => SetupDevice(
          //               isFromRegisterPage: true,
          //             )));
        }
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 47, 105, 126),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Column(
              children: [
                Container(
                    margin: EdgeInsets.fromLTRB(
                        0, MediaQuery.of(context).size.height / 9, 0, 0),
                    alignment: Alignment.topCenter,
                    child:buildCacheNetworkImage(width: 100, height: 100, url: StaticVarMethod.splashimageurl)
                       // Image.asset(StaticVarMethod.splashimageurl, height: 100)
                ),
                SizedBox(
                  height: 40,
                ),
                TextFormField(
                  controller: _nameCTR,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    // must have last name and first name
                    if (value!.isEmpty) {
                      return 'Please enter Your Name';
                    }
                    // check has last name
                    if (value.split(' ').length < 2) {
                      return 'Please enter Your Last Name';
                    }
                  },
                  style: const TextStyle(
                    color: Colors.white, // Set text color to white
                  ),
                  keyboardType: TextInputType.name,
                  onChanged: (String value) {},
                  decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[600]!)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: _underlineColor),
                      ),
                      labelText: 'Full Name',
                      labelStyle: const TextStyle(color: Colors.white)),
                ),
                // SizedBox(
                //   height: 20,
                // ),
                // TextField(
                //   controller: _usernameFieldController,
                //   style: const TextStyle(
                //     color: Colors.white, // Set text color to white
                //   ),
                //   keyboardType: TextInputType.emailAddress,
                //   onChanged: (String value) {},
                //   decoration: InputDecoration(
                //       prefixIcon: const Icon(
                //         Icons.phone,
                //         color: Colors.white,
                //       ),
                //       focusedBorder: UnderlineInputBorder(
                //           borderSide: BorderSide(color: Colors.grey[600]!)),
                //       enabledBorder: UnderlineInputBorder(
                //         borderSide: BorderSide(color: _underlineColor),
                //       ),
                //       labelText: 'Phone Number',
                //       labelStyle: const TextStyle(color: Colors.white)),
                // ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _phoneCTR,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    // must have last name and first name
                    if (value!.isEmpty) {
                      return 'Please enter Your Phone with country code';
                    }
                    // check has last name
                    // if (value.split(' ').length < 2) {
                    //   return 'Please enter Your Last Name';
                    // }
                  },
                  style: const TextStyle(
                    color: Colors.white, // Set text color to white
                  ),
                  keyboardType: TextInputType.name,
                  onChanged: (String value) {},
                  decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[600]!)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: _underlineColor),
                      ),
                      labelText: 'Phone',
                      labelStyle: const TextStyle(color: Colors.white)),
                ),
                // SizedBox(
                //   height: 20,
                // ),
                // TextField(
                //   controller: _usernameFieldController,
                //   style: const TextStyle(
                //     color: Colors.white, // Set text color to white
                //   ),
                //   keyboardType: TextInputType.emailAddress,
                //   onChanged: (String value) {},
                //   decoration: InputDecoration(
                //       prefixIcon: const Icon(
                //         Icons.phone,
                //         color: Colors.white,
                //       ),
                //       focusedBorder: UnderlineInputBorder(
                //           borderSide: BorderSide(color: Colors.grey[600]!)),
                //       enabledBorder: UnderlineInputBorder(
                //         borderSide: BorderSide(color: _underlineColor),
                //       ),
                //       labelText: 'Phone Number',
                //       labelStyle: const TextStyle(color: Colors.white)),
                // ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter Your Email';
                    }
                    if (!RegExp(
                            r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email Address';
                    }
                  },
                  controller: _emailCtr,
                  style: const TextStyle(
                    color: Colors.white, // Set text color to white
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (String value) {},
                  decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Colors.white,
                      ),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[600]!)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: _underlineColor),
                      ),
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.white)),
                ),
                // SizedBox(
                //   height: 20,
                // ),
                // TextField(
                //   controller: _usernameFieldController,
                //   style: const TextStyle(
                //     color: Colors.white, // Set text color to white
                //   ),
                //   keyboardType: TextInputType.emailAddress,
                //   onChanged: (String value) {},
                //   decoration: InputDecoration(
                //       prefixIcon: const Icon(
                //         Icons.location_on,
                //         color: Colors.white,
                //       ),
                //       focusedBorder: UnderlineInputBorder(
                //           borderSide: BorderSide(color: Colors.grey[600]!)),
                //       enabledBorder: UnderlineInputBorder(
                //         borderSide: BorderSide(color: _underlineColor),
                //       ),
                //       labelText: 'Address',
                //       labelStyle: const TextStyle(color: Colors.white)),
                // ),
                // const SizedBox(
                //   height: 20,
                // ),

                // password field and confirm password field

                // TextFormField(
                //   controller: _passwordCTR,
                //   autovalidateMode: AutovalidateMode.onUserInteraction,
                //   validator: (value) {
                //     if (value!.isEmpty) {
                //       return 'Please enter Your Password';
                //     }
                //     if (value.length < 6) {
                //       return 'Password must be at least 6 characters';
                //     }
                //   },
                //   style: const TextStyle(
                //     color: Colors.white, // Set text color to white
                //   ),
                //   obscureText: _isPasswordVisible,
                //   onChanged: (String value) {},
                //   decoration: InputDecoration(
                //       prefixIcon: const Icon(
                //         Icons.lock,
                //         color: Colors.white,
                //       ),
                //       focusedBorder: UnderlineInputBorder(
                //           borderSide: BorderSide(color: Colors.grey[600]!)),
                //       enabledBorder: UnderlineInputBorder(
                //         borderSide: BorderSide(color: _underlineColor),
                //       ),
                //       labelText: 'Password',
                //       suffixIcon: IconButton(
                //         icon: Icon(
                //           _isPasswordVisible
                //               ? Icons.visibility
                //               : Icons.visibility_off,
                //           color: Colors.white,
                //         ),
                //         onPressed: _togglePasswordVisibility,
                //       ),
                //       labelStyle: const TextStyle(color: Colors.white)),
                // ),
                // SizedBox(
                //   height: 20,
                // ),
                //
                // TextFormField(
                //   controller: _confirmPasswordCTR,
                //   autovalidateMode: AutovalidateMode.onUserInteraction,
                //   validator: (String? value) {
                //     if (value!.isEmpty) {
                //       return 'Please enter password';
                //     }
                //     if (value != _passwordCTR.text) {
                //       return 'Password does not match';
                //     }
                //     return null;
                //   },
                //   style: const TextStyle(
                //     color: Colors.white, // Set text color to white
                //   ),
                //   obscureText: _isPasswordVisible,
                //   onChanged: (String value) {},
                //   decoration: InputDecoration(
                //       prefixIcon: const Icon(
                //         Icons.lock,
                //         color: Colors.white,
                //       ),
                //       focusedBorder: UnderlineInputBorder(
                //           borderSide: BorderSide(color: Colors.grey[600]!)),
                //       enabledBorder: UnderlineInputBorder(
                //         borderSide: BorderSide(color: _underlineColor),
                //       ),
                //       labelText: 'Confirm Password',
                //       suffixIcon: IconButton(
                //         icon: Icon(
                //           _isPasswordVisible
                //               ? Icons.visibility
                //               : Icons.visibility_off,
                //           color: Colors.white,
                //         ),
                //         onPressed: _togglePasswordVisibility,
                //       ),
                //       labelStyle: const TextStyle(color: Colors.white)),
                // ),

                SizedBox(
                  height: 40,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Perform button action here

                        _register();
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) =>
                              const Color.fromARGB(255, 47, 105, 126),
                        ),
                        elevation: MaterialStateProperty.all<double>(
                            4), // Sets the elevation of the button
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                const RoundedRectangleBorder(
                          // borderRadius: BorderRadius.circular(
                          //     18.0), // Sets the border radius of the button
                          side: BorderSide(
                              color: Colors.white,
                              width: 2.0), // Sets the white border
                        )),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 3, vertical: 16),
                        child: const Text('Register'),
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: 20,
                ),
                // dont have account register here
                Container(
                  margin: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Do you have an account?',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                               // builder: (context) => const SignIn()),
                                builder: (context) => SignInWithBackground()), );
                        },
                        child: SizedBox(
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => const ContactScreen()),
                        // );
                        // Perform button action here
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) =>
                              Color.fromARGB(255, 239, 246, 249),
                        ),
                        elevation: MaterialStateProperty.all<double>(
                            4), // Sets the elevation of the button
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18.0)),
                          // borderRadius: BorderRadius.circular(
                          //     18.0), // Sets the border radius of the button
                          side: BorderSide(
                              color: Colors.white,
                              width: 2.0), // Sets the white border
                        )),
                      ),
                      child: const Text(
                        'Contact Us',
                        style: TextStyle(color: Colors.black),
                      ),
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
