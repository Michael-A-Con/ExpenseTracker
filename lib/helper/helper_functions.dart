import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//convert string to double

double ConvertStringToDouble(String string) {
  double? amount = double.tryParse(string);
  return amount ?? 0;

}

//convert double a colones
String formatDouble(double amount) {
  final format = NumberFormat.currency(locale: 'es_CR', symbol: '₡', decimalDigits: 2);
  return format.format(amount);
}


//calculate number of months since first month

int calculateMonthCount(int startYear, startMonth, currentYear, currentMonth) {
  int monthCount = (currentYear - startYear) * 12 + currentMonth - startMonth + 1;
  return monthCount;
}