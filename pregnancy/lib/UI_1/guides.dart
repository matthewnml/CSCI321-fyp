import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GuidesPage extends StatelessWidget {
  const GuidesPage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> guides = const [
    {
      'title': 'Fitness Guides',
      'urls': [
        {'title': 'GUIDE TO FITNESS During and After Pregnancy in the CF', 'url': 'https://cfmws.ca/CFMWS/media/images/documents/4.0%20Sport%20Fitness%20and%20Rec/4.1.2%20Fitness%20Class/Fitness-During-and-After-Pregnancy_1.pdf'},
        {'title': 'Physical activity and exercise during pregnancy - guidelines', 'url': 'https://www.health.gov.au/sites/default/files/2023-11/physical-activity-and-exercise-during-pregnancy-guidelines-brochure.pdf'},
        {'title': 'ACTIVE PREGNANCY GUIDE', 'url': 'https://www.researchgate.net/publication/370874994_ACTIVE_PREGNANCY_GUIDE_-Physical_activity_nutrition_and_sleep' },
        {'title': 'Fit for Pregnancy', 'url': 'https://thepogp.co.uk/_userfiles/pages/files/resources/21xxxxpogpffpregnancy_signed_off.pdf' },
        {'title': 'Prenatal-Postnatal-Exercise-Guidelines', 'url': 'https://members.momsintofitness.com/wp-content/uploads/Prenatal-Postnatal-Exercise-Guidelines.pdf' },
      ],
    },
    {
      'title': 'Pregnancy Symptoms Guides',
      'urls': [
        {'title': 'The Pregnancy Book', 'url': 'https://www.stgeorges.nhs.uk/wp-content/uploads/2013/11/Pregnancy_Book_comp.pdf'},
        {'title': 'Healthy-Pregnancy-Guide', 'url': 'https://www.canada.ca/content/dam/phac-aspc/documents/services/health-promotion/healthy-pregnancy/healthy-pregnancy-guide.pdf'},
        {'title': 'Your Guide To Pregnancy', 'url': 'https://www.austintexas.gov/sites/default/files/files/Guide%20to%20Pregnancy-%20English.pdf'},
        {'title': 'Pregnancy-Guide', 'url': 'https://www.fhn.org/docs/Pregnancy-Guide.pdf'},
        {'title': 'A Guide To Pregnancy', 'url': 'https://www.ssmhealth.com/getmedia/440bd96d-b033-49f9-921b-f399d925387e/ssm-health-pregnancy-guide.pdf'},
      ],
    },
    {
      'title': 'Nutrition Guides',
      'urls': [
        {'title': 'Prenatal Nutrition Education', 'url': 'https://www.va.gov/files/2023-09/Nutrition%20During%20Pregnancy.pdf'},
        {'title': 'Prenatal Nutrition', 'url': 'https://www.med.umich.edu/pfans/_pdf/hetm-2017/0417-prenatalnutrition.pdf'},
        {'title': 'Eating well for a healthy pregnancy', 'url': 'https://www.mkchildrenshealth.cnwl.nhs.uk/media/1030/eating-well.pdf'},
        {'title': 'Healthy eating in pregnancy', 'url': 'https://www.eatforhealth.gov.au/sites/default/files/files/the_guidelines/n55h_healthy_eating_during_pregnancy.pdf'},
        {'title': 'The pregnancy food guide', 'url': 'https://www.brighamandwomens.org/assets/BWH/obgyn/pdfs/nob-bwh-pregnancy-food-guide.pdf'},
      ],
    },
    {
      'title': 'Video Guides',
      'urls': [
        {'title': 'Inside Pregnancy: Weeks 1-9 | BabyCenter', 'url': 'https://www.youtube.com/watch?v=4l9GE_eaMSs'},
        {'title': 'Pregnancy: The First Trimester', 'url': 'https://www.youtube.com/watch?v=8312a32dcQc'},
        {'title': 'Pregnancy: A Month-By-Month Guide |3D Animation', 'url': 'https://www.youtube.com/watch?v=8BH7WFmRs-E'},
        {'title': 'Healthy Pregnancy Tips From the CDC', 'url': 'https://www.youtube.com/watch?v=wGvr4S33tW4'},
        {'title': 'Nutrition Tips: Pregnancy and Nutrition', 'url': 'https://www.youtube.com/watch?v=IWBF60kQcuk'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guides'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: guides.map((guide) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text(
                  guide['title']!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GuideDetailPage(guide: guide),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class GuideDetailPage extends StatelessWidget {
  final Map<String, dynamic> guide;

  const GuideDetailPage({Key? key, required this.guide}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(guide['title']),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: guide['urls'].length,
        itemBuilder: (context, index) {
          final urlInfo = guide['urls'][index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text(
                urlInfo['title'],
                style: const TextStyle(fontSize: 16),
              ),
              trailing: const Icon(Icons.open_in_browser),
              onTap: () {
                _launchURL(urlInfo['url']);
              },
            ),
          );
        },
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
