import 'package:flutter/material.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(
            'Yardım Merkezi',
            style: AppTextStyles.bold,
          ),
          centerTitle: true,
          bottom: TabBar(
            labelStyle: AppTextStyles.bold,
            unselectedLabelStyle: AppTextStyles.bold,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.secondary,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: [
              Tab(text: 'SSS'),
              Tab(text: 'Bize Ulaşın'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FAQTab(),
            ContactTab(),
          ],
        ),
      ),
    );
  }
}

// SSS Sekmesi
class FAQTab extends StatelessWidget {
  const FAQTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildQuestionTile(
          question: 'Bu sosyal medya uygulaması ücretsiz mi?',
          answer: 'Evet, uygulamamız tamamen ücretsizdir.',          context: context

        ),
        _buildQuestionTile(
          question: 'Film beğenme özelliği nasıl çalışıyor?',
          answer: 'Filmleri beğenmek için film detay sayfasındaki “Beğen” butonuna dokunun. Beğendiğiniz filmler profilinizde saklanır.',          context: context

        ),
        _buildQuestionTile(
          question: 'Yeni özelliklerden nasıl haberdar olabilirim?',
          answer: 'Resmi sosyal medya hesaplarımızı takip edin.',          context: context

        ),
        _buildQuestionTile(
          question: 'Topluluklara nasıl katılabilirim?',
          answer: 'Ana menüden “Topluluklar” bölümüne gidin ve ilginizi çeken gruplara katılın.',          context: context

        ),
        _buildQuestionTile(
          question: 'Müşteri desteğiyle nasıl iletişime geçebilirim?',
          answer: 'Ayarlar menüsünden “Bize Ulaşın” bölümüne dokunun veya cinematetr@gmail.com adresine e-posta gönderin.',          context: context

        ),
        _buildQuestionTile(
          question: 'Teknik sorunlarla karşılaşırsam ne yapmalıyım?',
          answer: 'Uygulamayı yeniden başlatmayı veya en son sürüme güncellemeyi deneyin. Sorun devam ederse destek ekibine ulaşın.',
            context: context

        ),
        _buildQuestionTile(
          question: 'Uygulamaya nasıl yorum ekleyebilirim?',
          answer: 'Uygulamanın mağaza sayfasına gidin ve “Yorum Yaz” seçeneğine dokunun.',
          context: context
        ),
      ],
    );
  }

  static Widget _buildQuestionTile({
    required BuildContext context,
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: Text(
          question,
          style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              answer,
              style: AppTextStyles.bold.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

}


// Contact Us Tab
class ContactTab extends StatelessWidget {
  const ContactTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
       /* _buildContactCard(
          icon: Icons.support_agent,
          label: 'Müşteri Hizmetleri',
          onTap: () {},
        ),*/
        _buildContactCard(
          icon: Icons.wallet,
          label: '(534) 650 55 89',
          onTap: () => _launchUrl('tel:5346505589'),
        ),
        _buildContactCard(
          icon: Icons.language,
          label: 'Website',
          onTap: () => _launchUrl('https://cinemate.my.canva.site/ke-fet-be-en-efsane-lemeleri-olu-tur'),
        ),
        _buildContactCard(
          icon: Icons.tiktok,
          label: 'Tiktok',
          onTap: () => _launchUrl('https://www.tiktok.com/@cinemate6'),
        ),
        _buildContactCard(
          icon: Icons.reddit,
          label: 'Reddit',
          onTap: () => _launchUrl('https://www.reddit.com/r/Cinemate/?type=TEXT'),
        ),
        _buildContactCard(
          icon: Icons.camera_alt,
          label: 'Instagram',
          onTap: () => _launchUrl('https://www.instagram.com/cinematetr/'),
        ),
      ],
    );
  }

  static Widget _buildContactCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.blueAccent),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  static Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}

