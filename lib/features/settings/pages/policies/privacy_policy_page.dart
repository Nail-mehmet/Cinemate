import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gizlilik Politikası'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Gizlilik Politikası',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Yürürlük Tarihi: 1 Ocak 2025\nSon Güncelleme: 1 Ocak 2025\n',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              '1. Topladığımız Bilgiler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Adınız, e-posta adresiniz, profil fotoğrafınız ve diğer hesap bilgileri gibi kişisel bilgileri toplayabiliriz. '
              'Ayrıca paylaştığınız içerikleri (gönderiler, medya) ve analiz ile performans izleme amacıyla kullanım ve cihaz verilerini toplarız.',
            ),
            SizedBox(height: 16),
            Text(
              '2. Bilgilerinizi Nasıl Kullanıyoruz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Verilerinizi, uygulama deneyimini sağlamak ve geliştirmek, içeriği kişiselleştirmek, güvenliği artırmak ve müşteri desteği sunmak için kullanırız. '
              'Ayrıca size önemli güncellemeler ve özellikler hakkında bildirimde bulunabiliriz.',
            ),
            SizedBox(height: 16),
            Text(
              '3. Bilgilerinizi Paylaşma',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Kişisel bilgilerinizi satmıyoruz. Uygulamanın çalışmasına yardımcı olan hizmet sağlayıcılarla sınırlı bilgileri paylaşabiliriz ve kanunen gerekli olduğunda yasal mercilerle paylaşabiliriz.',
            ),
            SizedBox(height: 16),
            Text(
              '4. Haklarınız ve Seçenekleriniz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Profil bilgilerinizi güncelleyebilir, içeriklerinizin görünürlüğünü kontrol edebilir, hesabınızı silebilir ve pazarlama iletişimlerini devre dışı bırakabilirsiniz.',
            ),
            SizedBox(height: 16),
            Text(
              '5. Güvenlik',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Verilerinizi korumak için makul önlemler alıyoruz, ancak %100 güvenlik garantisi veremeyiz. Lütfen güçlü parolalar kullanın ve herhangi bir sorunu bize bildirin.',
            ),
            SizedBox(height: 16),
            Text(
              '6. Çocukların Gizliliği',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Bu uygulama 13 yaş altındaki çocuklar için uygun değildir. Çocuklardan bilerek veri toplamıyoruz.',
            ),
            SizedBox(height: 16),
            Text(
              '7. Bu Politikanın Değişiklikleri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Bu politikayı zaman zaman güncelleyebiliriz. Önemli değişiklikler hakkında sizi bilgilendireceğiz.',
            ),
            SizedBox(height: 16),
            Text(
              '8. Bize Ulaşın',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Herhangi bir sorunuz varsa lütfen bize support@yourapp.com adresinden ulaşın.',
            ),
          ],
        ),
      ),
    );
  }
}
