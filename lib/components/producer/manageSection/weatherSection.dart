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
    

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Previsão 5 dias ($city)",
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
            return SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: forecast.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final day = forecast[index];
                  return Container(
                    width: 120,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).shadowColor.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          day['day'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Image.network(
                          'https://openweathermap.org/img/wn/${day['iconCode']}@2x.png',
                          width: 48,
                          height: 48,
                        ),
                        Text(
                          '${day['tempMax']}°C',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          '${day['tempMin']}°C mín',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          day['description'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

