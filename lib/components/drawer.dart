import 'package:flutter/material.dart';
import 'package:sky_luxury/components/strings.dart';

class CustomDrawer extends StatelessWidget {
  final Function() onTap;
  const CustomDrawer({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          height: size.height * 0.25,
          width: size.width,
          padding: EdgeInsets.all(12),
          decoration: gradientColor(),
          child: CircleAvatar(
            foregroundImage: AssetImage(
              Strings.adminPicture,
            ),
          ),
        ),
        ListTile(
            leading: Icon(
              Icons.logout,
              color: Strings.kPrimaryColor,
            ),
            title: Text(
              'Logout',
              style: TextStyle(fontSize: 18),
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: onTap),
      ],
    );
  }

  BoxDecoration gradientColor() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.blue,
          Strings.kPrimaryColor,
        ],
      ),
    );
  }
}
