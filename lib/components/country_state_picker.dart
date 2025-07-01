library country_state_city_picker_nona;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:harvestly/core/services/auth/auth_notifier.dart';
import 'package:provider/provider.dart';

import '../core/services/auth/auth_service.dart';
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

  const SelectState({
    Key? key,
    required this.onCountryChanged,
    required this.onStateChanged,
    required this.onCityChanged,
    this.style,
    this.inStyle,
    this.dropdownColor,
    this.iconColor,
  }) : super(key: key);

  @override
  _SelectStateState createState() => _SelectStateState();
}

class _SelectStateState extends State<SelectState> {
  late List<String> _cities;
  late List<String> _country;
  late String _selectedCity;
  late String _selectedCountry;
  late String _selectedState;
  late List<String> _states;
  var responses;

  @override
  void initState() {
    getCounty();
    super.initState();
    final currentUser =
        Provider.of<AuthNotifier>(context, listen: false).currentUser;
    if (currentUser != null) getCountryFromPhone(currentUser.phone);
    setState(() {
      _cities = [currentUser!.city!];
      _country = [currentUser.country!];
      _selectedCity = currentUser.city!;
      _selectedCountry = currentUser.country!;
      _selectedState = currentUser.municipality!;
      _states = [currentUser.municipality!];
    });
  }

  Future<void> getCountryFromPhone(String phone) async {

    final userPhone = AuthService().currentUser!.phone;
    PhoneNumber info = await PhoneNumber.getRegionInfoFromPhoneNumber(
      userPhone,
    );
    final isoCode = info.isoCode;

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
    var res = await rootBundle.loadString('assets/data/country.json');
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
      _selectedState = "Escolha um Munícipio";
      _states = ["Escolha um Munícipio"];
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
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          DropdownButton<String>(
            iconEnabledColor: widget.iconColor,
            style: widget.style,
            dropdownColor: widget.dropdownColor,
            isExpanded: true,
            items:
                _country.map((String dropDownStringItem) {
                  return DropdownMenuItem<String>(
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
                  );
                }).toList(),
            onChanged: (value) => _onSelectedCountry(value!),
            value: _selectedCountry,
          ),
          DropdownButton<String>(
            iconEnabledColor: widget.iconColor,
            style: widget.style,
            dropdownColor: widget.dropdownColor,
            isExpanded: true,
            items:
                _states.map((String dropDownStringItem) {
                  return DropdownMenuItem<String>(
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
                  );
                }).toList(),
            onChanged: (value) => _onSelectedState(value!),
            value: _selectedState,
          ),
          DropdownButton<String>(
            iconEnabledColor: widget.iconColor,
            style: widget.style,
            dropdownColor: widget.dropdownColor,
            isExpanded: true,
            items:
                _cities.map((String dropDownStringItem) {
                  return DropdownMenuItem<String>(
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
                  );
                }).toList(),
            onChanged: (value) => _onSelectedCity(value!),
            value: _selectedCity,
          ),
          SizedBox(height: 10.0),
        ],
      ),
    );
  }
}
