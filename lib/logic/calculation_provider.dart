import 'package:emi_manager/logic/rounding_provider.dart';
import 'package:emi_manager/utils/number_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

/// A provider that calculates and rounds EMI values
final emiCalculationProvider =
    Provider.family<double, EmiParams>((ref, params) {
  final monthlyRate = params.annualInterestRate / (12 * 100);
  final totalMonths = params.tenureInYears * 12;

  double emi;
  if (params.principalAmount <= 0 || totalMonths <= 0) {
    emi = 0;
  } else if (monthlyRate == 0) {
    // 0% interest: simple division
    emi = params.principalAmount / totalMonths;
  } else {
    emi = params.principalAmount *
        monthlyRate *
        pow(1 + monthlyRate, totalMonths) /
        (pow(1 + monthlyRate, totalMonths) - 1);
  }

  // Round the EMI according to settings
  final settings = ref.watch(roundingProvider);
  return NumberFormatter.formatNumber(emi, settings);
});

/// A provider that performs general calculations with rounding
final calculationProvider =
    Provider.family<double, CalculationParams>((ref, params) {
  // Perform the calculation
  final result = params.calculationFn();

  // Round the result
  final settings = ref.watch(roundingProvider);
  return NumberFormatter.formatNumber(result, settings);
});

/// Parameters for EMI calculation
class EmiParams {
  final double principalAmount;
  final double annualInterestRate;
  final int tenureInYears;

  const EmiParams({
    required this.principalAmount,
    required this.annualInterestRate,
    required this.tenureInYears,
  });
}

/// Parameters for general calculations
class CalculationParams {
  final double Function() calculationFn;

  const CalculationParams({
    required this.calculationFn,
  });
}
