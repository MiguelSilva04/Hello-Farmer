// ignore_for_file: use_build_context_synchronously

library country_state_city_picker_nona;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:provider/provider.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';
import 'select_status_model.dart' as StatusModel;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class SelectState extends StatefulWidget {
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onStateChanged;
  final ValueChanged<String> onCityChanged;
  final TextStyle? style;
  final TextStyle? inStyle;
  final Color? iconColor;
  final Color? dropdownColor;
  final bool isSignup;

  const SelectState({
    Key? key,
    required this.onCountryChanged,
    required this.onStateChanged,
    required this.onCityChanged,
    required this.isSignup,
    this.style,
    this.inStyle,
    this.dropdownColor,
    this.iconColor,
  }) : super(key: key);

  @override
  _SelectStateState createState() => _SelectStateState();
}

class _SelectStateState extends State<SelectState> {
  List<String> _countries = ["Escolha um País"];
  List<String> _states = ["Escolha um Município"];
  List<String> _cities = ["Escolha uma Cidade"];

  String _selectedCountry = "Escolha um País";
  String _selectedState = "Escolha um Município";
  String _selectedCity = "Escolha uma Cidade";

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await getCountries();

    final currentUser =
        Provider.of<AuthNotifier>(context, listen: false).currentUser;

    if (currentUser != null && !widget.isSignup) {
      // Detetar país a partir do telefone
      await getCountryFromPhone(currentUser.phone);

      setState(() {
        if (currentUser.country != null &&
            !_countries.contains(currentUser.country!)) {
          _countries.add(currentUser.country!);
          _selectedCountry = currentUser.country!;
        }

        if (currentUser.municipality != null &&
            !_states.contains(currentUser.municipality!)) {
          _states.add(currentUser.municipality!);
          _selectedState = currentUser.municipality!;
        }

        if (currentUser.city != null && !_cities.contains(currentUser.city!)) {
          _cities.add(currentUser.city!);
          _selectedCity = currentUser.city!;
        }
      });
    }
  }

  Future<List<dynamic>> getResponse() async {
    final res = await rootBundle.loadString('assets/data/country.json');
    return jsonDecode(res);
  }

  Future<void> getCountries() async {
    final countryRes = await getResponse();
    for (var data in countryRes) {
      final model = StatusModel.StatusModel();
      model.name = data['name'];
      model.emoji = data['emoji'];
      if (!mounted) return;
      setState(() {
        final formatted = "${model.emoji!}    ${model.name!}";
        if (!_countries.contains(formatted)) {
          _countries.add(formatted);
        }
      });
    }
  }

  Future<void> getCountryFromPhone(String phone) async {
    try {
      final userPhone = AuthService().currentUser?.phone;
      if (userPhone == null) return;

      final info = await PhoneNumber.getRegionInfoFromPhoneNumber(userPhone);
      final isoCode = info.isoCode;

      final countryList = await getResponse();

      for (var data in countryList) {
        if (data['code'] == isoCode) {
          final formattedCountry = "${data['emoji']}    ${data['name']}";
          if (!mounted) return;
          setState(() {
            _selectedCountry = formattedCountry;
            if (!_countries.contains(formattedCountry)) {
              _countries.add(formattedCountry);
            }
          });
          widget.onCountryChanged(formattedCountry);
          await getStates();
          break;
        }
      }
    } catch (_) {}
  }

  Future<void> getStates() async {
    final response = await getResponse();
    final takestate =
        response
            .map((map) => StatusModel.StatusModel.fromJson(map))
            .where(
              (item) => "${item.emoji}    ${item.name}" == _selectedCountry,
            )
            .map((item) => item.state)
            .toList();

    if (!mounted) return;
    setState(() {
      _states = ["Escolha um Município"];
      for (var s in takestate) {
        final names = s!.map((e) => e.name).toList();
        for (var name in names) {
          if (!_states.contains(name)) _states.add(name!);
        }
      }
    });
  }

  Future<void> getCities() async {
    final response = await getResponse();
    final takestate =
        response
            .map((map) => StatusModel.StatusModel.fromJson(map))
            .where(
              (item) => "${item.emoji}    ${item.name}" == _selectedCountry,
            )
            .map((item) => item.state)
            .toList();

    if (!mounted) return;
    setState(() {
      _cities = ["Escolha uma Cidade"];
      for (var state in takestate) {
        final selected = state!.where((e) => e.name == _selectedState);
        for (var s in selected) {
          for (var city in s.city!) {
            if (!_cities.contains(city.name)) _cities.add(city.name!);
          }
        }
      }
    });
  }

  void _onSelectedCountry(String value) {
    if (!mounted) return;
    setState(() {
      _selectedCountry = value;
      _selectedState = "Escolha um Município";
      _selectedCity = "Escolha uma Cidade";
      _states = ["Escolha um Município"];
      _cities = ["Escolha uma Cidade"];
    });
    widget.onCountryChanged(value);
    getStates();
  }

  void _onSelectedState(String value) {
    if (!mounted) return;
    setState(() {
      _selectedState = value;
      _selectedCity = "Escolha uma Cidade";
      _cities = ["Escolha uma Cidade"];
    });
    widget.onStateChanged(value);
    getCities();
  }

  void _onSelectedCity(String value) {
    if (!mounted) return;
    setState(() => _selectedCity = value);
    widget.onCityChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
      child: Column(
        children: [
          _buildDropdown(
            items: _countries,
            value: _selectedCountry,
            onChanged: _onSelectedCountry,
          ),
          _buildDropdown(
            items: _states,
            value: _selectedState,
            onChanged: _onSelectedState,
          ),
          _buildDropdown(
            items: _cities,
            value: _selectedCity,
            onChanged: _onSelectedCity,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required List<String> items,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButton<String>(
      iconEnabledColor: widget.iconColor,
      style: widget.style,
      dropdownColor: widget.dropdownColor,
      isExpanded: true,
      value: items.contains(value) ? value : items.first,
      items:
          items
              .map(
                (String dropDownStringItem) => DropdownMenuItem<String>(
                  value: dropDownStringItem,
                  child: Row(
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            dropDownStringItem,
                            style: widget.inStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
      onChanged: (val) => onChanged(val!),
    );
  }
}
