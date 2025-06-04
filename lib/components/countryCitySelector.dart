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
  List<String> _cities = [];
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
      final countryJson = await rootBundle.loadString('assets/data/country.json');

      final List<dynamic> countries = jsonDecode(countryJson);

      String? selectedCountryName;

      if (widget.overrideCountryName != null) {
        selectedCountryName = widget.overrideCountryName!;
      } else {
        final userPhone = AuthService().currentUser?.phone;
        if (userPhone == null) return;

        final phoneInfo = await PhoneNumber.getRegionInfoFromPhoneNumber(
          userPhone,
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
      final Set<String> cities = {};

      for (final state in states) {
        final stateName = state['name'];
        if (stateName != null) {
          cities.add(stateName);
        }
      }

      setState(() {
        _cities = cities.toList()..sort();
        _loading = false;
      });
    } catch (e) {
      print('Erro ao carregar cidades: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cities.isEmpty) {
      return const Text("Nenhuma cidade encontrada.");
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Escolher cidade',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _cities.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final city = _cities[index];
              return ListTile(
                title: Text(city),
                onTap: () => widget.onCitySelected(city),
              );
            },
          ),
        ),
      ],
    );
  }
}
