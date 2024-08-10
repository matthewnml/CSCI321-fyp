import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class DoctorProfileService {
  final String baseUrl;
  late Uri uri;  // Marking `uri` as `late`

  DoctorProfileService(this.baseUrl) {
    // Initialize `uri` within the constructor using the `replace` method to set initial query parameters
    uri = Uri.parse(baseUrl).replace(queryParameters: {
      'k': Uri.encodeComponent('*')  // Ensure '*' is properly encoded if needed
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
      var nameElement = element.querySelector('h3 a');
      var qualificationsElement = element.querySelector('.sub-line p');
      var specialtyElement = element.querySelector('h4');
      var interestsElement = element.querySelector('div[id^="ctl00"]');

      var name = nameElement?.text.trim() ?? 'No name';
      var profileUrl = nameElement?.attributes['href'] ?? '#';
      var qualifications = qualificationsElement?.text.trim() ?? 'No qualifications';
      var specialty = specialtyElement?.text.trim() ?? 'No specialty';
      var interests = interestsElement?.text.trim() ?? 'No clinical interests';

      profiles.add({
        'name': name,
        'profileUrl': profileUrl,
        'qualifications': qualifications,
        'specialty': specialty,
        'clinicalInterests': interests,
      });
    }

    return profiles;
  }

  Future<int> getTotalPages() async {
    String htmlContent = await fetchDoctorProfiles(1);
    var document = parse(htmlContent);
    var totalPagesElement = document.querySelector('.pagination')?.children.last;
    int totalPages = int.parse(totalPagesElement?.text.trim() ?? '1');
    return totalPages;
  }

  Future<List<Map<String, String>>> getAllDoctorProfiles() async {
    int totalPages = await getTotalPages();
    List<Map<String, String>> allProfiles = [];

    for (int page = 1; page <= totalPages; page++) {
      String htmlContent = await fetchDoctorProfiles(page);
      List<Map<String, String>> profiles = parseDoctorProfiles(htmlContent);
      allProfiles.addAll(profiles);
    }

    return allProfiles;
  }
}
