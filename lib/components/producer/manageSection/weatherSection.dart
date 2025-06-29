import 'package:flutter/material.dart';
import 'package:harvestly/core/services/other/weather_service.dart';
import 'package:provider/provider.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';

class WeatherForecastSection extends StatefulWidget {
  const WeatherForecastSection({super.key});

  @override
  State<WeatherForecastSection> createState() => _WeatherForecastSectionState();
}

class _WeatherForecastSectionState extends State<WeatherForecastSection> {
  late Future<List<Map<String, dynamic>>> _forecastFuture;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser! as ProducerUser;
    final store =
        user.stores[Provider.of<AuthNotifier>(
          context,
          listen: false,
        ).selectedStoreIndex!];
    final lat = store.coordinates?.latitude;
    final lon = store.coordinates?.longitude;

    if (lat != null && lon != null) {
      _forecastFuture = WeatherService().get5DayForecast(lat: lat, lon: lon);
    } else {
      _forecastFuture = Future.error('Coordenadas da banca não disponíveis');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser! as ProducerUser;
    final store =
        user.stores[Provider.of<AuthNotifier>(context).selectedStoreIndex!];
    final city = store.city;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Previsão 6 dias ($city)",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _forecastFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text('Erro: ${snapshot.error}');
              }

              final forecast = snapshot.data!;
              return ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: forecast.length,
                separatorBuilder:
                    (_, __) => Container(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Divider(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        height: 1,
                        thickness: 1,
                      ),
                    ),
                itemBuilder: (context, index) {
                  final day = forecast[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            day['day'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              day['description'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).colorScheme.onSurface
                                    .withAlpha((0.6 * 255).toInt()),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),
                        Image.network(
                          'https://openweathermap.org/img/wn/${day['iconCode']}@2x.png',
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                        Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${day['tempMax']}°C',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${day['tempMin']}°C mín',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withAlpha((0.7 * 255).toInt()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
