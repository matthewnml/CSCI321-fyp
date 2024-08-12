import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class DoctorDetailsService {
  Future<Map<String, String>> fetchDoctorDetails(String url) async {
    Uri pageUri = Uri.parse(url);
    final response = await http.get(pageUri);

    // Debug: Log the response status code and URL
    print('HTTP GET Request to $url, Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('HTML Content Fetched Successfully');
      return parseDoctorDetails(response.body);
    } else {
      // Debug: Log an error if the response is not successful
      print('Failed to load doctor details from $url, Status Code: ${response.statusCode}');
      throw Exception('Failed to load doctor details from $url, Status Code: ${response.statusCode}');
    }
  }

 Map<String, String> parseDoctorDetails(String htmlContent) {
    var document = parse(htmlContent);

    // More generic selector that ensures any <figcaption> is targeted
    var figcaption = document.querySelector('figcaption');

    if (figcaption != null) {
        print('Found figcaption: ${figcaption.outerHtml}');
    } else {
        print('Figcaption not found');
    }

    var qualificationsElement = figcaption?.querySelector('.sub-line > h4');
    var designationElement = figcaption?.querySelector('h4#paraClinicalDesg');

    var qualifications = qualificationsElement?.text.trim() ?? 'No qualifications provided';
    var designation = designationElement?.text.trim() ?? 'No designation provided';


    return {
        'Qualifications': qualifications,
        'Designation': designation
    };
}

}
