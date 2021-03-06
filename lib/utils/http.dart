import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';

import '../main.dart';
import '../main.dart';

Dio dio;
Uri uri;
var baseUrl;

void initConfig() async {
  if (localStorage.containsKey('serverURL')) {
    uri = Uri.parse(localStorage.getString('serverURL'));
    baseUrl = uri.origin;
    BaseOptions options = new BaseOptions(baseUrl: "$baseUrl/api");
    dio = Dio(options);
    var cookieJar = await getCookiePath();
    dio.interceptors.add(CookieManager(cookieJar));
  }
}

void cacheAllUsers() async {
  if (localStorage.containsKey('allUsers')) {
    return;
  } else {}
}

void setBaseUrl(url) async {
  if (!url.startsWith('https://')) {
    url = "https://$url";
  }
  baseUrl = url;
  BaseOptions options = new BaseOptions(baseUrl: "$url/api");
  dio = Dio(options);

  var cookieJar = await getCookiePath();
  dio.interceptors.add(CookieManager(cookieJar));

  uri = Uri.parse(url);

  localStorage.setString('serverURL', url);
}

Future getCookiePath() async {
  Directory appDocDir = await getApplicationSupportDirectory();
  String appDocPath = appDocDir.path;

  return PersistCookieJar(
    dir: appDocPath,
    ignoreExpires: true,
  );
}

Future<String> getCookies() async {
  var cookieJar = await getCookiePath();

  var cookies = cookieJar.loadForRequest(uri);

  var cookie = CookieManager.getCookies(cookies);

  return cookie;
}

String getAbsoluteUrl(String url) {
  return Uri.encodeFull("$baseUrl$url");
}
