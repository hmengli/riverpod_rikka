// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fetchData)
final fetchDataProvider = FetchDataFamily._();

final class FetchDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ComicsEntity>>,
          List<ComicsEntity>,
          FutureOr<List<ComicsEntity>>
        >
    with
        $FutureModifier<List<ComicsEntity>>,
        $FutureProvider<List<ComicsEntity>> {
  FetchDataProvider._({
    required FetchDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'fetchDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fetchDataHash();

  @override
  String toString() {
    return r'fetchDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ComicsEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ComicsEntity>> create(Ref ref) {
    final argument = this.argument as String;
    return fetchData(ref, weekday: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fetchDataHash() => r'962596a43bd9a8d240e8a7cd2bcfc4bb6f7f1901';

final class FetchDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ComicsEntity>>, String> {
  FetchDataFamily._()
    : super(
        retry: null,
        name: r'fetchDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FetchDataProvider call({required String weekday}) =>
      FetchDataProvider._(argument: weekday, from: this);

  @override
  String toString() => r'fetchDataProvider';
}
