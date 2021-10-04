import 'package:flutter/material.dart';
import 'package:menu_admin/pages/sign_up/sign_up_controller.dart';
import 'package:menu_core/core/exceptions/email_already_registered.dart';
import 'package:menu_core/core/exceptions/invalid_email_exception.dart';
import 'package:menu_core/core/exceptions/weak_password_exception.dart';
import 'package:menu_core/widgets/menu_loading.dart';
import 'package:menu_core/widgets/menu_logo.dart';
import 'package:menu_core/widgets/menu_logo_admin.dart';
import 'package:menu_core/widgets/toasts/toast_utils.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = SignUpController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: _controller.isLoading
                ? Center(child: MenuLoading())
                : Padding(
                    padding:
                        const EdgeInsets.all(32), //Padding em todos os lados
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MenuLogoAdmin(),
                        SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nome',
                            prefixIcon: Icon(
                              Icons.person,
                              size: 24,
                            ),
                          ),
                          validator: (name) =>
                              name.isEmpty ? 'Campo Obrigatório' : null,
                          onSaved: _controller.setNome,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: Icon(
                              Icons.mail,
                              size: 24,
                            ),
                          ),
                          validator: (email) =>
                              email.isEmpty ? 'Campo Obrigatório' : null,
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
                          onChanged: _controller.setPassword,
                          //fica observando o campo senha
                          validator: (password) =>
                              password.isEmpty ? 'Campo Obrigatório' : null,
                          onSaved: _controller.setPassword,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Confirmar senha',
                            prefixIcon: Icon(
                              Icons.lock,
                              size: 24,
                            ),
                          ),
                          obscureText: true,
                          validator: _controller.validatePassword,
                          onSaved: (password) => _controller.validatePassword,
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
                                    await _controller.createUser();
                                    showSuccessToast('Usuário cadastrado com sucesso!');
                                    Navigator.of(context).pop();
                                  } on InvalidEmailException {
                                    showWarningToast('E-mail inválido');
                                  } on WeakPasswordException {
                                    showWarningToast(
                                        'A senha deve conter no mínimo 6 caracteres');
                                  } on EmailAlreadyRegistered {
                                    showWarningToast('E-mail já cadastrado');
                                  } on Exception {
                                    showErrorToast(
                                        'Ocorreu um erro inesperado');
                                  } finally {
                                    setState(() {
                                      _controller.setIsLoading(false);
                                    });
                                  }
                                }
                              },
                              child: Text('Confirmar'),
                            )),
                        Container(
                            width: 120,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Voltar'),
                            ))
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
