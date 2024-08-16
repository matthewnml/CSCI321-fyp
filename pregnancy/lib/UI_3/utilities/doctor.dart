import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class DoctorProfileService {
  final String baseUrl;

  DoctorProfileService(this.baseUrl);

  // This method fetches raw HTML content
  Future<String> fetchDoctorProfiles(String url, int page) async {
    Uri pageUri = Uri.parse(url).replace(queryParameters: {
      ...Uri.parse(url).queryParameters,
      'PageNo': page.toString()
    });

    //print("Fetching profiles from URL: $pageUri");  // Log the full URI being requested

    final response = await http.get(pageUri, headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36'
    });

    if (response.statusCode == 200) {
      return response.body; // Return raw HTML content
    } else {
      throw Exception('Failed to load profiles: ${response.statusCode}');
    }
  }

  // This method parses HTML and returns a list of profile maps
  List<Map<String, String>> parseDoctorProfiles(String htmlContent) {
  var document = parse(htmlContent);
  var profileElements = document.querySelectorAll('figcaption');
  List<Map<String, String>> profiles = [];

  for (var element in profileElements) {
    var nameElement = element.querySelector('h3 a');
    var name = nameElement?.text.trim() ?? 'No name';
    var profileUrl = nameElement?.attributes['href'] ?? '#'; // Extracting the href attribute

    String specialty = 'No specialty';
    var h4Elements = element.querySelectorAll('h4');
    for (var h4 in h4Elements) {
      if (h4.text.contains('Specialty')) {
        specialty = 'Specialty/Department: ' + h4.text.split(':').last.trim();
      }
    }

    String location = 'No location';
    var locationElement = element.querySelector('h4[id*="PrimaryInstitution"]');
    if (locationElement != null) {
      location = 'Hospital: ' + (locationElement.text.contains('Institution:') ? locationElement.text.split('Institution:').last.trim() : locationElement.text.trim());
    } else {
      print('Location not found: ${element.outerHtml}'); // Log the element if location is missing
    }

    profiles.add({
      'name': name,
      'specialty': specialty,
      'location': location,
      'profileUrl': profileUrl // Adding URL to the map
    });
  }
  return profiles;
}


}

