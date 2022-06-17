import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider(
  (_) => Dio(
    BaseOptions(baseUrl: "https://api.github.com"),
  ),
);
