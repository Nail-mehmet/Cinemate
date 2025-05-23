
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

  void selectPlan(String plan) {
    setState(() {
      selectedPlan = plan;
    });
  }

  void onContinue() async {
    /*final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kullanıcı giriş yapmamış")),
      );
      return;
    }

    final now = DateTime.now();
    final subscriptionEnd = selectedPlan == 'monthly'
        ? now.add(const Duration(days: 30))
        : now.add(const Duration(days: 365));

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'subscription': {
          'isPremium': true,
          'subscriptionType': selectedPlan,
          'subscriptionStart': Timestamp.fromDate(now),
          'subscriptionEnd': Timestamp.fromDate(subscriptionEnd),
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Abonelik başarıyla güncellendi: $selectedPlan"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hata oluştu: $e"),
        ),
      );
    }*/
  }


  void onRestore() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Restore purchase clicked"),
      ),
    );
    // Add restore logic here
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = const Color(0xFFFDF6F1);
    final Color primaryColor = const Color(0xFF567DF4);
    final Color secondaryColor = const Color(0xFF232323);

    return Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  children: [
                    // Top Banner Image
                    SizedBox(
                      height: 260,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/premium.jpg', // Your image path
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text("Sınırları Kaldırın — Premium’a Geçin!",
                              style: AppTextStyles.bold.copyWith(fontSize: 24)),

                          const SizedBox(height: 16),

                          // Features
                          const FeatureRow(text: "Topluluklara Katıl"),
                          const FeatureRow(text: "Üçlemeneni paylaş"),
                          const FeatureRow(
                              text: "Aynı üçlemeye sahip kullanıclarlı bul"),
                          const FeatureRow(text: "Haftalık Yarışmalara katıl"),
                          const FeatureRow(text: "Premium etiketi kazan"),
                          const FeatureRow(
                              text:
                                  "Telefonuna filmlerlerden alıntı gönderelim"),
                                  
                          const SizedBox(height: 32),

                          // Plans
                          SubscriptionOption(
                            title: "Aylık",
                            price: "\₺119 / Ay",
                            isPopular: true,
                            isSelected: selectedPlan == 'monthly',
                            onTap: () => selectPlan('monthly'),
                          ),
                          const SizedBox(height: 16),
                          SubscriptionOption(
                            title: "Yıllık (Avantajlı)",
                            price: "\₺319 / Yıl",
                            isPopular: false,
                            isSelected: selectedPlan == 'yearly',
                            onTap: () => selectPlan('yearly'),
                          ),

                          const SizedBox(height: 32),

                          // Continue Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: onContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF001F3F),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Devam Et",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Center(
                            child: TextButton(
                              onPressed: onRestore,
                              child: Text(
                                "Satın alımı geri yükle",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
                top: 60,
                left: 20,
                child: Container(
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white38),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(FontAwesomeIcons.xmark,
                          color: Colors.black),
                    ))),
          ],
        ));
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
          const Icon(Icons.check_circle, color: Colors.lightBlue, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.medium.copyWith(fontSize: 15),
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                    colors: [Color(0xFFFFA53E), Color(0xFFFF7643)],
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
