library country_state_city_picker_nona;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/services/auth/auth_service.dart';
import 'select_status_model.dart' as StatusModel;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class SelectState extends StatefulWidget {
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onStateChanged;
  final ValueChanged<String> onCityChanged;
  final TextStyle? style;
  final Color? dropdownColor;

  const SelectState({
    Key? key,
    required this.onCountryChanged,
    required this.onStateChanged,
    required this.onCityChanged,
    this.style,
    this.dropdownColor,
  }) : super(key: key);

  @override
  _SelectStateState createState() => _SelectStateState();
}

class _SelectStateState extends State<SelectState> {
  List<String> _cities = ["Escolha uma Cidade"];
  List<String> _country = ["Escolha um País"];
  String _selectedCity = "Escolha uma Cidade";
  String _selectedCountry = "Escolha um País";
  String _selectedState = "Escolha uma Região";
  List<String> _states = ["Escolha uma Região"];
  var responses;

  @override
  void initState() {
    getCounty();
    super.initState();
    getCountryFromPhone(AuthService().currentUser!.phone);
  }

  Future<void> getCountryFromPhone(String phone) async {
    // PhoneNumber number = await PhoneNumber.getRegionInfoFromPhoneNumber(phone);

    final userPhone = AuthService().currentUser!.phone;
    PhoneNumber info = await PhoneNumber.getRegionInfoFromPhoneNumber(
      userPhone,
    );
    final isoCode = info.isoCode; // por exemplo: PT

    var countryList = await getResponse() as List;

    for (var data in countryList) {
      if (data['code'] == isoCode) {
        String formattedCountry = "${data['emoji']}    ${data['name']}";
        setState(() {
          _selectedCountry = formattedCountry;
          if (!_country.contains(formattedCountry)) {
            _country.add(formattedCountry);
          }
        });
        widget.onCountryChanged(formattedCountry);
        await getState();
        break;
      }
    }
  }

  Future getResponse() async {
    var res = await rootBundle.loadString(
      'packages/country_state_city_picker/lib/assets/country.json',
    );
    return jsonDecode(res);
  }

  Future getCounty() async {
    var countryres = await getResponse() as List;
    countryres.forEach((data) {
      var model = StatusModel.StatusModel();
      model.name = data['name'];
      model.emoji = data['emoji'];
      if (!mounted) return;
      setState(() {
        _country.add(model.emoji! + "    " + model.name!);
      });
    });

    return _country;
  }

  Future getState() async {
    var response = await getResponse();
    var takestate =
        response
            .map((map) => StatusModel.StatusModel.fromJson(map))
            .where(
              (item) => item.emoji + "    " + item.name == _selectedCountry,
            )
            .map((item) => item.state)
            .toList();
    var states = takestate as List;
    states.forEach((f) {
      if (!mounted) return;
      setState(() {
        var name = f.map((item) => item.name).toList();
        for (var statename in name) {
          _states.add(statename.toString());
        }
      });
    });

    return _states;
  }

  Future getCity() async {
    var response = await getResponse();
    var takestate =
        response
            .map((map) => StatusModel.StatusModel.fromJson(map))
            .where(
              (item) => item.emoji + "    " + item.name == _selectedCountry,
            )
            .map((item) => item.state)
            .toList();
    var states = takestate as List;
    states.forEach((f) {
      var name = f.where((item) => item.name == _selectedState);
      var cityname = name.map((item) => item.city).toList();
      cityname.forEach((ci) {
        if (!mounted) return;
        setState(() {
          var citiesname = ci.map((item) => item.name).toList();
          for (var citynames in citiesname) {
            _cities.add(citynames.toString());
          }
        });
      });
    });
    return _cities;
  }

  void _onSelectedCountry(String value) {
    if (!mounted) return;
    setState(() {
      _selectedState = "Escolha uma Região";
      _states = ["Escolha uma Região"];
      _selectedCountry = value;
      widget.onCountryChanged(value);
      getState();
    });
  }

  void _onSelectedState(String value) {
    if (!mounted) return;
    setState(() {
      _selectedCity = "Escolha uma Cidade";
      _cities = ["Escolha uma Cidade"];
      _selectedState = value;
      widget.onStateChanged(value);
      getCity();
    });
  }

  void _onSelectedCity(String value) {
    if (!mounted) return;
    setState(() {
      _selectedCity = value;
      widget.onCityChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        DropdownButton<String>(
          dropdownColor: widget.dropdownColor,
          isExpanded: true,
          items:
              _country.map((String dropDownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropDownStringItem,
                  child: Row(
                    children: [Text(dropDownStringItem, style: widget.style)],
                  ),
                );
              }).toList(),
          onChanged: (value) => _onSelectedCountry(value!),
          value: _selectedCountry,
        ),
        DropdownButton<String>(
          dropdownColor: widget.dropdownColor,
          isExpanded: true,
          items:
              _states.map((String dropDownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropDownStringItem,
                  child: Text(dropDownStringItem, style: widget.style),
                );
              }).toList(),
          onChanged: (value) => _onSelectedState(value!),
          value: _selectedState,
        ),
        DropdownButton<String>(
          dropdownColor: widget.dropdownColor,
          isExpanded: true,
          items:
              _cities.map((String dropDownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropDownStringItem,
                  child: Text(dropDownStringItem, style: widget.style),
                );
              }).toList(),
          onChanged: (value) => _onSelectedCity(value!),
          value: _selectedCity,
        ),
        SizedBox(height: 10.0),
      ],
    );
  }
}
