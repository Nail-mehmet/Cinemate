/*import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:Cinemate/themes/font_theme.dart';

class PremiumSubscriptionPage extends StatefulWidget {
  const PremiumSubscriptionPage({super.key});

  @override
  State<PremiumSubscriptionPage> createState() =>
      _PremiumSubscriptionPageState();
}

class _PremiumSubscriptionPageState extends State<PremiumSubscriptionPage> {
  String selectedPlan = 'monthly';
  late String backgroundImage;

  @override
  void initState() {
    super.initState();
    final List<String> images = [
      'assets/images/premium.png',
      'assets/images/premium1.png',
      'assets/images/premium2.png'
    ];
    backgroundImage = images[Random().nextInt(images.length)];
  }

  void selectPlan(String plan) {
    setState(() {
      selectedPlan = plan;
    });
  }

  void onContinue() async {
    // Satın alma işlemleri burada olacak
  }

  void onRestore() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Satın alımı geri yükle tıklandı")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka Plan Resmi
          SizedBox.expand(
            child: Image.asset(
              backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          // Saydam Arka Plan
          Container(color: Colors.black.withOpacity(0.2)),
          // İçerik
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Geri Dön Butonu
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white38),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(FontAwesomeIcons.xmark,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Sınırları Kaldır",
                      style: AppTextStyles.bold.copyWith(
                        fontSize: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Özellikler
                  const FeatureRow(text: "Topluluklara Katıl"),
                  const FeatureRow(text: "Üçlemeneni paylaş"),
                  const FeatureRow(
                      text: "Aynı üçlemeye sahip kullanıclarlı bul"),
                  const FeatureRow(text: "Haftalık Yarışmalara katıl"),
                  const FeatureRow(text: "Premium etiketi kazan"),
                  const FeatureRow(
                      text: "Telefonuna filmlerlerden alıntı gönderelim"),

                  const SizedBox(height: 10),

                  // Abonelik Seçenekleri
                  SubscriptionOption(
                    title: "Aylık",
                    price: "\₺29 / Ay",
                    isPopular: true,
                    isSelected: selectedPlan == 'monthly',
                    onTap: () => selectPlan('monthly'),
                  ),
                  const SizedBox(height: 16),
                  SubscriptionOption(
                    title: "Yıllık (Avantajlı)",
                    price: "\₺249 / Yıl",
                    isPopular: false,
                    isSelected: selectedPlan == 'yearly',
                    onTap: () => selectPlan('yearly'),
                  ),

                  const SizedBox(height: 20),

                  // Devam Et Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onContinue,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.transparent),
                        shadowColor: MaterialStateProperty.all(Colors.transparent),
                        padding: MaterialStateProperty.all(
                            const EdgeInsets.symmetric(vertical: 1)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        overlayColor: MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Color(0xFF003366); // Darker blue when pressed
                            }
                            return null;
                          },
                        ),
                      ),
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF001F3F), Color(0xFF004080)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Container(
                          width: double.infinity, // Genişliği burada ayarladık
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          child: const Center(
                            child: Text(
                              "Devam Et",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )

                  ),

                  const SizedBox(height: 12),

                  // Satın Alımı Geri Yükle
                  Center(
                    child: TextButton(
                      onPressed: onRestore,
                      child: Text(
                        "Satın alımı geri yükle",
                        style: TextStyle(
                          color: Colors.white70,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class FeatureRow extends StatelessWidget {
  final String text;
  const FeatureRow({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.lightBlueAccent, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.medium.copyWith(fontSize: 15,color: Colors.white70),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionOption extends StatelessWidget {
  final String title;
  final String price;
  final bool isPopular;
  final bool isSelected;
  final VoidCallback onTap;

  const SubscriptionOption({
    super.key,
    required this.title,
    required this.price,
    required this.isPopular,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none, // Bu sayede etiket taşmasına izin veriyoruz
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade50 : Colors.white,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isSelected ? Colors.blue.shade800 : Colors.black,
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.blue.shade800 : Colors.black,
                  ),
                ),
              ],
            ),
          ),
          if (isPopular)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF001F3F), Color(0xFF004080)],

                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  "POPÜLER",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
*/