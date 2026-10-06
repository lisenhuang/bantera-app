import 'package:flutter/material.dart';

class AiAvatar extends StatelessWidget {
  const AiAvatar({super.key, this.radius = 22, this.online = false});
  final double radius;
  final bool online;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      CircleAvatar(
        radius: radius,
        backgroundImage: const AssetImage('assets/icon.png'),
      ),
      if (online)
        const Positioned(
          right: 0,
          bottom: 0,
          child: CircleAvatar(radius: 6, backgroundColor: Colors.green),
        ),
    ],
  );
}
