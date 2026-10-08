import 'package:climapp_cc20262/src/enums/enviroments_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CityTileWidget extends StatelessWidget {
  const CityTileWidget({
    required this.cityName,
    required this.icon,
    required this.temperature,
    required this.onTap,
    super.key,
  });

  final String cityName;
  final String icon;
  final int temperature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const EnvironmentEnum envEnum = EnvironmentEnum.constants;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x15FFFFFF),
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          leading: SvgPicture.network('${envEnum.imageUrl}$icon.svg'),
          titleTextStyle: const TextStyle(fontSize: 20),
          textColor: Colors.white,
          title: Text(cityName, textAlign: TextAlign.center),
          trailing: Text(
            '$temperature°C',
            style: const TextStyle(color: Colors.white, fontSize: 25),
          ),
        ),
      ),
    );
  }
}
