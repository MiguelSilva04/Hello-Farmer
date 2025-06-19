import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../core/services/auth/auth_service.dart';

class CountryCitySelector extends StatefulWidget {
  final Function(String city) onCitySelected;
  final String? overrideCountryName;

  const CountryCitySelector({
    Key? key,
    required this.onCitySelected,
    this.overrideCountryName,
  }) : super(key: key);

  @override
  State<CountryCitySelector> createState() => _CountryCitySelectorState();
}

class _CountryCitySelectorState extends State<CountryCitySelector> {
  Map<String, List<String>> _stateCitiesMap = {};
  bool _loading = true;

  final isoToCountryName = {
    'PT': 'Portugal',
    'ES': 'Spain',
    'FR': 'France',
    'IT': 'Italy',
    'BR': 'Brazil',
    'US': 'United States',
  };

  @override
  void initState() {
    super.initState();
    loadCities();
  }

  Future<void> loadCities() async {
    try {
      final countryJson = await rootBundle.loadString(
        'assets/data/country.json',
      );

      final List<dynamic> countries = jsonDecode(countryJson);

      String? selectedCountryName;

      if (widget.overrideCountryName != null) {
        selectedCountryName = widget.overrideCountryName!;
      } else {
        final userPhone = AuthService().currentUser?.phone;
        if (userPhone == null) return;

        final defaultIsoCode = 'PT';

        final phoneInfo = await PhoneNumber.getRegionInfoFromPhoneNumber(
          userPhone,
          defaultIsoCode,
        );
        final isoCode = phoneInfo.isoCode;

        final countryName = isoToCountryName[isoCode?.toUpperCase() ?? ''];
        if (countryName == null) {
          print("Nome de país não encontrado para código: $isoCode");
          return;
        }

        final country = countries.firstWhere(
          (c) =>
              c['name'].toString().toLowerCase() == countryName.toLowerCase(),
          orElse: () {
            print("País '${countryName}' não encontrado no JSON.");
            return null;
          },
        );

        if (country == null) {
          print('País não encontrado com código: $isoCode');
          return;
        }

        selectedCountryName = country['name'];
      }


      final countryData = countries.firstWhere(
        (c) => c['name'] == selectedCountryName,
        orElse: () => null,
      );

      if (countryData == null) {
        print('Dados do país não encontrados para: $selectedCountryName');
        return;
      }

      final List<dynamic> states = countryData['state'];
      final Map<String, List<String>> map = {};


      for (final state in states) {
        final String? stateName = state['name'];
        if (stateName == null) continue;

        final List<dynamic>? citiesDynamic = state['city'];
        if (citiesDynamic == null || citiesDynamic.isEmpty) continue;

        final List<String> cities =
            citiesDynamic
                .map((cityObj) => cityObj['name']?.toString() ?? '')
                .where((cityName) => cityName.isNotEmpty)
                .toList();


        map[stateName] = cities;
      }

      setState(() {
        _stateCitiesMap = map;
        _loading = false;
      });
    } catch (e) {
      print('Erro ao carregar cidades por estado: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stateCitiesMap.isEmpty) {
      return const Center(child: Text('Nenhuma cidade encontrada.'));
    }

    final items = <String>[];
    _stateCitiesMap.forEach((state, cities) {
      for (var city in cities) {
        items.add('$state - $city');
      }
    });

    items.sort();

    return ListView(
      shrinkWrap: true,
      children:
          _stateCitiesMap.entries.map((entry) {
            final state = entry.key;
            final cities = entry.value;

            return ExpansionTile(
              title: Text(state),
              children:
                  cities
                      .map(
                        (city) => ListTile(
                          title: Text(city),
                          onTap: () {
                            widget.onCitySelected(city);
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
            );
          }).toList(),
    );
  }
}
