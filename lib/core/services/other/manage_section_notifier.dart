import 'package:flutter/material.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';

class ManageSectionNotifier extends ChangeNotifier {
  int _currentIndex = 0;
  DateTime _billingFromDate = (AuthService().currentUser! as ProducerUser).store.createdAt;

  DateTime get billingFromDate => _billingFromDate;

  int get currentIndex => _currentIndex;

  void setBillingFromDate(DateTime dateTime) {
    _billingFromDate = dateTime;
  }

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
}
