import 'package:device_tracker/helper/device_inf.dart';
import 'package:device_tracker/login_system/register/screen/register_form.dart';
import 'package:device_tracker/login_system/register/screen/register_screen.dart';
import 'package:device_tracker/repository/user_repository.dart';
import 'package:flutter/material.dart';

class CreateAccountButton extends StatelessWidget {
  final UserRepository _userRepository;
  DeviceInfo deviceInfo = DeviceInfo();

  CreateAccountButton({Key? key, required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(
        'Create an Account',
      ),
      onPressed: () async{
        //await deviceInfo.getModel();
        //RegisterForm(deviceName: deviceInfo.android,);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) {
            return RegisterScreen(userRepository: _userRepository);
          }),
        );
      },
    );
  }
}