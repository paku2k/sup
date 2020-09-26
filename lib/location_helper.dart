import 'package:http/http.dart' as http;
import 'dart:convert';

const GOOGLE_API_KEY = 'AIzaSyBDKEmS987S3Tp7aVICuZXrPPcy0-NZ0zk';

class LocationHelper {
  static String generateLocationPreviewImage({double lat, double lon}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lon&zoom=16&size=600x300&maptype=roadmap &markers=color:orange%7Clabel:%7C$lat,$lon&key=$GOOGLE_API_KEY';
  }

  static Future<String> getPlaceAddress(double lat, double lon) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=$GOOGLE_API_KEY';
    final response = await http.get(url);
    print("Address FOLLOWING ${json.decode(response.body)}");
    return json.decode(response.body)['results'][0]['formatted_address'];
  }
}
