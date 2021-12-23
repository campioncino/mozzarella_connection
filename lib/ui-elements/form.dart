import 'package:flutter/material.dart';
import 'package:supa_auth_flutter/utils/supabase.dart';
import 'package:email_validator/email_validator.dart';

class AuthForm extends StatefulWidget {
  final String titleText;
  const AuthForm({Key? key, required this.titleText}) : super(key: key);

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.titleText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
              TextFormField(
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !EmailValidator.validate(_email.text)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                  hintText: 'Enter your email',
                ),
                style: const TextStyle(
                  color: Colors.white,
                ),
                controller: _email,
              ),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Please enter a password that is atleast 6 characters long';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.lock),
                  prefixStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  hintText: 'Enter your password',
                ),
                style: const TextStyle(
                  color: Colors.white,
                ),
                controller: _password,
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: Text(
                    widget.titleText == 'Sign In' ? 'Sign In' : 'Sign Up',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        widget.titleText == 'Sign In') {
                      try {
                        SupabaseHelper()
                            .signInExistingUser(_email.text, _password.text);
                        Navigator.pushNamed(context, '/home');
                      } catch (e) {
                        throw Exception(e.toString());
                      }
                    } else if (_formKey.currentState!.validate() &&
                        widget.titleText == 'Sign Up') {
                      try {
                        SupabaseHelper()
                            .createNewUser(_email.text, _password.text);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              contentPadding: const EdgeInsets.all(16),
                              backgroundColor: Colors.grey[800],
                              title: const Text(
                                'Verification code sent!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white70,
                                ),
                              ),
                              content: const Text(
                                'Please check your email to verify and continue',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white60,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Got it',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        _email.text = '';
                        _password.text = '';
                      } catch (e) {
                        throw Exception(e.toString());
                      }
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (widget.titleText == 'Sign In')
                Column(
                  children: [
                    TextButton(
                      child: const Text('Forgot Password? Click here'),
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot-password');
                      },
                    ),
                    TextButton(
                      child: const Text('Don\'t have an account? Sign Up'),
                      onPressed: () {
                        Navigator.pushNamed(context, '/sign-up');
                      },
                    ),
                  ],
                ),
              if (widget.titleText == 'Sign Up')
                TextButton(
                  child: const Text('Already have an account? Sign In'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/');
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}