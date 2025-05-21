import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> articles = [];
  List<dynamic> likedArticles = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadLikedArticles();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      const apiKey = 'pub_881278aa99c095cc2088c3b1d0ca9e0bb4e63';
      // Original keywords list
      const keywords = [
        'climate change',
        'global warming',
        'sustainability',
        'renewable energy',
        'solar power',
        'wind energy',
        'green technology',
        'clean energy',
        'eco-friendly',
        'environmental conservation',
        'nature protection',
        'carbon footprint',
        'energy efficiency',
        'sustainable living',
        'greenhouse gases',
        'net zero',
        'fossil fuels',
        'climate crisis',
        'eco innovation',
        'low carbon',
        'green energy',
        'energy saving',
        'electric vehicles',
        'biodegradable',
        'reforestation',
        'afforestation',
        'water conservation',
        'pollution control',
        'climate policy',
        'emissions reduction',
        'clean transportation',
        'sustainable development',
        'green economy',
        'organic farming',
        'environmental protection',
      ];

      // Take first 5 keywords to avoid URL length issues
      // You can adjust this number based on what works with the API
      final query = keywords.take(5).join(',').replaceAll(' ', '%20');

      debugPrint('Using query: $query');

      final url = Uri.parse(
        'https://newsdata.io/api/1/news?apikey=$apiKey&q=$query&language=en',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (!mounted) return;
        setState(() {
          articles = data['results'] ?? [];
          isLoading = false;
        });
      } else {
        throw Exception(
          'API request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching news: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Failed to load news. Please try again.';
      });
    }
  }

  Future<void> _loadLikedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final liked = prefs.getStringList('likedArticles') ?? [];
    setState(() {
      likedArticles = liked.map((e) => json.decode(e)).toList();
    });
  }

  Future<void> _toggleLikeArticle(Map<String, dynamic> article) async {
    final prefs = await SharedPreferences.getInstance();
    final articleString = json.encode(article);
    final isLiked = likedArticles.any((a) => a['title'] == article['title']);

    if (isLiked) {
      likedArticles.removeWhere((a) => a['title'] == article['title']);
    } else {
      likedArticles.add(article);
    }

    await prefs.setStringList(
      'likedArticles',
      likedArticles.map((a) => json.encode(a)).toList(),
    );

    setState(() {});
  }

  void _navigateToLikedArticles() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LikedArticlesScreen(
          likedArticles: likedArticles,
          onArticleRemoved: (article) {
            _toggleLikeArticle(article);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Environmental News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: _navigateToLikedArticles,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchNews,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Failed to load news'),
            TextButton(onPressed: _fetchNews, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (articles.isEmpty) {
      return const Center(child: Text('No articles found'));
    }

    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        final isLiked = likedArticles.any(
          (a) => a['title'] == article['title'],
        );

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Text(
              article['title'] ?? 'No title',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article['description'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(article['description']),
                  ),
                if (article['source_id'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Source: ${article['source_id']}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : null,
              ),
              onPressed: () => _toggleLikeArticle(article),
            ),
            onTap: () {
              if (article['link'] != null) {
                _launchURL(article['link']);
              }
            },
          ),
        );
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }
}

class LikedArticlesScreen extends StatelessWidget {
  final List<dynamic> likedArticles;
  final Function(Map<String, dynamic>) onArticleRemoved;

  const LikedArticlesScreen({
    super.key,
    required this.likedArticles,
    required this.onArticleRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liked Articles')),
      body: likedArticles.isEmpty
          ? const Center(child: Text('No liked articles yet'))
          : ListView.builder(
              itemCount: likedArticles.length,
              itemBuilder: (context, index) {
                final article = likedArticles[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      article['title'] ?? 'No title',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article['description'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(article['description']),
                          ),
                        if (article['source_id'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Source: ${article['source_id']}',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => onArticleRemoved(article),
                    ),
                    onTap: () {
                      if (article['link'] != null) {
                        _launchURL(context, article['link']);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

  void _launchURL(BuildContext context, String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
    }
  }
}
