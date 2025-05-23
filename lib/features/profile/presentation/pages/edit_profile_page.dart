/*import 'dart:io';
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
  final emailTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Kullanıcı bilgilerini controller'lara ata
    nameTextController.text = widget.user.name;
    emailTextController.text = widget.user.email;
    bioTextController.text = widget.user.bio ?? '';
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
    final String uid = widget.user.uid;
    final String? imagePath = imagePickedFile?.path;
    final String newName = nameTextController.text.trim();
    final String newEmail = emailTextController.text.trim();
    final String newBio = bioTextController.text.trim();

    if (newName.isEmpty || newEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("İsim ve email boş olamaz")),
      );
      return;
    }

    profileCubit.updateProfile(
      uid: uid,
      newName: newName,
      newEmail: newEmail,
      newBio: newBio.isNotEmpty ? newBio : null,
      imageMobilePath: imagePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) Navigator.pop(context);
        /*if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.)),
          );
        }*/
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
                const SizedBox(height: 40),
              ],
            ),
          ),
          // Sabit Güncelle Butonu
          bottomNavigationBar: _buildUpdateButton(state),
        );
      },
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
                    imageUrl: widget.user.profileImageUrl,
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

  Widget _buildUpdateButton(ProfileState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: state is ProfileLoading ? null : updateProfile,
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
                style: AppTextStyles.semiBold.copyWith(color: Theme.of(context).colorScheme.tertiary),
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
}*/