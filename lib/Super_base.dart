
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuperBase{

  final String baseUrl = 'https://api.themoviedb.org/3';
  final String apiKey = 'api_key=abb567a3b20034b814a0c424bd06a3cb';

  static String sessionId='';

  String url(String url) => "$baseUrl$url?$apiKey&guest_session_id=$sessionId";

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();


  RegExp emailExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");


  bool canDecode(String jsonString) {
    var decodeSucceeded = false;
    try {
      json.decode(jsonString);
      decodeSucceeded = true;
    } on FormatException {}
    return decodeSucceeded;
  }

  Future<void> saveVal(String key, String value) async {
    (await prefs).setString(key, value);
    return Future.value();
  }

  Widget loadBox(
      {Color? color,
        Color? bColor,
        double size= 20,
        double? value,
        double width= 3}) {
    return SizedBox(
      height: size,
      width: size,
      child:Platform.isIOS?CupertinoActivityIndicator(
        color: color??Colors.red,
      ):CircularProgressIndicator(
        backgroundColor: bColor,
        strokeWidth: width,
        value: value,
        valueColor: AlwaysStoppedAnimation<Color>(color??Colors.red),
      )
    );
  }



  static String? token;

  Future<void> ajax(
      {required String url,
        required BuildContext context,
        String method: "GET",
        FormData? data,
        Map<String, dynamic>? map,
        bool server: true,
        bool auth: true,
        bool local: false,
        bool base2: false,
        String? authKey,
        bool json: true,
        void Function(CancelToken token)? onCancelToken,
        bool absolutePath: false,
        ResponseType responseType: ResponseType.json,
        bool localSave: false,
        String? jsonData,
        void Function(dynamic response, String url)? onValue,
        void Function()? onEnd,
        void Function(dynamic response, String url)? error}) async {
        url = absolutePath ? url : this.url(url);

    authKey = authKey ?? SuperBase.token;
    Map<String, String> headers = <String, String>{};
    headers["Accept"] = "application/json";

    var prf = await prefs;
    Options opt = Options(
        responseType: responseType,
        contentType: Headers.jsonContentType,
        headers: headers,
        receiveDataWhenStatusError: true,
        sendTimeout: 30000,
        receiveTimeout: 30000);

    if (!server) {
      String? val = prf.getString(url);
      bool t = onValue != null && val != null;
      local = local && t;
      localSave = localSave && t;
      var c = (t && json && canDecode(val)) || !json;
      t = t && c;
      if (t) onValue(json ? jsonDecode(val) : val, url);
    }

    if (local) {
      if (onEnd != null) onEnd();
      return Future.value();
    }

    CancelToken token = CancelToken();

    if (onCancelToken != null) {
      onCancelToken(token);
    }

    Future<Response> future = method.toUpperCase() == "POST"
        ? Dio().post(url,
        data: jsonData ?? map ?? data, options: opt, cancelToken: token)
        : method.toUpperCase() == "PUT"
        ? Dio().put(url,
        data: jsonData ?? map ?? data, options: opt, cancelToken: token)
        : method.toUpperCase() == "DELETE"
        ? Dio().delete(url,
        data: jsonData ?? map ?? data,
        options: opt,
        cancelToken: token)
        : Dio().get(url, options: opt, cancelToken: token);

    try {
      Response response = await future;
      dynamic data = response.data;
      if (response.statusCode == 200 || response.statusCode == 201) {
        //var cond = (data is String && json && canDecode(data)) || !json;
        if (!server) saveVal(url, jsonEncode(data));

        if (onValue != null && !localSave) {
          onValue(data, url);
        } else if (error != null) {
          error(data, url);
        }
      }else if (error != null) {
        error(data, url);
      }
    } on DioError catch (e) {
      var resp = e.response != null ? e.response!.data : e.message;
      if (error != null) error(resp, url);
    }
    if (onEnd != null) onEnd();
    return Future.value();
  }

  void showSnack(String string,BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(string)));
  }
}