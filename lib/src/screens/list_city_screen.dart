import 'package:climapp_cc20262/src/controller/list_city_controller.dart';
import 'package:climapp_cc20262/src/screens/no_connection_screen.dart';
import 'package:climapp_cc20262/src/screens/weather_city_screen.dart';
import 'package:climapp_cc20262/src/widgets/city_tile_widget.dart';
import 'package:climapp_cc20262/src/screens/compass_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListCityScreen extends StatefulWidget {
  const ListCityScreen({super.key});

  @override
  State<ListCityScreen> createState() => _ListCityScreenState();
}

class _ListCityScreenState extends State<ListCityScreen> {
  final TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ListCityController>(
      builder: (context, controller, child) {
        if (controller.errorMessage.isNotEmpty &&
            !controller.isLoading &&
            controller.allCities.isEmpty) {
          return const NoConnectionScreen();
        }

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CompassMapScreen()),
              );
            },
            label: const Text('Ver mapa'),
            icon: const Icon(Icons.explore),
          ),
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[Color(0xFF00457D), Color(0xFF05051F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(height: 25),
                  if (controller.isOfflineMode)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0x33FFC107),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.amberAccent.withValues(alpha: 0.6),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            color: Colors.amberAccent,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Modo Offline — Exibindo dados salvos',
                            style: TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: textController,
                    onChanged: (query) {
                      context.read<ListCityController>().filterCities(query);
                    },
                    decoration: const InputDecoration(
                      fillColor: Color(0x15FFFFFF),
                      filled: true,
                      hintText: 'Digite uma cidade',
                      hintStyle: TextStyle(color: Colors.white),
                      suffixIcon: Icon(Icons.search, color: Colors.white),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (controller.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () async {
                            await context
                                .read<ListCityController>()
                                .loadCities();
                          },
                          child: ListView.builder(
                            itemCount: controller.filteredCities.length,
                            itemBuilder: (context, index) {
                              final city = controller.filteredCities[index];
                              return CityTileWidget(
                                cityName: city.cityName,
                                icon: city.conditionSlug,
                                temperature: city.temp,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WeatherCityScreen(
                                        weatherForecastModel: city,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
