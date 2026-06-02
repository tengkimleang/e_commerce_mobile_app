import 'package:e_commerce_mobile_app/core/theme/remote_theme_config.dart';
import 'package:e_commerce_mobile_app/core/theme/theme_cache.dart';
import 'package:e_commerce_mobile_app/core/theme/theme_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeState {
  const ThemeState({
    required this.config,
    this.etag,
    this.fetchedAtUtc,
    this.isRefreshing = false,
  });

  factory ThemeState.initial(CachedAppTheme? cachedTheme) => ThemeState(
    config: cachedTheme?.config ?? RemoteThemeConfig.fallback,
    etag: cachedTheme?.etag,
    fetchedAtUtc: cachedTheme?.fetchedAtUtc,
  );

  final RemoteThemeConfig config;
  final String? etag;
  final DateTime? fetchedAtUtc;
  final bool isRefreshing;

  ThemeState copyWith({
    RemoteThemeConfig? config,
    String? etag,
    DateTime? fetchedAtUtc,
    bool? isRefreshing,
  }) => ThemeState(
    config: config ?? this.config,
    etag: etag ?? this.etag,
    fetchedAtUtc: fetchedAtUtc ?? this.fetchedAtUtc,
    isRefreshing: isRefreshing ?? this.isRefreshing,
  );
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({
    required ThemeRepository repository,
    required ThemeCache cache,
    CachedAppTheme? initialTheme,
    DateTime Function()? now,
  }) : _repository = repository,
       _cache = cache,
       _now = now ?? DateTime.now,
       super(ThemeState.initial(initialTheme));

  static const refreshInterval = Duration(minutes: 5);

  final ThemeRepository _repository;
  final ThemeCache _cache;
  final DateTime Function() _now;

  Future<void> refreshIfStale({bool force = false}) async {
    if (state.isRefreshing || (!force && !_isStale)) return;

    emit(state.copyWith(isRefreshing: true));
    try {
      final result = await _repository.fetchCurrentTheme(etag: state.etag);
      final fetchedAt = _now().toUtc();
      if (result.isNotModified) {
        await _cache.touch(fetchedAt);
        debugPrint(
          '[ThemeCubit] Theme is unchanged (${state.config.revision})',
        );
        emit(state.copyWith(fetchedAtUtc: fetchedAt, isRefreshing: false));
        return;
      }

      final config = result.config!;
      await _cache.write(
        config: config,
        fetchedAtUtc: fetchedAt,
        etag: result.etag,
      );
      debugPrint('[ThemeCubit] Applied remote theme ${config.revision}');
      emit(
        state.copyWith(
          config: config,
          etag: result.etag,
          fetchedAtUtc: fetchedAt,
          isRefreshing: false,
        ),
      );
    } catch (error) {
      debugPrint(
        '[ThemeCubit] Keeping cached theme after refresh failure: $error',
      );
      emit(state.copyWith(isRefreshing: false));
    }
  }

  bool get _isStale {
    final fetchedAt = state.fetchedAtUtc;
    return fetchedAt == null ||
        _now().toUtc().difference(fetchedAt) >= refreshInterval;
  }
}
