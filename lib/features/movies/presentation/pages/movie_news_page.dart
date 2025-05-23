import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class MovieNewsPage extends StatefulWidget {
  final String movieTitle;

  const MovieNewsPage({Key? key, required this.movieTitle}) : super(key: key);

  @override
  State<MovieNewsPage> createState() => _MovieNewsPageState();
}

class _MovieNewsPageState extends State<MovieNewsPage> {
  List<dynamic> newsArticles = [];
  bool isLoading = true;

  final String apiKey = '00683ba824af83a9f031efef28abb989'; // ← Buraya kendi API anahtarını yaz

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    final url = Uri.parse(
        'https://gnews.io/api/v4/search?q=${Uri.encodeComponent(widget.movieTitle)}&lang=tr&max=10&token=$apiKey');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          // Türkçe haberleri sadece çekiyoruz
          newsArticles = (data['articles'] as List).where((article) {
            // Başlıkta film adını içermelidir ve dil Türkçe olmalı
            final title = article['title']?.toLowerCase() ?? '';
            return title.contains(widget.movieTitle.toLowerCase());
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Haberler alınamadı.');
      }
    } catch (e) {
      print('Hata: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // URL'yi açmak için bir fonksiyon
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Haber açılabilir URL bulunamadı: $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.movieTitle} Haberleri')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : newsArticles.isEmpty
              ? const Center(child: Text('Hiç haber bulunamadı.'))
              : ListView.builder(
                  itemCount: newsArticles.length,
                  itemBuilder: (context, index) {
                    final article = newsArticles[index];
                    final imageUrl = article['image'] ?? '';
                    final title = article['title'] ?? '';
                    final description = article['description'] ?? '';
                    final articleUrl = article['url'];

                    return GestureDetector(
                      onTap: () {
                        _launchURL(articleUrl); // Tıklanınca haber sayfasını aç
                      },
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                    child: Image.network(
                                      imageUrl,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    width: 120,
                                    height: 120,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, color: Colors.white),
                                  ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
