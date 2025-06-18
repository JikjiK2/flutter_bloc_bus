import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class textFormRxDart extends StatefulWidget {
  @override
  _textFormRxDartState createState() => _textFormRxDartState();
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class _textFormRxDartState extends State<textFormRxDart> {
  final _emailSubject = BehaviorSubject<String>();
  final _passwordSubject = BehaviorSubject<String>();
  final _nameSubject = BehaviorSubject<String>();
  final _formValidSubject = BehaviorSubject<bool>.seeded(false);

  FocusNode btnFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    Rx.combineLatest2(
        _emailSubject.stream.map(_validateEmail),
        _passwordSubject.stream.map(_validatePassword),
            (emailValid, passwordValid) => emailValid && passwordValid)
        .listen((isValid) {
      _formValidSubject.add(isValid);
    });
  }

  bool _validateEmail(String email) {
    final bool emailRegExp;
    emailRegExp = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
    if (email.isNotEmpty && emailRegExp) {
      return true;
    } else {
      return false;
    }
  }

  bool _validatePassword(String password) {
    final bool passwordRegExp;
    //영문 대소문자, 숫자, 특수문자, 최소 1개 이상 포함\n비밀번호 8 - 25자리\n특수문자 @ \$ ! % * ? &
    passwordRegExp = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,25}$')
        .hasMatch(password);
    if (password.isNotEmpty && passwordRegExp) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _emailSubject.close();
    _passwordSubject.close();
    _nameSubject.close();
    _formValidSubject.close();
    super.dispose();
  }

  final TextEditingController EmailController = TextEditingController();
  final TextEditingController PWController = TextEditingController();


  bool _passwordVisible = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
          child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 30.0,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IconButton(
                        padding: EdgeInsets.only(right: 30.0),
                        icon: Icon(Icons.keyboard_backspace),
                        splashRadius: 20,
                        splashColor: Colors.transparent,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Text(
                        "회원가입",
                        style: TextStyle(fontSize: 25),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              "이메일 주소",
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        TextField(
                          maxLines: 1,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          cursorColor: Colors.black,
                          controller: EmailController,
                          onChanged: (text) => _emailSubject.add(text),
                        ),
                        Row(
                          children: [
                            const Text(
                              "비밀번호",
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        TextFormField(
                          style: TextStyle(fontFamily: ''),
                          maxLines: 1,
                          keyboardType: TextInputType.visiblePassword,
                          cursorColor: Colors.black,
                          autocorrect: false,
                          obscureText: _passwordVisible,
                          controller: PWController,
                          onChanged: (text) => _passwordSubject.add(text),
                        ),
                        StreamBuilder<bool>(
                            stream: _formValidSubject.stream,
                            builder: (context, snapshot) {
                              return ElevatedButton(
                                focusNode: btnFocus,
                                onPressed: snapshot.data == true ? () {} : null,
                                style: ElevatedButton.styleFrom(
                                    splashFactory: NoSplash.splashFactory,
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white),
                                child: Text(
                                  "${snapshot.data}",
                                  style: TextStyle(fontSize: 18),
                                ),
                              );
                            }),
                        const SizedBox(
                          height: 30.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
