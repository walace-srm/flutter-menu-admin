import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:menu_admin/pages/home/home_page.dart';
import 'package:menu_admin/pages/sign_in/sign_in_controller.dart';
import 'package:menu_admin/pages/sign_up/sign_up_page.dart';
import 'package:menu_core/core/exceptions/admin_invalid_exception.dart';
import 'package:menu_core/core/exceptions/invalid_email_exception.dart';
import 'package:menu_core/core/exceptions/password_invalid_exception.dart';
import 'package:menu_core/core/exceptions/user_not_found_exception.dart';
import 'package:menu_core/widgets/menu_loading.dart';
import 'package:menu_core/widgets/menu_logo.dart';
import 'package:menu_core/widgets/menu_logo_admin.dart';
import 'package:menu_core/widgets/toasts/toast_utils.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = SignInController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: _controller.isLoading ? Center(child: MenuLoading()) : Container(
          child: Padding(
            padding: const EdgeInsets.all(32), //Padding em todos os lados
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MenuLogoAdmin(),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(
                      Icons.mail,
                      size: 24,
                    ),
                  ),
                  validator: (email) => email.isEmpty ? 'Campo Obrigatório' : null,
                  onSaved: _controller.setEmail,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(
                      Icons.lock,
                      size: 24,
                    ),
                  ),
                  obscureText: true,
                  validator: (password) => password.isEmpty ? 'Campo Obrigatório' : null,
                  onSaved: _controller.setPassword,
                ),
                SizedBox(height: 16),
                Container(
                    width: 120,
                    child: OutlinedButton(
                      onPressed: () async {
                        final form = _formKey.currentState;
                        if (form.validate()) {
                          form.save();
                          setState(() {
                            _controller.setIsLoading(true);
                          });
                          try {
                            final user = await _controller.login();
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => HomePage(user))
                            );
                          } on UserNotFoundException {
                            showWarningToast('Usuário ou senha inválido');
                          } on PasswordInvalidException {
                            showWarningToast('Usuário ou senha inválido');
                          } on InvalidEmailException {
                            showWarningToast('E-mail inválido');
                          } on AdminInvalidException {
                            showWarningToast('Usuário sem permissão de acesso');
                          } finally {
                            setState(() {
                              _controller.setIsLoading(false);
                            });
                          }
                        }
                      },
                      child: Text('Entrar'),
                    )
                ),
                Container(
                    width: 120,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SignUpPage(),
                          ),
                        );
                      },
                      child: Text('Cadastrar'),
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
