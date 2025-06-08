import 'package:Cinemate/features/premium/pages/subscriptions_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumsPage extends StatefulWidget {
  final bool isPremium;
  const PremiumsPage({super.key, required this.isPremium});

  @override
  State<PremiumsPage> createState() => _PremiumsPageState();
}

class _PremiumsPageState extends State<PremiumsPage> with SingleTickerProviderStateMixin {
  final TextEditingController _storyController = TextEditingController();
  bool hasSubmitted = false;
  bool isLoading = true;
  String title = '';
  String story = '';
  String award = '';
  int membersCount = 0;
  final String premiumDocId = "weeklyStory";
  Duration remainingTime = Duration.zero;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeOut,
    ));
    _fetchData();
    _calculateRemainingTime();
    /*if (!widget.isPremium) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(seconds: 1), () {
          _showPremiumRequiredDialog();
        });
      });}*/
  }


  void _calculateRemainingTime() {
    final now = DateTime.now();
    // Bu haftanın Pazar 20:00'ini hesapla
    final nextSunday = now.weekday == 7
        ? DateTime(now.year, now.month, now.day, 20, 0)
        : DateTime(now.year, now.month, now.day + (7 - now.weekday), 20, 0);

    setState(() {
      remainingTime = nextSunday.difference(now);
    });
  }
  final supabase = Supabase.instance.client;


  Future<void> _fetchData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final contestData = await supabase
        .from('premium_contests')
        .select()
        .eq('id', premiumDocId)
        .single();

    final participantData = await supabase
        .from('premium_participants')
        .select()
        .eq('contest_id', premiumDocId)
        .eq('user_id', user.id);

    setState(() {
      title = contestData['title'] ?? '';
      story = contestData['description'] ?? '';
      award = contestData['award'] ?? '';
      membersCount = contestData['members_count'] ?? 0;
      hasSubmitted = participantData.isNotEmpty;
      isLoading = false;
    });
  }

  Future<void> _submitStory() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final text = _storyController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen bir metin girin.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await supabase.from('premium_participants').insert({
        'contest_id': premiumDocId,
        'user_id': user.id,
        'text': text,
      });

      setState(() {
        hasSubmitted = true;
        _storyController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Hikayen gönderildi!"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _formatDuration(Duration d) {
    return "${d.inDays}g ${d.inHours.remainder(24)}s ${d.inMinutes.remainder(60)}d";
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }
  /*
  void _showPremiumRequiredDialog() {
    // Animasyonu başlat
    _shakeController.forward(from: 0);

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value * (1 - (_shakeAnimation.value / 10)), 0),
            child: Transform.rotate(
              angle: _shakeAnimation.value * 0.01,
              child: child,
            ),
          );
        },
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 60,
                  color: Colors.amber,
                ),
                const SizedBox(height: 20),
                Text(
                  "Premium’a Katıl",
                  style: AppTextStyles.bold.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  "Sadece Premium üyeler bu özel yarışmaya katılabilir!\nAyrıcalıkları kaçırma, hemen yükselt!",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regular.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  height: 40, // Sabit yükseklik
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Future.delayed(Duration.zero, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PremiumSubscriptionPage(),
                          ),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: Text("Premium Ol", style: AppTextStyles.bold.copyWith(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40, // Sabit yükseklik
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).maybePop();
                    },
                    child: const Text("Sonra"),
                  ),
                ),
              ],
            ),

          ),
        ),
      ),
    );
  }


*/
  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: colors.primary,
          ),
        ),
      );
    }

    Widget _buildInfoItem({required IconData icon, required Color color, required String text}) {
      return Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.medium.copyWith(color: color, fontSize: 18),
          ),
        ],
      );
    }

    Widget _buildVerticalSeparator() {
      return Container(
        height: 24,
        width: 1,
        color: Colors.grey.shade300,
        margin: const EdgeInsets.symmetric(horizontal: 12),
      );
    }



    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Haftalık Film Yarışması",
          style: AppTextStyles.bold.copyWith(fontSize: 20)
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Katılımcı sayısı ve bilgiler
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInfoItem(
                      icon: Icons.people_alt_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      text: membersCount.toString(),
                    ),
                    _buildVerticalSeparator(),
                    _buildInfoItem(
                      icon: Icons.timer_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      text: _formatDuration(remainingTime),
                    ),
                    _buildVerticalSeparator(),
                    _buildInfoItem(
                      icon: Icons.emoji_events_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      text: "$award TL",
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Ana hikaye bölümü
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.outline.withOpacity(0.4),
                  width: 4
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "🎬 $title",
                    style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.primary, fontSize: 20)
                  ),
                  const SizedBox(height: 12),
                  Text(
                    story,
                    style: AppTextStyles.regular.copyWith(color: Theme.of(context).colorScheme.primary)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Katılım bölümü
            Text(
              "Hikayeyi Sen Tamamla:",
              style: AppTextStyles.bold.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary)
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _storyController,
                maxLines: 8,
                minLines: 5,
                enabled: !hasSubmitted,
                decoration: InputDecoration(
                  hintText: hasSubmitted
                      ? "Bu hafta zaten katıldınız. 🎉"
                      : "Hikayeyi buradan devam ettir...",
                  hintStyle: AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.primary),
                  filled: true,
                  fillColor: hasSubmitted
                      ? colors.surfaceVariant.withOpacity(0.3)
                      : colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: TextStyle(
                  fontSize: 15,
                  color: colors.onSurface,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Gönder butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ( hasSubmitted || isLoading)
                    ? null
                    : _submitStory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasSubmitted
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.tertiary, // Premium değilse daha soluk gözüksün
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Hikayemi Gönder"
                          , // Farklı mesaj gösterebilirsiniz
                      style: AppTextStyles.bold
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Geçmiş kazananlar
            Center(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: colors.primary,
                  ),
                  children: [
                    TextSpan(text: "Kazananlar her Pazar akşamı ",style: AppTextStyles.italic),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: GestureDetector(
                        onTap: () async {
                          final url = Uri.parse('https://www.instagram.com/cinematetr/');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Text(
                          "@cinematetr",
                          style: AppTextStyles.bold,
                        ),
                      ),
                    ),
                    TextSpan(text: " Instagram hesabında paylaşılır.",style: AppTextStyles.italic),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),

          ],
        ),
      ),
    );
  }
}