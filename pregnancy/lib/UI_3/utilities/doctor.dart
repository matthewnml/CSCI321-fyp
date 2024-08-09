import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class DoctorProfileService {
  final String baseUrl;

  DoctorProfileService(this.baseUrl);

  Future<String> fetchDoctorProfiles(int page) async {
    final url = '$baseUrl?page=$page';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.body; // This is the HTML content of the page
    } else {
      throw Exception('Failed to load profiles');
    }
  }

  List<Map<String, String>> parseDoctorProfiles(String htmlContent) {
    var document = parse(htmlContent);
    
    // Assuming doctor profiles are in divs with a class "doctor-profile"
    var profileElements = document.getElementsByClassName('doctor-profile');
    
    List<Map<String, String>> profiles = [];
    
    for (var element in profileElements) {
      var name = element.querySelector('.doctor-name')?.text ?? '';
      var specialty = element.querySelector('.doctor-specialty')?.text ?? '';
      var profileUrl = element.querySelector('a')?.attributes['href'] ?? '';
      
      profiles.add({
        'name': name,
        'specialty': specialty,
        'profileUrl': profileUrl,
      });
    }
    
    return profiles;
  }

  Future<int> getTotalPages() async {
    String htmlContent = await fetchDoctorProfiles(1);
    var document = parse(htmlContent);

    // Extract the total number of pages from the pagination section
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
