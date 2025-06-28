import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const _apiKey = '96cb7fae12b9fe19e880f861d15a1b97';

  Future<List<Map<String, dynamic>>> get5DayForecast({
    required double lat,
    required double lon,
  }) async {
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&lang=pt&appid=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar previsão do tempo');
    }

    final data = jsonDecode(response.body);
    final List list = data['list'];

    final Map<String, List<dynamic>> dailyGroups = {};

    for (var item in list) {
      final dateTime = DateTime.parse(item['dt_txt']);
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
        final tempMin = item['main']['temp_min'];
        final tempMax = item['main']['temp_max'];

        if (tempMin < minTemp) minTemp = tempMin;
        if (tempMax > maxTemp) maxTemp = tempMax;

        if (icon.isEmpty) {
          var rawIcon = item['weather'][0]['icon'] as String;
          icon = rawIcon.substring(0, rawIcon.length - 1) + 'd';
          description = item['weather'][0]['description'];
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
  }
}
