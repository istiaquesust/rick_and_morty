import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty/custom_widgets/custom_text.dart';
import 'package:rick_and_morty/features/favorite/controller/favorite_provider.dart';
import 'package:rick_and_morty/features/favorite_detail/view/favorite_detail.dart';
import 'package:rick_and_morty/util/constants.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});
  @override
  State<FavoriteScreen> createState() {
    return _FavoriteScreen();
  }
}

class _FavoriteScreen extends State<FavoriteScreen> {
  List _content = [];

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      context.read<FavoriteProvider>().initiateFavoriteCharctersListProvider();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _content = context.watch<FavoriteProvider>().favoriteList;
    return Scaffold(
      backgroundColor: color1,
      body: SafeArea(
        child: _content.isNotEmpty
            ? Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      //controller: _scrollController,
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
                ],
              )
            : _noFavorite(),
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
              builder: (context) => FavoriteDetail(id: character['id']),
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

  Widget _noFavorite() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Optional: Add a cartoon-style icon or image here
            Icon(Icons.heart_broken_rounded, size: 80, color: color4),
            const SizedBox(height: 20),

            // 3. Your Custom Text with the Cartoon Font
            CustomText(
              text: "No favorite character added yet",
              fontSize: 22,
              textAlign: TextAlign.center,
              color: color4,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }

  //methods
}
