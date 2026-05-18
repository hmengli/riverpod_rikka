// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parser_provide.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(parserList)
final parserListProvider = ParserListProvider._();

final class ParserListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ParserEntity>>,
          List<ParserEntity>,
          FutureOr<List<ParserEntity>>
        >
    with
        $FutureModifier<List<ParserEntity>>,
        $FutureProvider<List<ParserEntity>> {
  ParserListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parserListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parserListHash();

  @$internal
  @override
  $FutureProviderElement<List<ParserEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ParserEntity>> create(Ref ref) {
    return parserList(ref);
  }
}

String _$parserListHash() => r'd806f7c0cd38d577d37e295f6e0f12da9ad457e9';

@ProviderFor(ParserNotifier)
final parserProvider = ParserNotifierProvider._();

final class ParserNotifierProvider
    extends $AsyncNotifierProvider<ParserNotifier, void> {
  ParserNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'parserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$parserNotifierHash();

  @$internal
  @override
  ParserNotifier create() => ParserNotifier();
}

String _$parserNotifierHash() => r'3dad403974bf575ddf6cbab5150ab1d22a65166f';

abstract class _$ParserNotifier extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
