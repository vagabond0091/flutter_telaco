import 'dart:convert';

import 'package:http/http.dart' as http;

class CallApi {
  final String _url = 'http://www.telaco.online/api/';
  postData(data, apiUrl) async {
    return await http.post(
      Uri.parse(_url + apiUrl),
      body: jsonEncode(data),
      headers: _setHeaders(),
    );
  }

  loginData(data, apiUrl) async {
    return await http.post(
      Uri.parse(_url + apiUrl),
      body: jsonEncode(data),
      headers: _setHeaders(),
    );
  }

  getData(apiUrl) async {
    return await http.get(
      Uri.parse(_url + apiUrl),
      headers: _setHeaders(),
    );
  }
  deleteData(apiUrl) async {
    return await http.delete(
      Uri.parse(_url + apiUrl),
      headers: _setHeaders(),
    );
  }
  updateSingleData(apiUrl) async {
    return await http.put(
      Uri.parse(_url + apiUrl),
      headers: _setHeaders(),
    );
  }

  updateData(data,apiUrl) async {
    return await http.put(
      Uri.parse(_url + apiUrl),
      body: jsonEncode(data),
      headers: _setHeaders(),
    );
  }

  _setHeaders() =>
      {'Content-type': 'application/json', 'Accept': 'application/json'};
}
