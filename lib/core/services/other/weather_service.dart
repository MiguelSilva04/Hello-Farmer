import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_remote_config/firebase_remote_config.dart';

class WeatherService {
  late final FirebaseRemoteConfig _remoteConfig;

  WeatherService() {
    _remoteConfig = FirebaseRemoteConfig.instance;
  }

  Future<void> _initRemoteConfig() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await _remoteConfig.fetchAndActivate();
  }

  Future<List<Map<String, dynamic>>> get5DayForecast({
    required double lat,
    required double lon,
  }) async {
    await _initRemoteConfig();
    final apiKey = _remoteConfig.getString('OPEN_WEATHER_API_KEY');

    if (apiKey.isEmpty) {
      throw Exception("API Key está inválida");
    }

    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&lang=pt&appid=$apiKey',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List list = data['list'];

        final Map<String, List<dynamic>> dailyGroups = {};

        for (var item in list) {
          final dateTime = DateTime.tryParse(item['dt_txt'] ?? '');
          if (dateTime == null) continue;

          final dateKey = '${dateTime.year}-${dateTime.month}-${dateTime.day}';
          dailyGroups.putIfAbsent(dateKey, () => []).add(item);
        }

        final diasSemana = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

        return dailyGroups.entries.take(5).map((entry) {
          final date = DateTime.parse(entry.value.first['dt_txt']);
          final diaSemana = diasSemana[date.weekday - 1];

          double minTemp = double.infinity;
          double maxTemp = -double.infinity;
          String icon = '';
          String description = '';

          for (var item in entry.value) {
            final tempMin = (item['main']?['temp_min'] ?? 0).toDouble();
            final tempMax = (item['main']?['temp_max'] ?? 0).toDouble();

            if (tempMin < minTemp) minTemp = tempMin;
            if (tempMax > maxTemp) maxTemp = tempMax;

            if (icon.isEmpty &&
                item['weather'] != null &&
                item['weather'].isNotEmpty) {
              var rawIcon = item['weather'][0]['icon'] as String? ?? '';
              icon = rawIcon.isNotEmpty
                  ? rawIcon.substring(0, rawIcon.length - 1) + 'd'
                  : '';
              description = item['weather'][0]['description'] ?? '';
            }
          }

          return {
            'day': diaSemana,
            'tempMin': minTemp.round(),
            'tempMax': maxTemp.round(),
            'iconCode': icon,
            'description': description,
          };
        }).toList();
      } else {
        throw _handleHttpError(response.statusCode);
      }
    } catch (e) {
      throw Exception("Erro na previsão do tempo: ${e.toString()}");
    }
  }

  Exception _handleHttpError(int statusCode) {
    switch (statusCode) {
      case 401:
        return Exception("API Key inválida");
      case 429:
        return Exception("Limite de chamadas excedido");
      case 404:
        return Exception("Cidade ou localização não encontrada");
      default:
        return Exception("Erro inesperado (${statusCode})");
    }
  }
}
