import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/university.dart';
import '../services/university_service.dart';

class UniversityState {
  final bool isLoading;
  final List<University> universities;
  final String? error;

  UniversityState({
    this.isLoading = false,
    this.universities = const [],
    this.error,
  });

  UniversityState copyWith({
    bool? isLoading,
    List<University>? universities,
    String? error,
  }) {
    return UniversityState(
      isLoading: isLoading ?? this.isLoading,
      universities: universities ?? this.universities,
      error: error,
    );
  }
}

class UniversityViewModel extends StateNotifier<UniversityState> {
  final UniversityService _service;

  UniversityViewModel(this._service) : super(UniversityState());

  Future<void> searchUniversity(String country) async {
    // Empty country check
    if (country.isEmpty) {
      state = state.copyWith(
          error: "Invalid country: Please enter a country name.");
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await _service.fetchUniversities(country);

      if (results.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: "No results found for \"$country\".",
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        universities: results,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: "Network error: Unable to fetch data. Check your connection.",
      );
    }
  }
}

final universityViewModelProvider =
    StateNotifierProvider<UniversityViewModel, UniversityState>((ref) {
  return UniversityViewModel(UniversityService());
});
