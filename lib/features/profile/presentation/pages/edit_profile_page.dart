import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Cinemate/features/auth/presentation/components/my_text_field.dart';
import 'package:Cinemate/features/profile/domain/entities/profile_user.dart';
import 'package:Cinemate/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:Cinemate/features/profile/presentation/cubits/profile_states.dart';
import 'package:Cinemate/themes/font_theme.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? imagePickedFile;
  final bioTextController = TextEditingController();
  final nameTextController = TextEditingController();
  final businessTextController = TextEditingController();
  final emailTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Kullanıcı bilgilerini controller'lara ata
    nameTextController.text = widget.user.name;
    emailTextController.text = widget.user.email;
    bioTextController.text = widget.user.bio ?? '';
    businessTextController.text = widget.user.business ?? "";
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? selectedImage = await _picker.pickImage(source: source);
      if (selectedImage != null) {
        setState(() => imagePickedFile = selectedImage);
      }
    } catch (e) {
      debugPrint("Resim seçerken hata oluştu: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Resim seçerken hata: ${e.toString()}")),
      );
    }
  }

  void updateProfile() {
    final profileCubit = context.read<ProfileCubit>();
    final String newBusiness = selectedPlatform != null
        ? '${platforms[selectedPlatform]}${businessTextController.text.replaceAll(platforms[selectedPlatform]!, '')}'
        : businessTextController.text.trim();

    try{
      profileCubit.updateProfile(
        uid: widget.user.uid,
        newName: nameTextController.text.trim(),
        newEmail: emailTextController.text.trim(),
        newBio: bioTextController.text.trim(),
        newBusiness: newBusiness.isNotEmpty ? newBusiness : null,
        imageMobilePath: imagePickedFile?.path,
      ).then((_) {
        // Başarılı olursa true döndür
        if (mounted) { // <-- Bu kontrol kritik
          Navigator.of(context).maybePop();        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: ${e.toString()}")),
        );
      }
    }
  }

  String? selectedPlatform;
  final Map<String, String> platforms = {
    'Instagram': 'https://instagram.com/',
    'Facebook': 'https://facebook.com/',
    'Tiktok': 'https://tiktok.com/',
  };
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {

        if (state is ProfileLoaded) Navigator.pop(context);
        if (state is ProfileError) {
          print(state.message)
;        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Profili Düzenle"),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profil Fotoğrafı
                _buildProfileImage(),
                const SizedBox(height: 30),
                
                // İsim Alanı
                _buildLabeledTextField(
                  label: "İsim",
                  controller: nameTextController,
                  hintText: "Adınızı girin",
                ),
                const SizedBox(height: 20),
                
                // Email Alanı
                _buildLabeledTextField(
                  label: "Email",
                  controller: emailTextController,
                  hintText: "Email adresinizi girin",
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                
                // Bio Alanı
                _buildLabeledTextField(
                  label: "Hakkımda",
                  controller: bioTextController,
                  hintText: "Kendinizden bahsedin (isteğe bağlı)",
                  maxLines: 3,
                ),
                const SizedBox(height: 20),



                // TextField kısmı
                buildSocialLinkField()
              ],
            ),
          ),
          // Sabit Güncelle Butonu
          bottomNavigationBar: _buildUpdateButton(state),
        );
      },
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6.0),
          child: Text(
              label,
              style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.primary)
          ),
        ),
        const SizedBox(height: 8),
        MyTextField(
          controller: controller,
          hintText: hintText,
          obscureText: false,

        ),
      ],
    );
  }


  Widget buildSocialLinkField() {
    final Map<String, String> platforms = {
      'Instagram': 'https://instagram.com/',
      'Facebook': 'https://facebook.com/',
      'Tiktok': 'https://tiktok.com/',
    };

    final Map<String, String> platformIcons = {
      'Instagram': 'assets/icons/instagram.png',
      'Facebook': 'assets/icons/facebook.png',
      'Tiktok': 'assets/icons/tiktok.png',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sosyal Medya Hesabın",
          style: AppTextStyles.bold.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // TextField
            Expanded(
              child: MyTextField(
                controller: businessTextController,
                hintText: selectedPlatform == null
                    ? "Kullanıcı adınızı girin"
                    : platforms[selectedPlatform]!,
                obscureText: false,
              ),
            ),
            const SizedBox(width: 8),
            // Platform Seçim Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                //border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(14),
                color: Theme.of(context).colorScheme.tertiary,

              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedPlatform,
                  hint: Text("Seç",style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.primary),),
                  items: platforms.keys.map((platform) {
                    return DropdownMenuItem<String>(
                      value: platform,
                      child: Row(
                        children: [
                          Image.asset(
                            platformIcons[platform]!,
                            width: 20,
                            height: 20,
                          ),

                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPlatform = value;
                      businessTextController.text = platforms[value]!;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.hardEdge,
            child: imagePickedFile != null
                ? Image.file(File(imagePickedFile!.path), fit: BoxFit.cover)
                : CachedNetworkImage(
                    imageUrl: widget.user.profileImageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Center(child: CircularProgressIndicator()),
                    errorWidget: (_, __, ___) => Icon(Icons.person, size: 60),
                  ),
          ),
          FloatingActionButton(
            onPressed: () => showImagePickerDialog(),
            mini: true,
            child: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
    );
  }



  Widget _buildUpdateButton(ProfileState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: state is ProfileLoading
            ? null
            : () async {
           updateProfile(); // profili güncelle
          /*if (mounted) {
            Navigator.of(context).pop(true); // Güncelleme başarılı olduğunda geri dön
          }*/
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: state is ProfileLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          "Profili Güncelle",
          style: AppTextStyles.semiBold.copyWith(
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
    );
  }


  void showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galeriden Seç"),
              onTap: () {
                pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text("Kamera ile Çek"),
              onTap: () {
                pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}