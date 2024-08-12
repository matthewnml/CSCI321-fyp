import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class DoctorProfileService {
  final String baseUrl;
  late Uri uri;

  DoctorProfileService(this.baseUrl) {
    // Initialize the URI within the constructor using the 'replace' method to set initial query parameters
    uri = Uri.parse(baseUrl).replace(queryParameters: {
      'k': Uri.encodeComponent('*')  // Properly encode the '*' character if needed
    });
  }

  Future<String> fetchDoctorProfiles(int page) async {
    try {
      // Modify the URI to include the page number dynamically
      Uri pageUri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        'page': page.toString()
      });

      // Use the modified URI in the http.get method directly
      final response = await http.get(pageUri, headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36'
      });

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load profiles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch doctor profiles: $e');
    }
  }

  List<Map<String, String>> parseDoctorProfiles(String htmlContent) {
  var document = parse(htmlContent);
  var profileElements = document.querySelectorAll('figcaption');
  var profiles = <Map<String, String>>[];

  for (var element in profileElements) {
    // Extracting the name
    var nameElement = element.querySelector('h3 a');
    var name = nameElement?.text.trim() ?? 'No name';

    // Debug output to check if h4 elements are captured
    var h4Elements = element.querySelectorAll('h4');

    var specialty = 'No specialty';
    for (var h4 in h4Elements) {
      if (h4.text.contains('Specialty')) {
        specialty = 'Specialty/Department: ' + h4.text.split(':').last.trim();
        break;
      }
    }

    // Extracting the location
    var location = 'No location';
    var locationElement = element.querySelector('div[id^="ctl00_"] img');
    if (locationElement != null && locationElement.attributes['alt'] != null) {
      location = locationElement.attributes['alt']!;
    } else {
      var possibleLocationElement = element.querySelector('h4[id*="PrimaryInstitution"]');
      if (possibleLocationElement != null) {
        location = 'Institute: ' + possibleLocationElement.text.split('"').last;
      }
    }

    profiles.add({
      'name': name,
      'specialty': specialty,
      'location': location
    });
  }

  return profiles;
}





  Future<int> getTotalPages() async {
  try {
    String htmlContent = await fetchDoctorProfiles(1); // Fetching the first page
    var document = parse(htmlContent);

    // Example of parsing pagination: Find a 'span' or 'div' that contains total pages info
    var paginationText = document.querySelector('.pagination-info')?.text; // Adjust the selector as needed
    if (paginationText != null) {
      // Extract total pages from paginationText, assuming it contains text like "Page 1 of 10"
      var matches = RegExp(r'of (\d+)').firstMatch(paginationText);
      if (matches != null && matches.groupCount >= 1) {
        return int.parse(matches.group(1)!);
      }
    }
    return 1; // Default to one page if no pagination info found
  } catch (e) {
    throw Exception('Failed to determine total pages: $e');
  }
}


  Future<List<Map<String, String>>> getAllDoctorProfiles() async {
    try {
      int totalPages = await getTotalPages();
      List<Map<String, String>> allProfiles = [];

      for (int page = 1; page <= totalPages; page++) {
        String htmlContent = await fetchDoctorProfiles(page);
        List<Map<String, String>> profiles = parseDoctorProfiles(htmlContent);
        allProfiles.addAll(profiles);
      }
      return allProfiles;
    } catch (e) {
      throw Exception('Failed to fetch all profiles: $e');
    }
  }
}
