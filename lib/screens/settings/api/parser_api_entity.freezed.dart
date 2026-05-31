// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'parser_api_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ParserApiEntity {

 String? get basisUrl; String? get method; String? get dataRootPath; List<HeadersEntity> get headers; List<FieldMapping> get fieldMappings;
/// Create a copy of ParserApiEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ParserApiEntityCopyWith<ParserApiEntity> get copyWith => _$ParserApiEntityCopyWithImpl<ParserApiEntity>(this as ParserApiEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParserApiEntity&&(identical(other.basisUrl, basisUrl) || other.basisUrl == basisUrl)&&(identical(other.method, method) || other.method == method)&&(identical(other.dataRootPath, dataRootPath) || other.dataRootPath == dataRootPath)&&const DeepCollectionEquality().equals(other.headers, headers)&&const DeepCollectionEquality().equals(other.fieldMappings, fieldMappings));
}


@override
int get hashCode => Object.hash(runtimeType,basisUrl,method,dataRootPath,const DeepCollectionEquality().hash(headers),const DeepCollectionEquality().hash(fieldMappings));

@override
String toString() {
  return 'ParserApiEntity(basisUrl: $basisUrl, method: $method, dataRootPath: $dataRootPath, headers: $headers, fieldMappings: $fieldMappings)';
}


}

/// @nodoc
abstract mixin class $ParserApiEntityCopyWith<$Res>  {
  factory $ParserApiEntityCopyWith(ParserApiEntity value, $Res Function(ParserApiEntity) _then) = _$ParserApiEntityCopyWithImpl;
@useResult
$Res call({
 String? basisUrl, String? method, String? dataRootPath, List<HeadersEntity> headers, List<FieldMapping> fieldMappings
});




}
/// @nodoc
class _$ParserApiEntityCopyWithImpl<$Res>
    implements $ParserApiEntityCopyWith<$Res> {
  _$ParserApiEntityCopyWithImpl(this._self, this._then);

  final ParserApiEntity _self;
  final $Res Function(ParserApiEntity) _then;

/// Create a copy of ParserApiEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? basisUrl = freezed,Object? method = freezed,Object? dataRootPath = freezed,Object? headers = null,Object? fieldMappings = null,}) {
  return _then(_self.copyWith(
basisUrl: freezed == basisUrl ? _self.basisUrl : basisUrl // ignore: cast_nullable_to_non_nullable
as String?,method: freezed == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String?,dataRootPath: freezed == dataRootPath ? _self.dataRootPath : dataRootPath // ignore: cast_nullable_to_non_nullable
as String?,headers: null == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as List<HeadersEntity>,fieldMappings: null == fieldMappings ? _self.fieldMappings : fieldMappings // ignore: cast_nullable_to_non_nullable
as List<FieldMapping>,
  ));
}

}


/// Adds pattern-matching-related methods to [ParserApiEntity].
extension ParserApiEntityPatterns on ParserApiEntity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ParserApiEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ParserApiEntity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ParserApiEntity value)  $default,){
final _that = this;
switch (_that) {
case _ParserApiEntity():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ParserApiEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ParserApiEntity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? basisUrl,  String? method,  String? dataRootPath,  List<HeadersEntity> headers,  List<FieldMapping> fieldMappings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ParserApiEntity() when $default != null:
return $default(_that.basisUrl,_that.method,_that.dataRootPath,_that.headers,_that.fieldMappings);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? basisUrl,  String? method,  String? dataRootPath,  List<HeadersEntity> headers,  List<FieldMapping> fieldMappings)  $default,) {final _that = this;
switch (_that) {
case _ParserApiEntity():
return $default(_that.basisUrl,_that.method,_that.dataRootPath,_that.headers,_that.fieldMappings);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? basisUrl,  String? method,  String? dataRootPath,  List<HeadersEntity> headers,  List<FieldMapping> fieldMappings)?  $default,) {final _that = this;
switch (_that) {
case _ParserApiEntity() when $default != null:
return $default(_that.basisUrl,_that.method,_that.dataRootPath,_that.headers,_that.fieldMappings);case _:
  return null;

}
}

}

/// @nodoc


class _ParserApiEntity implements ParserApiEntity {
  const _ParserApiEntity({this.basisUrl, this.method, this.dataRootPath, final  List<HeadersEntity> headers = const [], final  List<FieldMapping> fieldMappings = const []}): _headers = headers,_fieldMappings = fieldMappings;
  

@override final  String? basisUrl;
@override final  String? method;
@override final  String? dataRootPath;
 final  List<HeadersEntity> _headers;
@override@JsonKey() List<HeadersEntity> get headers {
  if (_headers is EqualUnmodifiableListView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_headers);
}

 final  List<FieldMapping> _fieldMappings;
@override@JsonKey() List<FieldMapping> get fieldMappings {
  if (_fieldMappings is EqualUnmodifiableListView) return _fieldMappings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fieldMappings);
}


/// Create a copy of ParserApiEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ParserApiEntityCopyWith<_ParserApiEntity> get copyWith => __$ParserApiEntityCopyWithImpl<_ParserApiEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ParserApiEntity&&(identical(other.basisUrl, basisUrl) || other.basisUrl == basisUrl)&&(identical(other.method, method) || other.method == method)&&(identical(other.dataRootPath, dataRootPath) || other.dataRootPath == dataRootPath)&&const DeepCollectionEquality().equals(other._headers, _headers)&&const DeepCollectionEquality().equals(other._fieldMappings, _fieldMappings));
}


@override
int get hashCode => Object.hash(runtimeType,basisUrl,method,dataRootPath,const DeepCollectionEquality().hash(_headers),const DeepCollectionEquality().hash(_fieldMappings));

@override
String toString() {
  return 'ParserApiEntity(basisUrl: $basisUrl, method: $method, dataRootPath: $dataRootPath, headers: $headers, fieldMappings: $fieldMappings)';
}


}

/// @nodoc
abstract mixin class _$ParserApiEntityCopyWith<$Res> implements $ParserApiEntityCopyWith<$Res> {
  factory _$ParserApiEntityCopyWith(_ParserApiEntity value, $Res Function(_ParserApiEntity) _then) = __$ParserApiEntityCopyWithImpl;
@override @useResult
$Res call({
 String? basisUrl, String? method, String? dataRootPath, List<HeadersEntity> headers, List<FieldMapping> fieldMappings
});




}
/// @nodoc
class __$ParserApiEntityCopyWithImpl<$Res>
    implements _$ParserApiEntityCopyWith<$Res> {
  __$ParserApiEntityCopyWithImpl(this._self, this._then);

  final _ParserApiEntity _self;
  final $Res Function(_ParserApiEntity) _then;

/// Create a copy of ParserApiEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? basisUrl = freezed,Object? method = freezed,Object? dataRootPath = freezed,Object? headers = null,Object? fieldMappings = null,}) {
  return _then(_ParserApiEntity(
basisUrl: freezed == basisUrl ? _self.basisUrl : basisUrl // ignore: cast_nullable_to_non_nullable
as String?,method: freezed == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String?,dataRootPath: freezed == dataRootPath ? _self.dataRootPath : dataRootPath // ignore: cast_nullable_to_non_nullable
as String?,headers: null == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as List<HeadersEntity>,fieldMappings: null == fieldMappings ? _self._fieldMappings : fieldMappings // ignore: cast_nullable_to_non_nullable
as List<FieldMapping>,
  ));
}


}

/// @nodoc
mixin _$HeadersEntity {

 String get mKey; dynamic get mValue;
/// Create a copy of HeadersEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HeadersEntityCopyWith<HeadersEntity> get copyWith => _$HeadersEntityCopyWithImpl<HeadersEntity>(this as HeadersEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HeadersEntity&&(identical(other.mKey, mKey) || other.mKey == mKey)&&const DeepCollectionEquality().equals(other.mValue, mValue));
}


@override
int get hashCode => Object.hash(runtimeType,mKey,const DeepCollectionEquality().hash(mValue));

@override
String toString() {
  return 'HeadersEntity(mKey: $mKey, mValue: $mValue)';
}


}

/// @nodoc
abstract mixin class $HeadersEntityCopyWith<$Res>  {
  factory $HeadersEntityCopyWith(HeadersEntity value, $Res Function(HeadersEntity) _then) = _$HeadersEntityCopyWithImpl;
@useResult
$Res call({
 String mKey, dynamic mValue
});




}
/// @nodoc
class _$HeadersEntityCopyWithImpl<$Res>
    implements $HeadersEntityCopyWith<$Res> {
  _$HeadersEntityCopyWithImpl(this._self, this._then);

  final HeadersEntity _self;
  final $Res Function(HeadersEntity) _then;

/// Create a copy of HeadersEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mKey = null,Object? mValue = freezed,}) {
  return _then(_self.copyWith(
mKey: null == mKey ? _self.mKey : mKey // ignore: cast_nullable_to_non_nullable
as String,mValue: freezed == mValue ? _self.mValue : mValue // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [HeadersEntity].
extension HeadersEntityPatterns on HeadersEntity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HeadersEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HeadersEntity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HeadersEntity value)  $default,){
final _that = this;
switch (_that) {
case _HeadersEntity():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HeadersEntity value)?  $default,){
final _that = this;
switch (_that) {
case _HeadersEntity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mKey,  dynamic mValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HeadersEntity() when $default != null:
return $default(_that.mKey,_that.mValue);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mKey,  dynamic mValue)  $default,) {final _that = this;
switch (_that) {
case _HeadersEntity():
return $default(_that.mKey,_that.mValue);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mKey,  dynamic mValue)?  $default,) {final _that = this;
switch (_that) {
case _HeadersEntity() when $default != null:
return $default(_that.mKey,_that.mValue);case _:
  return null;

}
}

}

/// @nodoc


class _HeadersEntity implements HeadersEntity {
  const _HeadersEntity({required this.mKey, this.mValue});
  

@override final  String mKey;
@override final  dynamic mValue;

/// Create a copy of HeadersEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HeadersEntityCopyWith<_HeadersEntity> get copyWith => __$HeadersEntityCopyWithImpl<_HeadersEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HeadersEntity&&(identical(other.mKey, mKey) || other.mKey == mKey)&&const DeepCollectionEquality().equals(other.mValue, mValue));
}


@override
int get hashCode => Object.hash(runtimeType,mKey,const DeepCollectionEquality().hash(mValue));

@override
String toString() {
  return 'HeadersEntity(mKey: $mKey, mValue: $mValue)';
}


}

/// @nodoc
abstract mixin class _$HeadersEntityCopyWith<$Res> implements $HeadersEntityCopyWith<$Res> {
  factory _$HeadersEntityCopyWith(_HeadersEntity value, $Res Function(_HeadersEntity) _then) = __$HeadersEntityCopyWithImpl;
@override @useResult
$Res call({
 String mKey, dynamic mValue
});




}
/// @nodoc
class __$HeadersEntityCopyWithImpl<$Res>
    implements _$HeadersEntityCopyWith<$Res> {
  __$HeadersEntityCopyWithImpl(this._self, this._then);

  final _HeadersEntity _self;
  final $Res Function(_HeadersEntity) _then;

/// Create a copy of HeadersEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mKey = null,Object? mValue = freezed,}) {
  return _then(_HeadersEntity(
mKey: null == mKey ? _self.mKey : mKey // ignore: cast_nullable_to_non_nullable
as String,mValue: freezed == mValue ? _self.mValue : mValue // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

/// @nodoc
mixin _$FieldMapping {

 String? get targetField; String? get sourcePath; ValueSourceType? get type; List<DataTransForm> get transforms;
/// Create a copy of FieldMapping
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FieldMappingCopyWith<FieldMapping> get copyWith => _$FieldMappingCopyWithImpl<FieldMapping>(this as FieldMapping, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldMapping&&(identical(other.targetField, targetField) || other.targetField == targetField)&&(identical(other.sourcePath, sourcePath) || other.sourcePath == sourcePath)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.transforms, transforms));
}


@override
int get hashCode => Object.hash(runtimeType,targetField,sourcePath,type,const DeepCollectionEquality().hash(transforms));

@override
String toString() {
  return 'FieldMapping(targetField: $targetField, sourcePath: $sourcePath, type: $type, transforms: $transforms)';
}


}

/// @nodoc
abstract mixin class $FieldMappingCopyWith<$Res>  {
  factory $FieldMappingCopyWith(FieldMapping value, $Res Function(FieldMapping) _then) = _$FieldMappingCopyWithImpl;
@useResult
$Res call({
 String? targetField, String? sourcePath, ValueSourceType type, List<DataTransForm> transforms
});




}
/// @nodoc
class _$FieldMappingCopyWithImpl<$Res>
    implements $FieldMappingCopyWith<$Res> {
  _$FieldMappingCopyWithImpl(this._self, this._then);

  final FieldMapping _self;
  final $Res Function(FieldMapping) _then;

/// Create a copy of FieldMapping
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targetField = freezed,Object? sourcePath = freezed,Object? type = null,Object? transforms = null,}) {
  return _then(_self.copyWith(
targetField: freezed == targetField ? _self.targetField : targetField // ignore: cast_nullable_to_non_nullable
as String?,sourcePath: freezed == sourcePath ? _self.sourcePath : sourcePath // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type! : type // ignore: cast_nullable_to_non_nullable
as ValueSourceType,transforms: null == transforms ? _self.transforms : transforms // ignore: cast_nullable_to_non_nullable
as List<DataTransForm>,
  ));
}

}


/// Adds pattern-matching-related methods to [FieldMapping].
extension FieldMappingPatterns on FieldMapping {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FieldMapping value)?  $default,{TResult Function( _DirectFieldMapping value)?  direct,TResult Function( _TemplateFieldMapping value)?  template,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FieldMapping() when $default != null:
return $default(_that);case _DirectFieldMapping() when direct != null:
return direct(_that);case _TemplateFieldMapping() when template != null:
return template(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FieldMapping value)  $default,{required TResult Function( _DirectFieldMapping value)  direct,required TResult Function( _TemplateFieldMapping value)  template,}){
final _that = this;
switch (_that) {
case _FieldMapping():
return $default(_that);case _DirectFieldMapping():
return direct(_that);case _TemplateFieldMapping():
return template(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FieldMapping value)?  $default,{TResult? Function( _DirectFieldMapping value)?  direct,TResult? Function( _TemplateFieldMapping value)?  template,}){
final _that = this;
switch (_that) {
case _FieldMapping() when $default != null:
return $default(_that);case _DirectFieldMapping() when direct != null:
return direct(_that);case _TemplateFieldMapping() when template != null:
return template(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? targetField,  String? sourcePath,  ValueSourceType? type,  List<DataTransForm> transforms)?  $default,{TResult Function( String? targetField,  String? sourcePath,  List<DataTransForm> transforms,  ValueSourceType type)?  direct,TResult Function( String? targetField,  String? sourcePath,  List<DataTransForm> transforms,  ValueSourceType type)?  template,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FieldMapping() when $default != null:
return $default(_that.targetField,_that.sourcePath,_that.type,_that.transforms);case _DirectFieldMapping() when direct != null:
return direct(_that.targetField,_that.sourcePath,_that.transforms,_that.type);case _TemplateFieldMapping() when template != null:
return template(_that.targetField,_that.sourcePath,_that.transforms,_that.type);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? targetField,  String? sourcePath,  ValueSourceType? type,  List<DataTransForm> transforms)  $default,{required TResult Function( String? targetField,  String? sourcePath,  List<DataTransForm> transforms,  ValueSourceType type)  direct,required TResult Function( String? targetField,  String? sourcePath,  List<DataTransForm> transforms,  ValueSourceType type)  template,}) {final _that = this;
switch (_that) {
case _FieldMapping():
return $default(_that.targetField,_that.sourcePath,_that.type,_that.transforms);case _DirectFieldMapping():
return direct(_that.targetField,_that.sourcePath,_that.transforms,_that.type);case _TemplateFieldMapping():
return template(_that.targetField,_that.sourcePath,_that.transforms,_that.type);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? targetField,  String? sourcePath,  ValueSourceType? type,  List<DataTransForm> transforms)?  $default,{TResult? Function( String? targetField,  String? sourcePath,  List<DataTransForm> transforms,  ValueSourceType type)?  direct,TResult? Function( String? targetField,  String? sourcePath,  List<DataTransForm> transforms,  ValueSourceType type)?  template,}) {final _that = this;
switch (_that) {
case _FieldMapping() when $default != null:
return $default(_that.targetField,_that.sourcePath,_that.type,_that.transforms);case _DirectFieldMapping() when direct != null:
return direct(_that.targetField,_that.sourcePath,_that.transforms,_that.type);case _TemplateFieldMapping() when template != null:
return template(_that.targetField,_that.sourcePath,_that.transforms,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _FieldMapping implements FieldMapping {
  const _FieldMapping({this.targetField, this.sourcePath, this.type, final  List<DataTransForm> transforms = const []}): _transforms = transforms;
  

@override final  String? targetField;
@override final  String? sourcePath;
@override final  ValueSourceType? type;
 final  List<DataTransForm> _transforms;
@override@JsonKey() List<DataTransForm> get transforms {
  if (_transforms is EqualUnmodifiableListView) return _transforms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transforms);
}


/// Create a copy of FieldMapping
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FieldMappingCopyWith<_FieldMapping> get copyWith => __$FieldMappingCopyWithImpl<_FieldMapping>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FieldMapping&&(identical(other.targetField, targetField) || other.targetField == targetField)&&(identical(other.sourcePath, sourcePath) || other.sourcePath == sourcePath)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._transforms, _transforms));
}


@override
int get hashCode => Object.hash(runtimeType,targetField,sourcePath,type,const DeepCollectionEquality().hash(_transforms));

@override
String toString() {
  return 'FieldMapping(targetField: $targetField, sourcePath: $sourcePath, type: $type, transforms: $transforms)';
}


}

/// @nodoc
abstract mixin class _$FieldMappingCopyWith<$Res> implements $FieldMappingCopyWith<$Res> {
  factory _$FieldMappingCopyWith(_FieldMapping value, $Res Function(_FieldMapping) _then) = __$FieldMappingCopyWithImpl;
@override @useResult
$Res call({
 String? targetField, String? sourcePath, ValueSourceType? type, List<DataTransForm> transforms
});




}
/// @nodoc
class __$FieldMappingCopyWithImpl<$Res>
    implements _$FieldMappingCopyWith<$Res> {
  __$FieldMappingCopyWithImpl(this._self, this._then);

  final _FieldMapping _self;
  final $Res Function(_FieldMapping) _then;

/// Create a copy of FieldMapping
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetField = freezed,Object? sourcePath = freezed,Object? type = freezed,Object? transforms = null,}) {
  return _then(_FieldMapping(
targetField: freezed == targetField ? _self.targetField : targetField // ignore: cast_nullable_to_non_nullable
as String?,sourcePath: freezed == sourcePath ? _self.sourcePath : sourcePath // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ValueSourceType?,transforms: null == transforms ? _self._transforms : transforms // ignore: cast_nullable_to_non_nullable
as List<DataTransForm>,
  ));
}


}

/// @nodoc


class _DirectFieldMapping implements FieldMapping {
  const _DirectFieldMapping({this.targetField, this.sourcePath, final  List<DataTransForm> transforms = const [], this.type = ValueSourceType.direct}): _transforms = transforms;
  

@override final  String? targetField;
@override final  String? sourcePath;
 final  List<DataTransForm> _transforms;
@override@JsonKey() List<DataTransForm> get transforms {
  if (_transforms is EqualUnmodifiableListView) return _transforms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transforms);
}

@override@JsonKey() final  ValueSourceType type;

/// Create a copy of FieldMapping
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DirectFieldMappingCopyWith<_DirectFieldMapping> get copyWith => __$DirectFieldMappingCopyWithImpl<_DirectFieldMapping>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DirectFieldMapping&&(identical(other.targetField, targetField) || other.targetField == targetField)&&(identical(other.sourcePath, sourcePath) || other.sourcePath == sourcePath)&&const DeepCollectionEquality().equals(other._transforms, _transforms)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,targetField,sourcePath,const DeepCollectionEquality().hash(_transforms),type);

@override
String toString() {
  return 'FieldMapping.direct(targetField: $targetField, sourcePath: $sourcePath, transforms: $transforms, type: $type)';
}


}

/// @nodoc
abstract mixin class _$DirectFieldMappingCopyWith<$Res> implements $FieldMappingCopyWith<$Res> {
  factory _$DirectFieldMappingCopyWith(_DirectFieldMapping value, $Res Function(_DirectFieldMapping) _then) = __$DirectFieldMappingCopyWithImpl;
@override @useResult
$Res call({
 String? targetField, String? sourcePath, List<DataTransForm> transforms, ValueSourceType type
});




}
/// @nodoc
class __$DirectFieldMappingCopyWithImpl<$Res>
    implements _$DirectFieldMappingCopyWith<$Res> {
  __$DirectFieldMappingCopyWithImpl(this._self, this._then);

  final _DirectFieldMapping _self;
  final $Res Function(_DirectFieldMapping) _then;

/// Create a copy of FieldMapping
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetField = freezed,Object? sourcePath = freezed,Object? transforms = null,Object? type = null,}) {
  return _then(_DirectFieldMapping(
targetField: freezed == targetField ? _self.targetField : targetField // ignore: cast_nullable_to_non_nullable
as String?,sourcePath: freezed == sourcePath ? _self.sourcePath : sourcePath // ignore: cast_nullable_to_non_nullable
as String?,transforms: null == transforms ? _self._transforms : transforms // ignore: cast_nullable_to_non_nullable
as List<DataTransForm>,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ValueSourceType,
  ));
}


}

/// @nodoc


class _TemplateFieldMapping implements FieldMapping {
  const _TemplateFieldMapping({this.targetField, this.sourcePath, final  List<DataTransForm> transforms = const [], this.type = ValueSourceType.template}): _transforms = transforms;
  

@override final  String? targetField;
@override final  String? sourcePath;
 final  List<DataTransForm> _transforms;
@override@JsonKey() List<DataTransForm> get transforms {
  if (_transforms is EqualUnmodifiableListView) return _transforms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_transforms);
}

@override@JsonKey() final  ValueSourceType type;

/// Create a copy of FieldMapping
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TemplateFieldMappingCopyWith<_TemplateFieldMapping> get copyWith => __$TemplateFieldMappingCopyWithImpl<_TemplateFieldMapping>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TemplateFieldMapping&&(identical(other.targetField, targetField) || other.targetField == targetField)&&(identical(other.sourcePath, sourcePath) || other.sourcePath == sourcePath)&&const DeepCollectionEquality().equals(other._transforms, _transforms)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,targetField,sourcePath,const DeepCollectionEquality().hash(_transforms),type);

@override
String toString() {
  return 'FieldMapping.template(targetField: $targetField, sourcePath: $sourcePath, transforms: $transforms, type: $type)';
}


}

/// @nodoc
abstract mixin class _$TemplateFieldMappingCopyWith<$Res> implements $FieldMappingCopyWith<$Res> {
  factory _$TemplateFieldMappingCopyWith(_TemplateFieldMapping value, $Res Function(_TemplateFieldMapping) _then) = __$TemplateFieldMappingCopyWithImpl;
@override @useResult
$Res call({
 String? targetField, String? sourcePath, List<DataTransForm> transforms, ValueSourceType type
});




}
/// @nodoc
class __$TemplateFieldMappingCopyWithImpl<$Res>
    implements _$TemplateFieldMappingCopyWith<$Res> {
  __$TemplateFieldMappingCopyWithImpl(this._self, this._then);

  final _TemplateFieldMapping _self;
  final $Res Function(_TemplateFieldMapping) _then;

/// Create a copy of FieldMapping
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetField = freezed,Object? sourcePath = freezed,Object? transforms = null,Object? type = null,}) {
  return _then(_TemplateFieldMapping(
targetField: freezed == targetField ? _self.targetField : targetField // ignore: cast_nullable_to_non_nullable
as String?,sourcePath: freezed == sourcePath ? _self.sourcePath : sourcePath // ignore: cast_nullable_to_non_nullable
as String?,transforms: null == transforms ? _self._transforms : transforms // ignore: cast_nullable_to_non_nullable
as List<DataTransForm>,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ValueSourceType,
  ));
}


}

/// @nodoc
mixin _$DataTransForm {

 String? get pattern; String? get replacement; TransFormType get type;
/// Create a copy of DataTransForm
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DataTransFormCopyWith<DataTransForm> get copyWith => _$DataTransFormCopyWithImpl<DataTransForm>(this as DataTransForm, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DataTransForm&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.replacement, replacement) || other.replacement == replacement)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,pattern,replacement,type);

@override
String toString() {
  return 'DataTransForm(pattern: $pattern, replacement: $replacement, type: $type)';
}


}

/// @nodoc
abstract mixin class $DataTransFormCopyWith<$Res>  {
  factory $DataTransFormCopyWith(DataTransForm value, $Res Function(DataTransForm) _then) = _$DataTransFormCopyWithImpl;
@useResult
$Res call({
 String pattern, String replacement, TransFormType type
});




}
/// @nodoc
class _$DataTransFormCopyWithImpl<$Res>
    implements $DataTransFormCopyWith<$Res> {
  _$DataTransFormCopyWithImpl(this._self, this._then);

  final DataTransForm _self;
  final $Res Function(DataTransForm) _then;

/// Create a copy of DataTransForm
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pattern = null,Object? replacement = null,Object? type = null,}) {
  return _then(_self.copyWith(
pattern: null == pattern ? _self.pattern! : pattern // ignore: cast_nullable_to_non_nullable
as String,replacement: null == replacement ? _self.replacement! : replacement // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransFormType,
  ));
}

}


/// Adds pattern-matching-related methods to [DataTransForm].
extension DataTransFormPatterns on DataTransForm {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DataTransform value)?  $default,{TResult Function( _TrimDataTransForm value)?  trim,TResult Function( _UnescapeDataTransForm value)?  unescape,TResult Function( _RmoveDataTransForm value)?  removeWhitespace,TResult Function( _ReplaceDataTransForm value)?  replace,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DataTransform() when $default != null:
return $default(_that);case _TrimDataTransForm() when trim != null:
return trim(_that);case _UnescapeDataTransForm() when unescape != null:
return unescape(_that);case _RmoveDataTransForm() when removeWhitespace != null:
return removeWhitespace(_that);case _ReplaceDataTransForm() when replace != null:
return replace(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DataTransform value)  $default,{required TResult Function( _TrimDataTransForm value)  trim,required TResult Function( _UnescapeDataTransForm value)  unescape,required TResult Function( _RmoveDataTransForm value)  removeWhitespace,required TResult Function( _ReplaceDataTransForm value)  replace,}){
final _that = this;
switch (_that) {
case _DataTransform():
return $default(_that);case _TrimDataTransForm():
return trim(_that);case _UnescapeDataTransForm():
return unescape(_that);case _RmoveDataTransForm():
return removeWhitespace(_that);case _ReplaceDataTransForm():
return replace(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DataTransform value)?  $default,{TResult? Function( _TrimDataTransForm value)?  trim,TResult? Function( _UnescapeDataTransForm value)?  unescape,TResult? Function( _RmoveDataTransForm value)?  removeWhitespace,TResult? Function( _ReplaceDataTransForm value)?  replace,}){
final _that = this;
switch (_that) {
case _DataTransform() when $default != null:
return $default(_that);case _TrimDataTransForm() when trim != null:
return trim(_that);case _UnescapeDataTransForm() when unescape != null:
return unescape(_that);case _RmoveDataTransForm() when removeWhitespace != null:
return removeWhitespace(_that);case _ReplaceDataTransForm() when replace != null:
return replace(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? pattern,  String? replacement,  TransFormType type)?  $default,{TResult Function( String? pattern,  String? replacement,  TransFormType type)?  trim,TResult Function( String? pattern,  String? replacement,  TransFormType type)?  unescape,TResult Function( String? pattern,  String? replacement,  TransFormType type)?  removeWhitespace,TResult Function( String pattern,  String replacement,  TransFormType type)?  replace,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DataTransform() when $default != null:
return $default(_that.pattern,_that.replacement,_that.type);case _TrimDataTransForm() when trim != null:
return trim(_that.pattern,_that.replacement,_that.type);case _UnescapeDataTransForm() when unescape != null:
return unescape(_that.pattern,_that.replacement,_that.type);case _RmoveDataTransForm() when removeWhitespace != null:
return removeWhitespace(_that.pattern,_that.replacement,_that.type);case _ReplaceDataTransForm() when replace != null:
return replace(_that.pattern,_that.replacement,_that.type);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? pattern,  String? replacement,  TransFormType type)  $default,{required TResult Function( String? pattern,  String? replacement,  TransFormType type)  trim,required TResult Function( String? pattern,  String? replacement,  TransFormType type)  unescape,required TResult Function( String? pattern,  String? replacement,  TransFormType type)  removeWhitespace,required TResult Function( String pattern,  String replacement,  TransFormType type)  replace,}) {final _that = this;
switch (_that) {
case _DataTransform():
return $default(_that.pattern,_that.replacement,_that.type);case _TrimDataTransForm():
return trim(_that.pattern,_that.replacement,_that.type);case _UnescapeDataTransForm():
return unescape(_that.pattern,_that.replacement,_that.type);case _RmoveDataTransForm():
return removeWhitespace(_that.pattern,_that.replacement,_that.type);case _ReplaceDataTransForm():
return replace(_that.pattern,_that.replacement,_that.type);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? pattern,  String? replacement,  TransFormType type)?  $default,{TResult? Function( String? pattern,  String? replacement,  TransFormType type)?  trim,TResult? Function( String? pattern,  String? replacement,  TransFormType type)?  unescape,TResult? Function( String? pattern,  String? replacement,  TransFormType type)?  removeWhitespace,TResult? Function( String pattern,  String replacement,  TransFormType type)?  replace,}) {final _that = this;
switch (_that) {
case _DataTransform() when $default != null:
return $default(_that.pattern,_that.replacement,_that.type);case _TrimDataTransForm() when trim != null:
return trim(_that.pattern,_that.replacement,_that.type);case _UnescapeDataTransForm() when unescape != null:
return unescape(_that.pattern,_that.replacement,_that.type);case _RmoveDataTransForm() when removeWhitespace != null:
return removeWhitespace(_that.pattern,_that.replacement,_that.type);case _ReplaceDataTransForm() when replace != null:
return replace(_that.pattern,_that.replacement,_that.type);case _:
  return null;

}
}

}

/// @nodoc


class _DataTransform implements DataTransForm {
  const _DataTransform({this.pattern, this.replacement, required this.type});
  

@override final  String? pattern;
@override final  String? replacement;
@override final  TransFormType type;

/// Create a copy of DataTransForm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DataTransformCopyWith<_DataTransform> get copyWith => __$DataTransformCopyWithImpl<_DataTransform>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DataTransform&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.replacement, replacement) || other.replacement == replacement)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,pattern,replacement,type);

@override
String toString() {
  return 'DataTransForm(pattern: $pattern, replacement: $replacement, type: $type)';
}


}

/// @nodoc
abstract mixin class _$DataTransformCopyWith<$Res> implements $DataTransFormCopyWith<$Res> {
  factory _$DataTransformCopyWith(_DataTransform value, $Res Function(_DataTransform) _then) = __$DataTransformCopyWithImpl;
@override @useResult
$Res call({
 String? pattern, String? replacement, TransFormType type
});




}
/// @nodoc
class __$DataTransformCopyWithImpl<$Res>
    implements _$DataTransformCopyWith<$Res> {
  __$DataTransformCopyWithImpl(this._self, this._then);

  final _DataTransform _self;
  final $Res Function(_DataTransform) _then;

/// Create a copy of DataTransForm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pattern = freezed,Object? replacement = freezed,Object? type = null,}) {
  return _then(_DataTransform(
pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,replacement: freezed == replacement ? _self.replacement : replacement // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransFormType,
  ));
}


}

/// @nodoc


class _TrimDataTransForm implements DataTransForm {
  const _TrimDataTransForm({this.pattern, this.replacement, this.type = TransFormType.trim});
  

@override final  String? pattern;
@override final  String? replacement;
@override@JsonKey() final  TransFormType type;

/// Create a copy of DataTransForm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrimDataTransFormCopyWith<_TrimDataTransForm> get copyWith => __$TrimDataTransFormCopyWithImpl<_TrimDataTransForm>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrimDataTransForm&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.replacement, replacement) || other.replacement == replacement)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,pattern,replacement,type);

@override
String toString() {
  return 'DataTransForm.trim(pattern: $pattern, replacement: $replacement, type: $type)';
}


}

/// @nodoc
abstract mixin class _$TrimDataTransFormCopyWith<$Res> implements $DataTransFormCopyWith<$Res> {
  factory _$TrimDataTransFormCopyWith(_TrimDataTransForm value, $Res Function(_TrimDataTransForm) _then) = __$TrimDataTransFormCopyWithImpl;
@override @useResult
$Res call({
 String? pattern, String? replacement, TransFormType type
});




}
/// @nodoc
class __$TrimDataTransFormCopyWithImpl<$Res>
    implements _$TrimDataTransFormCopyWith<$Res> {
  __$TrimDataTransFormCopyWithImpl(this._self, this._then);

  final _TrimDataTransForm _self;
  final $Res Function(_TrimDataTransForm) _then;

/// Create a copy of DataTransForm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pattern = freezed,Object? replacement = freezed,Object? type = null,}) {
  return _then(_TrimDataTransForm(
pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,replacement: freezed == replacement ? _self.replacement : replacement // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransFormType,
  ));
}


}

/// @nodoc


class _UnescapeDataTransForm implements DataTransForm {
  const _UnescapeDataTransForm({this.pattern, this.replacement, this.type = TransFormType.unescape});
  

@override final  String? pattern;
@override final  String? replacement;
@override@JsonKey() final  TransFormType type;

/// Create a copy of DataTransForm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnescapeDataTransFormCopyWith<_UnescapeDataTransForm> get copyWith => __$UnescapeDataTransFormCopyWithImpl<_UnescapeDataTransForm>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnescapeDataTransForm&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.replacement, replacement) || other.replacement == replacement)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,pattern,replacement,type);

@override
String toString() {
  return 'DataTransForm.unescape(pattern: $pattern, replacement: $replacement, type: $type)';
}


}

/// @nodoc
abstract mixin class _$UnescapeDataTransFormCopyWith<$Res> implements $DataTransFormCopyWith<$Res> {
  factory _$UnescapeDataTransFormCopyWith(_UnescapeDataTransForm value, $Res Function(_UnescapeDataTransForm) _then) = __$UnescapeDataTransFormCopyWithImpl;
@override @useResult
$Res call({
 String? pattern, String? replacement, TransFormType type
});




}
/// @nodoc
class __$UnescapeDataTransFormCopyWithImpl<$Res>
    implements _$UnescapeDataTransFormCopyWith<$Res> {
  __$UnescapeDataTransFormCopyWithImpl(this._self, this._then);

  final _UnescapeDataTransForm _self;
  final $Res Function(_UnescapeDataTransForm) _then;

/// Create a copy of DataTransForm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pattern = freezed,Object? replacement = freezed,Object? type = null,}) {
  return _then(_UnescapeDataTransForm(
pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,replacement: freezed == replacement ? _self.replacement : replacement // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransFormType,
  ));
}


}

/// @nodoc


class _RmoveDataTransForm implements DataTransForm {
  const _RmoveDataTransForm({this.pattern, this.replacement, this.type = TransFormType.removeWhitespace});
  

@override final  String? pattern;
@override final  String? replacement;
@override@JsonKey() final  TransFormType type;

/// Create a copy of DataTransForm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RmoveDataTransFormCopyWith<_RmoveDataTransForm> get copyWith => __$RmoveDataTransFormCopyWithImpl<_RmoveDataTransForm>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RmoveDataTransForm&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.replacement, replacement) || other.replacement == replacement)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,pattern,replacement,type);

@override
String toString() {
  return 'DataTransForm.removeWhitespace(pattern: $pattern, replacement: $replacement, type: $type)';
}


}

/// @nodoc
abstract mixin class _$RmoveDataTransFormCopyWith<$Res> implements $DataTransFormCopyWith<$Res> {
  factory _$RmoveDataTransFormCopyWith(_RmoveDataTransForm value, $Res Function(_RmoveDataTransForm) _then) = __$RmoveDataTransFormCopyWithImpl;
@override @useResult
$Res call({
 String? pattern, String? replacement, TransFormType type
});




}
/// @nodoc
class __$RmoveDataTransFormCopyWithImpl<$Res>
    implements _$RmoveDataTransFormCopyWith<$Res> {
  __$RmoveDataTransFormCopyWithImpl(this._self, this._then);

  final _RmoveDataTransForm _self;
  final $Res Function(_RmoveDataTransForm) _then;

/// Create a copy of DataTransForm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pattern = freezed,Object? replacement = freezed,Object? type = null,}) {
  return _then(_RmoveDataTransForm(
pattern: freezed == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String?,replacement: freezed == replacement ? _self.replacement : replacement // ignore: cast_nullable_to_non_nullable
as String?,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransFormType,
  ));
}


}

/// @nodoc


class _ReplaceDataTransForm implements DataTransForm {
  const _ReplaceDataTransForm({required this.pattern, required this.replacement, this.type = TransFormType.replace});
  

@override final  String pattern;
@override final  String replacement;
@override@JsonKey() final  TransFormType type;

/// Create a copy of DataTransForm
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReplaceDataTransFormCopyWith<_ReplaceDataTransForm> get copyWith => __$ReplaceDataTransFormCopyWithImpl<_ReplaceDataTransForm>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReplaceDataTransForm&&(identical(other.pattern, pattern) || other.pattern == pattern)&&(identical(other.replacement, replacement) || other.replacement == replacement)&&(identical(other.type, type) || other.type == type));
}


@override
int get hashCode => Object.hash(runtimeType,pattern,replacement,type);

@override
String toString() {
  return 'DataTransForm.replace(pattern: $pattern, replacement: $replacement, type: $type)';
}


}

/// @nodoc
abstract mixin class _$ReplaceDataTransFormCopyWith<$Res> implements $DataTransFormCopyWith<$Res> {
  factory _$ReplaceDataTransFormCopyWith(_ReplaceDataTransForm value, $Res Function(_ReplaceDataTransForm) _then) = __$ReplaceDataTransFormCopyWithImpl;
@override @useResult
$Res call({
 String pattern, String replacement, TransFormType type
});




}
/// @nodoc
class __$ReplaceDataTransFormCopyWithImpl<$Res>
    implements _$ReplaceDataTransFormCopyWith<$Res> {
  __$ReplaceDataTransFormCopyWithImpl(this._self, this._then);

  final _ReplaceDataTransForm _self;
  final $Res Function(_ReplaceDataTransForm) _then;

/// Create a copy of DataTransForm
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pattern = null,Object? replacement = null,Object? type = null,}) {
  return _then(_ReplaceDataTransForm(
pattern: null == pattern ? _self.pattern : pattern // ignore: cast_nullable_to_non_nullable
as String,replacement: null == replacement ? _self.replacement : replacement // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransFormType,
  ));
}


}

// dart format on
