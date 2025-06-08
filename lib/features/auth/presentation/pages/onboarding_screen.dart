import 'package:flutter/material.dart';
import 'package:Cinemate/app.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
  {
    'title': 'CINEMATE',
    'subtitle': 'Filmleri Keşfet, Listene Ekle',
    'description':
        'Beğendiğin filmleri kolayca bul, izlediklerini işaretle, izlemek istediklerini kaydet.',
    'color': const Color(0xFF0D3B66),
    'image': 'assets/onboarding/1.png',
  },
  {
    'title': 'CINEMATE',
    'subtitle': 'Topluluklara Katıl',
    'description':
        'Korku, bilim kurgu, romantik veya belgesel… Sana uygun topluluklarda kendini bul.',
    'color': Color(0xFF0D3B66),
    'image': 'assets/onboarding/2.png',
  },
  {
    'title': 'CINEMATE',
    'subtitle': 'Düşüncelerini Paylaş, Gündemi Belirle',
    'description':
        'İzlediğin film hakkında gönderi oluştur, sahneleri analiz et, teorilerini yaz ve diğer sinemaseverlerle tartışmaya başla.',
    'color': Color(0xFF0D3B66),
    'image': 'assets/onboarding/3.png',
  },
  {
    'title': 'CINEMATE',
    'subtitle': 'Yorum Yap, Tartışmalara Katıl',
    'description':
        'Her film için yorum yapabilir, topluluk içinde düşüncelerini paylaşabilirsin.',
    'color': Color(0xFF0D3B66),
    'image': 'assets/onboarding/4.png',
  },
  {
    'title': 'CINEMATE',
    'subtitle': 'En Sevdiğin Üçlemeyi Oluştur',
    'description':
        'Favori üç filmini seç, profilinde sergile ve diğerlerinin listelerine göz at.',
    'color': Color(0xFF0D3B66),
    'image': 'assets/onboarding/5.png',
  },
    {
      'title': 'CINEMATE',
      'subtitle': 'Senin Gibi Film Tutkunlarıyla Tanış',
      'description':
      'Beğenilerine göre eşleş, yeni arkadaşlıklar kur ve film sohbetlerinin tadını çıkar.',
      'color': Color(0xFF0D3B66),
      'image': 'assets/onboarding/6.png',
    },
];


  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  }

  @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: _pages[_currentPage]['color'],
    body: Stack(
      children: [
        // Sabit ORTA container
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.15,
          left: MediaQuery.of(context).size.height * 0.045,
          right: MediaQuery.of(context).size.height * 0.045,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        ),

        // Sabit Cinemate logosu (PageView dışında)
        Positioned(
          top: MediaQuery.of(context).size.height * 0.08, // Aynı konumu koru
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(
              "assets/images/cinemate.png",
              height: 40, // Uygun bir yükseklik ayarla
            ),
          ),
        ),

        // PageView içerik (logoyu çıkardık)
        PageView.builder(
          controller: _pageController,
          itemCount: _pages.length,
          onPageChanged: (index) {
            setState(() => _currentPage = index);
          },
          itemBuilder: (context, index) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Resim - Asset kullanımı
                Container(
                  height: 450,
                  width: 300,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16), // isteğe bağlı
                     child: Image.asset(
                      _pages[index]['image'],
                      fit: BoxFit.contain, // resim taşmadan sığsın
                    ),
                  ),
                ),

                //const SizedBox(height: 20),

                // İçerik Container'ı (logoyu çıkardık)
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
                  child: Column(
                    children: [
                      Text(
                        _pages[index]['subtitle'],
                        style: AppTextStyles.bold.copyWith(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 5),

                      // Açıklama
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          _pages[index]['description'],
                          textAlign: TextAlign.center,
                          style: AppTextStyles.medium.copyWith(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        // Dot indicator
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.10,
          left: 0,
          right: 0,
          child: Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: _pages.length,
              effect: SlideEffect(
                dotHeight: 6,
                dotWidth: 20,
                spacing: 8,
                dotColor: Colors.black.withOpacity(0.2),
                activeDotColor: Colors.black,
                type: SlideType.slideUnder,
              ),
            ),
          ),
        ),

        // Get Started butonu (sadece son sayfada)
        if (_currentPage == _pages.length - 1)
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  _finishOnboarding();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "Şimdi Başla",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

        // Skip butonu (son sayfa hariç)
        if (_currentPage != _pages.length - 1)
          Positioned(
            bottom: 60,
            left: 30,
            child: TextButton(
              onPressed: () {
                _pageController.animateToPage(
                  _pages.length - 1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              },
              child: const Text(
                'Atla',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

}
