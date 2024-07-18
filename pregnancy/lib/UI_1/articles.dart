import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticlesPage extends StatelessWidget {
  const ArticlesPage({super.key});

  final List<Map<String, dynamic>> articles = const [
    {
      'title': 'Female Health Articles',
      'urls': [
        {'title': 'All Women Health Articles', 'url': 'https://www.health.harvard.edu/topics/womens-health/all?page=3'},
        {'title': 'Heart Health', 'url': 'https://www.nuhcs.com.sg/Heart-Health/pulsearticles/Pages/Tackling-the-Number-One-Cause-of-Death-in-Women.aspx'},
        {'title': 'A-Z Health Topics', 'url': 'https://www.womenshealth.gov/a-z-topics'},
        {'title': 'More than a third of women experience lasting health problems after childbirth', 'url' : 'https://www.who.int/news/item/07-12-2023-more-than-a-third-of-women-experience-lasting-health-problems-after-childbirth'},
        {'title': 'How to stay healthy during pregnancy', 'url' : 'https://magazine.medlineplus.gov/article/how-to-stay-healthy-during-pregnancy'},
      ],
    },
    {
      'title': 'Conceiving Articles',
      'urls': [
        {'title': 'Conception: Fertilization, Process & When It Happens', 'url': 'https://my.clevelandclinic.org/health/articles/11585-conception'},
        {'title': 'Pre-Pregnancy Preparations', 'url': 'https://www.healthhub.sg/live-healthy/guide-1-pre-pregnancy-preparations'},
        {'title': 'Advice on conceiving and preparing for pregnancy', 'url': 'https://www.nidirect.gov.uk/articles/advice-conceiving-and-preparing-pregnancy'},
        {'title': 'Latest Fertility Articles', 'url': 'https://www.yourfertility.org.au/latest-articles'},
        {'title': '9 Conception Stories to Read If You are Having Trouble Getting Pregnant', 'url': 'https://www.parents.com/getting-pregnant/trying-to-conceive/tips/success-after-trouble-getting-pregnant/'},
      ],
    },
    {
      'title': 'Parenting Articles',
      'urls': [
        {'title': 'Parenting News & Advice for Moms and Dads', 'url': 'https://www.today.com/parents'},
        {'title': 'Parenting', 'url': 'https://www.psychologytoday.com/us/basics/parenting'},
        {'title': 'Child Development', 'url': 'https://www.unicef.org/parenting/child-development'},
        {'title': 'Why Parenting Styles Matter When Raising Children', 'url': 'https://www.verywellmind.com/parenting-styles-2795072'},
        {'title': 'Be the Best Parent You Can Be', 'url': 'https://www.healthline.com/health/parenting/parenting-skills#important-skills'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: articles.map((article) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ListTile(
                title: Text(
                  article['title']!,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleDetailPage(article: article),
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

class ArticleDetailPage extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticleDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article['title']),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: article['urls'].length,
        itemBuilder: (context, index) {
          final urlInfo = article['urls'][index];
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
