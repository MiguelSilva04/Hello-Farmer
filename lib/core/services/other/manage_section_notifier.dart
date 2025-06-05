import 'package:flutter/material.dart';
import 'package:harvestly/core/models/producer_user.dart';
import 'package:harvestly/core/services/auth/auth_service.dart';

class ManageSectionNotifier extends ChangeNotifier {
  int _currentIndex = 0;
  int _storeIndex = 0;
  DateTime? _billingFromDate =
      AuthService().currentUser!.runtimeType == ProducerUser
          ? (AuthService().currentUser! as ProducerUser).stores.first.createdAt
          : null;

  DateTime get billingFromDate => _billingFromDate!;

  int get currentIndex => _currentIndex;

  int get storeIndex => _storeIndex;

  void setBillingFromDate(DateTime dateTime) {
    _billingFromDate = dateTime;
  }

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void setStoreIndex(int index) {
    if (_storeIndex != index) {
      _storeIndex = index;
      notifyListeners();
    }
  }
}
