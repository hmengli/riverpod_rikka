// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router_provider.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [$loginRoute, $detailsRoute, $mainShellRoute];

RouteBase get $loginRoute =>
    GoRouteData.$route(path: '/login', factory: $LoginRoute._fromState);

mixin $LoginRoute on GoRouteData {
  static LoginRoute _fromState(GoRouterState state) => const LoginRoute();

  @override
  String get location => GoRouteData.$location('/login');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $detailsRoute =>
    GoRouteData.$route(path: '/details', factory: $DetailsRoute._fromState);

mixin $DetailsRoute on GoRouteData {
  static DetailsRoute _fromState(GoRouterState state) =>
      DetailsRoute($extra: state.extra as ComicsEntity?);

  DetailsRoute get _self => this as DetailsRoute;

  @override
  String get location => GoRouteData.$location('/details');

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

RouteBase get $mainShellRoute => StatefulShellRouteData.$route(
  factory: $MainShellRouteExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      navigatorKey: HomeBranch.$navigatorKey,
      routes: [
        GoRouteData.$route(path: '/home', factory: $HomeRoute._fromState),
      ],
    ),
    StatefulShellBranchData.$branch(
      navigatorKey: ScheduleBranch.$navigatorKey,
      routes: [
        GoRouteData.$route(
          path: '/schedule',
          factory: $ScheduleRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      navigatorKey: SettingsBranch.$navigatorKey,
      routes: [
        GoRouteData.$route(
          path: '/settings',
          factory: $SettingsRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: '/parser',
              factory: $ParserRoute._fromState,
            ),
          ],
        ),
      ],
    ),
  ],
);

extension $MainShellRouteExtension on MainShellRoute {
  static MainShellRoute _fromState(GoRouterState state) =>
      const MainShellRoute();
}

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location('/home');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ScheduleRoute on GoRouteData {
  static ScheduleRoute _fromState(GoRouterState state) => const ScheduleRoute();

  @override
  String get location => GoRouteData.$location('/schedule');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SettingsRoute on GoRouteData {
  static SettingsRoute _fromState(GoRouterState state) => const SettingsRoute();

  @override
  String get location => GoRouteData.$location('/settings');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ParserRoute on GoRouteData {
  static ParserRoute _fromState(GoRouterState state) => const ParserRoute();

  @override
  String get location => GoRouteData.$location('/parser');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authStateListenable)
final authStateListenableProvider = AuthStateListenableProvider._();

final class AuthStateListenableProvider
    extends
        $FunctionalProvider<
          AuthStateListenable,
          AuthStateListenable,
          AuthStateListenable
        >
    with $Provider<AuthStateListenable> {
  AuthStateListenableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateListenableProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateListenableHash();

  @$internal
  @override
  $ProviderElement<AuthStateListenable> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AuthStateListenable create(Ref ref) {
    return authStateListenable(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthStateListenable value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthStateListenable>(value),
    );
  }
}

String _$authStateListenableHash() =>
    r'111db304b709af4ba70a1f0cf70dbc019ec051ae';

@ProviderFor(goRouter)
final goRouterProvider = GoRouterProvider._();

final class GoRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  GoRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goRouterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return goRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$goRouterHash() => r'b9b79d103fed8217bef65c9f8fe968dad3f12278';
