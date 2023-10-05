import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voice_notes_app/providers/authentication.dart';
import 'package:voice_notes_app/utils/images.dart';
import 'package:voice_notes_app/utils/strings.dart';
enum AuthMode { signup, login }

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(StringsConst.notesApp),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              ImagesPath.loginSecurityImage,
              height: 200,
              fit: BoxFit.cover,
            ),
            const AuthCard(),
          ],
        ),
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  bool _isLoading = false;
  AuthMode _authMode = AuthMode.login;
  final _authData = {'email': '', 'password': ''};

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(StringsConst.errorOccured),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(StringsConst.okayMessage),
            ),
          ],
        );
      },
    );
  }

  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login ? AuthMode.signup : AuthMode.login;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.login) {
        await Provider.of<Authentication>(context, listen: false).logIn(
          email: _authData['email']!,
          password: _authData['password']!,
        );
      } else {
        await Provider.of<Authentication>(context, listen: false).signUp(
          email: _authData['email']!,
          password: _authData['password']!,
        );
      }
    } on HttpException catch (error) {
      var errorMsg = StringsConst.authFailed;
      if (error.message.contains('EMAIL_EXISTS')) {
        errorMsg = StringsConst.emailInUse;
      } else if (error.message.contains('INVALID_EMAIL')) {
        errorMsg = StringsConst.invalidEmailUsed;
      } else if (error.message.contains('WEAK_PASSWORD')) {
        errorMsg = StringsConst.weakPassword;
      } else if (error.message.contains('EMAIL_NOT_FOUND')) {
        errorMsg = StringsConst.unableToFindEmail;
      } else if (error.message.contains('INVALID_PASSWORD')) {
        errorMsg = StringsConst.invalidPassword;
      }
      _showErrorDialog(errorMsg);
    } catch (error) {
      const errorMsg = StringsConst.authFailTryAgain;
      _showErrorDialog(errorMsg);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.bounceIn,
        height: _authMode == AuthMode.signup ? 320 : 260,
        width: deviceSize.width * 0.9,
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.signup ? 320 : 260,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: StringsConst.email),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return StringsConst.invalidEmail;
                  }
                  return null;
                },
                onSaved: (email) {
                  _authData['email'] = email!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: StringsConst.password),
                obscureText: true,
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                textInputAction: _authMode == AuthMode.login
                    ? TextInputAction.done
                    : TextInputAction.next,
                onFieldSubmitted: _authMode == AuthMode.login
                    ? (_) => _submit()
                    : (_) => FocusScope.of(context).requestFocus(_confirmPasswordFocusNode),
                validator: (pass) {
                  if (pass!.isEmpty || pass.length < 5) {
                    return StringsConst.shortPassword;
                  }
                  return null;
                },
                onSaved: (pass) {
                  _authData['password'] = pass!;
                },
              ),
              if (_authMode == AuthMode.signup)
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: StringsConst.confirmPassword,
                    ),
                    obscureText: true,
                    focusNode: _confirmPasswordFocusNode,
                    onFieldSubmitted: (_) => _submit(),
                    validator: _authMode == AuthMode.signup
                        ? (pass) {
                      if (pass != _passwordController.text) {
                        return StringsConst.notMatechedPassword;
                      }
                      return null;
                    }
                        : null,
                  ),
                ),
              const SizedBox(height: 10),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 8.0,
                    ),
                    backgroundColor: Colors.grey[200],
                  ),
                  onPressed: _submit,
                  child: Text(
                    _authMode == AuthMode.login ? 'LOGIN' : 'SIGNUP',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              TextButton(
                onPressed: _switchAuthMode,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 4,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '${_authMode == AuthMode.login ? 'SIGN UP' : 'LOGIN'} INSTEAD',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}