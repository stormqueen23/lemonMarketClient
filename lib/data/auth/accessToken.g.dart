// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accessToken.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccessToken _$AccessTokenFromJson(Map<String, dynamic> json) => AccessToken(
      json['access_token'] as String,
      json['expires_in'] as int,
      json['scope'] as String,
      json['token_type'] as String,
    );

Map<String, dynamic> _$AccessTokenToJson(AccessToken instance) =>
    <String, dynamic>{
      'access_token': instance.token,
      'expires_in': instance.expiresIn,
      'scope': instance.scope,
      'token_type': instance.type,
    };