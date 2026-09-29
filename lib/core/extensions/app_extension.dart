import 'package:flutter/material.dart';
import 'package:masic_generation/core/enums/loading_state.dart';
import 'package:masic_generation/core/exceptions/app_exceptions.dart';

extension LoadingStateX on LoadingState {
  bool get isLoading => this == LoadingState.loading;

  bool get isError => this == LoadingState.error;

  bool get isLoaded => this == LoadingState.loaded;

  bool get isInitial => this == LoadingState.initial;
}




extension AppExceptionX on Object {
  String get errorMessage {
    if (this is AppException) {
      final e = this as AppException;
      debugPrint('====================================>> Errored: ${e.toString()}');
      return e.message;
    }
    return toString();
  }
}

extension StringDisplayX on String {
  /// Capitalizes the first letter of each word: "female" → "Female".
  String get toTitleCase {
    final trimmed = trim();
    if (trimmed.isEmpty) return this;
    if (trimmed.toUpperCase() == 'N/A') return trimmed;

    return trimmed.split(RegExp(r'(\s+)')).map((part) {
      if (part.trim().isEmpty) return part;
      return part.split('-').map((word) {
        if (word.isEmpty) return word;
        return '${word[0].toUpperCase()}${word.substring(1)}';
      }).join('-');
    }).join();
  }
}

extension NullableStringDisplayX on String? {
  String? get toTitleCaseOrNull {
    final value = this;
    if (value == null || value.trim().isEmpty) return value;
    return value.toTitleCase;
  }
}


