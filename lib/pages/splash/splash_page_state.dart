class SplashPageState {
  final bool loading;
  final String? error;

  SplashPageState({
    this.loading = false,
    this.error,
  });

  factory SplashPageState.initial() => SplashPageState();

  SplashPageState copyWith({
    bool? loading,
    String? error,
  }) {
    return SplashPageState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}
