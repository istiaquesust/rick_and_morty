import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty/core/local/local_db.dart';
import 'package:rick_and_morty/custom_widgets/custom_text.dart';
import 'package:rick_and_morty/features/detail/controller/detail_provider.dart';
import 'package:rick_and_morty/features/favorite/controller/favorite_provider.dart';
import 'package:rick_and_morty/features/home/controller/characters_list_provider.dart';
import 'package:rick_and_morty/util/constants.dart';

class DetailScreen extends StatefulWidget {
  final int id;
  const DetailScreen({super.key, required this.id});
  @override
  State<DetailScreen> createState() {
    return _DetailScreen();
  }
}

class _DetailScreen extends State<DetailScreen> {
  final _containerColor = Color.fromRGBO(40, 40, 40, 0.55);
  bool _isFavorite = false;

  final LocalDb _db = LocalDb();

  // 1. Initialize controllers with current character data
  final nameController = TextEditingController();
  final statusController = TextEditingController();
  final speciesController = TextEditingController();
  final genderController = TextEditingController();
  final typeController = TextEditingController();
  final originController = TextEditingController();
  final locationController = TextEditingController();

  Map _character = {};

  @override
  void initState() {
    super.initState();
    // Check the status as soon as the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DetailProvider>().checkIsFavoriteProvider(
        id: _character['id'],
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 1. Get the data
    _isFavorite = context.watch<DetailProvider>().isfavorite;
    _character = context.watch<CharactersListProvider>().getCharacterById(
      widget.id,
    );

    // 2. GUARD: Only update controllers if the text is actually different.
    // This prevents the "setState during build" crash.
    if (nameController.text != _character['name']) {
      nameController.text = _character['name'] ?? '';
      statusController.text = _character['status'] ?? '';
      speciesController.text = _character['species'] ?? '';
      genderController.text = _character['gender'] ?? '';
      typeController.text = _character['type'] ?? '';

      // Safe nesting check
      originController.text = (_character['origin']['name'] ?? '');

      locationController.text = (_character['location']['name'] ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        // This tells Android: "My background is dark, use light icons"
        statusBarIconBrightness: Brightness.light,
        // This tells iOS: "My background is dark, use light icons"
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Hero Image (Optional: adds a smooth transition animation)
              Stack(
                children: [
                  // 1. The Main Character Image
                  CachedNetworkImage(
                    imageUrl: _character['image'],
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),

                  // 2. The Back Button (TOP-LEFT)
                  Positioned(
                    top:
                        MediaQuery.of(context).padding.top +
                        10, // Adjust for status bar
                    left: 10,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(
                        12,
                      ), // Match the container shape
                      child: Container(
                        padding: const EdgeInsets.all(
                          10,
                        ), // Equal padding for the icon
                        decoration: BoxDecoration(
                          color: _containerColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back, // A cleaner, modern back icon
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  // The Status Overlay (Positioned Bottom-Left)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _containerColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: _status(), // Your status method from before
                    ),
                  ),
                  // The Center-Right Action Buttons
                  Positioned(
                    right: 10,
                    top: 0,
                    bottom: 0, // This allows us to use Center alignment
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // --- FAVORITE BUTTON ---
                          _buildActionButton(
                            icon: _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,

                            onTap: () {
                              context
                                  .read<DetailProvider>()
                                  .saveOrDeleteFavoriteProvider(
                                    id: _character['id'],
                                    favoriteFlag: !_isFavorite,
                                  );
                              context
                                  .read<FavoriteProvider>()
                                  .initiateFavoriteCharctersListProvider();
                            },
                          ),

                          const SizedBox(height: 20), // Gap between buttons
                          // --- EDIT BUTTON ---
                          _buildActionButton(
                            icon: Icons.edit_outlined,
                            onTap: () {
                              // Your Edit Logic
                              _showEditDialog(context, _character);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CustomText(
                        text: _character['name'],
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Displaying API details like Status, Species, etc.
                    _buildDetailRow("Species", _character['species']),
                    _buildDetailRow("Gender", _character['gender']),
                    _buildDetailRow("Type", _character['type']),
                    _buildDetailRow("Origin", _character['origin']['name']),
                    _buildDetailRow("Location", _character['location']['name']),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      splashColor: color6,
      highlightColor: color6,
      onTap: onTap,
      //borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(
          8,
        ), // Slightly larger for better touch target
        decoration: BoxDecoration(
          color: _containerColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: (icon == Icons.favorite && _isFavorite)
              ? color6
              : Colors.white,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(text: label, color: color4, fontSize: 12),
            CustomText(
              text: value.isNotEmpty ? value : 'Not specified',
              fontSize: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _status() {
    // 1. Determine the color logic
    Color statusColor;
    String status = (_character['status'] ?? 'unknown').toLowerCase();

    if (status == 'alive') {
      statusColor = Colors.green;
    } else if (status == 'dead') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.yellowAccent;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 2. The Small Circle Icon
        Icon(Icons.circle, size: 12, color: statusColor),

        const SizedBox(width: 5),

        // 3. The Status Text (Using your Custom Text logic)
        CustomText(
          text: _character['status'],
          fontSize: 14,
          color: statusColor, // Keep text white so the dot is the focus
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, Map character) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromRGBO(30, 30, 30, 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: CustomText(
          text: "Edit Character",
          fontSize: 22,
          color: Colors.yellowAccent,
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildEditField("Name", nameController),
                _buildEditField("Status", statusController),
                _buildEditField("Species", speciesController),
                _buildEditField("Gender", genderController),
                _buildEditField("Type", typeController),
                _buildEditField("Origin", originController),
                _buildEditField("Location", locationController),
              ],
            ),
          ),
        ),
        actions: [
          // CANCEL BUTTON
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: CustomText(
              text: "Cancel",
              fontSize: 16,
              color: Colors.redAccent,
            ),
          ),
          // CONFIRM BUTTON
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // Logic to save these values back to your LocalDb
              _editCharacter();
              Navigator.pop(context);
            },
            child: CustomText(
              text: "Confirm",
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Helper for the TextFields
  Widget _buildEditField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontFamily: 'LuckiestGuy'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  //methods

  void _editCharacter() {
    // 1. Save to Local DB
    // Assuming these controllers were defined in your dialog
    _db.saveEditedCharacter(
      id: _character['id'],
      name: nameController.text,
      status: statusController.text,
      species: speciesController.text,
      gender: genderController.text,
      type: typeController.text,
      origin: originController.text,
      location: locationController.text,
    );

    // 2. Refresh the UI via Provider

    context.read<CharactersListProvider>().modifyCharacterAfterEdit(
      _character['id'],
    );
    context.read<FavoriteProvider>().modifyCharacterAfterEdit(_character['id']);

    // 3. Close the Dialog
    //Navigator.pop(context);

    // 4. Show the "Saved Successfully" Banner
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        padding: const EdgeInsets.all(20),
        content: CustomText(
          text: "Character saved successfully!",
          fontSize: 16,
          color: Colors.white,
        ),
        leading: const Icon(Icons.check_circle, color: Colors.greenAccent),
        backgroundColor: const Color.fromRGBO(30, 30, 30, 1.0),
        actions: [
          TextButton(
            onPressed: () =>
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: CustomText(
              text: "DISMISS",
              fontSize: 14,
              color: Colors.yellowAccent,
            ),
          ),
        ],
      ),
    );

    // Automatically hide the banner after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    });
  }
}
