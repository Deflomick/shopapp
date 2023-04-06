import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../models/http_exception.dart';
enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),

                      // ..translate(-10.0), è un metodo che compensa l oggetto o che aggiunge una configurazione
                      // di compensanzione all oggetto matrix4 ma il problema è che non resitituisce un nuovo
                      // oggetto matrix4 ma restituisce void quindi se faccio translate e passo la mia discussione come
                      // -10 ma con il doppio punto che è un operatore speciale di dart
                      // dove in pratica chiama traduttore su quell oggetto ma non restituisce cioè che la tradizione
                      // restituisce ma ciò che ha restituito l istruzione precedente quindi ciò che ha restituito
                      //rotazione Z


                      /*

                      Matrix4 oggetto che descrive la trasformazione di un contenitore
                      e consente di descrivere la rotazione , ridimensionamento ,
                      offset di un contenitore in un unico oggetto , quindi è
                      un grande insieme di informazioni che contiene informazioni
                      su come posizionare questo contenitore

                       */

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          color: Theme.of(context).accentTextTheme.headline6.color,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _showErrorDialog(String message ){
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text ('Errore'),
      content: Text(message),
      actions: <Widget>[
        ElevatedButton(onPressed: (){
          Navigator.of(ctx).pop();
        }, child: Text('Okay'))
      ],
    )
    );

  }


  Future<void>  _submit() async{
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try{
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context,listen: false).login(
          _authData['email'],
          _authData['password'],
        );
      } else {
        // Sign user up
        await Provider.of<Auth>(context , listen: false).signup(
          _authData['email'],
          _authData['password'],
        );
    }



    } on HttpException catch(error){
      var errorMessage = 'Autenticazione fallita' ;
      // switch(error.toString()){
      //
      // }
      if(error.toString().contains('EMAIL_EXISTS')){
        errorMessage = 'Questo indirizzo email esiste già';
      }else if (error.toString().contains('INVALID_EMAIL')){
        errorMessage = 'EMail non valida';
      }else if (error.toString().contains('WEAK_PASSWORD')){
        errorMessage = 'Questa password troppo debole';
      }else if (error.toString().contains('EMAIL_NOT_FOUND')){
        errorMessage = 'Nessuna email trovata';
      }else if (error.toString().contains('INVALID_PASSWORD')){
        errorMessage = 'Password sbagliata';
      }
      _showErrorDialog(errorMessage);
    }catch (error ){
      const errorMessage = 'Non è possibile autenticarti , prova più tardi' ;
      _showErrorDialog(errorMessage);
    }


    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.Signup ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                          }
                        : null,
                  ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),
                        padding:
                           EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      textStyle: TextStyle(color: Colors.blue),
                    )

                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(30),
                    //),
                    // padding:
                    //     EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    // color: Theme.of(context).primaryColor,
                    // textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                TextButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,

                  //padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  //materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  //textColor: Theme.of(context).primaryColor,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 30.0 , vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    minimumSize: Size(50, 30),


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
