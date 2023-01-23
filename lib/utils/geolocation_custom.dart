import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart' show required;

class GeolocationData {
  final String country, regionName, city, timezone, ip;

  GeolocationData({
    @required this.country,
    @required this.regionName,
    @required this.city,
    @required this.timezone,
    @required this.ip,
  });

  factory GeolocationData.fromJson(Map<String, dynamic> json) {
    return GeolocationData(
      country: json['country'],
      regionName: json['regionName'],
      city: json['city'],
      timezone: json['timezone'],
      ip: json['query'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "country": this.country,
      "regionName": this.regionName,
      "city": this.city,
      "timezone": this.timezone,
      "ip": this.ip,
    };
  }
}

class GeolocationAPI {
  static Future<GeolocationData> getData({String query = ''}) async {
    try {
      final response = await http.get("http://ip-api.com/json/$query");
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        return GeolocationData.fromJson(parsed);
      }
      print("geolocation api ${response.statusCode}");
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
