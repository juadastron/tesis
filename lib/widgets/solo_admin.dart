import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class SoloAdmin extends StatelessWidget {
  final Widget child;

  const SoloAdmin({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return userProvider.rol == 'admin' ? child : const SizedBox.shrink();
  }
}
