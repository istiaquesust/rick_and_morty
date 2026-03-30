import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty/custom_widgets/custom_text.dart';
import 'package:rick_and_morty/features/detail/view/detail_screen.dart';
import 'package:rick_and_morty/features/home/controller/characters_list_provider.dart';
import 'package:rick_and_morty/util/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() {
    return _HomeScreen();
  }
}

class _HomeScreen extends State<HomeScreen> {
  final ScrollController _scrollController =
      ScrollController(); // Added for Load More

  int page = 1;
  List _content = [];
  bool _isInitialLoading = false;
  bool _isMoreLoading = false;
  int _totalPages = 0;
  int _page = 1;

  @override
  void initState() {
    super.initState();

    // Tells Flutter: "Do this as soon as the first build is done"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialSetUp('initialLoading');
    });
    // Listen to scroll position
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isInitialLoading = context
        .watch<CharactersListProvider>()
        .isInitialLoading;
    _isMoreLoading = context.watch<CharactersListProvider>().isMoreLoading;
    _content = context.watch<CharactersListProvider>().content;
    _totalPages = context.watch<CharactersListProvider>().totalPages;
    _page = context.watch<CharactersListProvider>().page;
    return Scaffold(
      backgroundColor: color1,
      body: SafeArea(
        child: RefreshIndicator(
          color: color6,
          onRefresh: () => _initialSetUp('refreshLoading'),
          child: _isInitialLoading
              ? const Center(child: CircularProgressIndicator(color: color6))
              : _content.isNotEmpty
              ? Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(5),
                        //cacheExtent: 50,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 3,
                              mainAxisSpacing: 3,
                            ),
                        itemCount: _content.length,
                        itemBuilder: (context, index) {
                          final character = _content[index];
                          return _buildCharacterCard(character);
                        },
                      ),
                    ),
                    // Bottom Loader for Infinite Scroll
                    if (_isMoreLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: CircularProgressIndicator(color: color6),
                      ),
                  ],
                )
              : _noData(),
        ),
      ),
    );
  }

  Widget _buildCharacterCard(dynamic character) {
    return Card(
      color: color2,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navigate to details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(id: character['id']),
            ),
          );
        },
        splashColor: color1,
        highlightColor: color1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: character['image'],
                width: double.infinity,
                //height: double.infinity,
                fit: BoxFit.contain,
                memCacheWidth: 250,
                maxWidthDiskCache: 400,
                filterQuality: FilterQuality.low,
                placeholder: (context, url) => Container(color: color3),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(text: character['name'], fontSize: 11),
                  CustomText(
                    text: "${character['species']} - ${character['status']}",
                    fontSize: 9,
                    color: color4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noData() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Optional: Add a cartoon-style icon or image here
            Icon(Icons.search_off_rounded, size: 60, color: color4),
            const SizedBox(height: 20),

            // 3. Your Custom Text with the Cartoon Font
            CustomText(
              text: "No data found",
              fontSize: 22,
              textAlign: TextAlign.center,
              color: color4,
              overflow: TextOverflow.visible,
            ),
            SizedBox(height: 20),
            InkWell(
              onTap: () {
                // 1. Trigger your data fetch logic
                _initialSetUp('initialLoading');
              },
              borderRadius: BorderRadius.circular(25),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color2, // Matches your other buttons
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color4),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //methods

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // if already fetching data, not fetch data.
      if (!_isMoreLoading) {
        _loadMoreContent();
      }
    }
  }

  // Initial Fetch & Refresh
  Future<void> _initialSetUp(String loadingType) async {
    await context.read<CharactersListProvider>().updateContent(
      loagingType: loadingType,
    );
  }

  // Load More Logic
  Future<void> _loadMoreContent() async {
    if (_totalPages >= _page) {
      await context.read<CharactersListProvider>().updateContent(
        loagingType: 'moreLoading',
      );
    }
  }
}
