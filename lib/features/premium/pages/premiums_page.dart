import 'package:Cinemate/features/premium/pages/subscriptions_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Cinemate/themes/font_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    if (!widget.isPremium) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(Duration(seconds: 1), () {
          _showPremiumRequiredDialog();
        });
      });}
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
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people_alt_outlined,
                            color: Theme.of(context).colorScheme.tertiary, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          membersCount.toString(),
                          style: AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.tertiary, fontSize: 20)
                        ),
                      ],
                    ),
                    const VerticalDivider(thickness: 1, width: 20),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined,
                            color: Colors.red, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          _formatDuration(remainingTime),
                          style: AppTextStyles.medium.copyWith(color: Colors.red, fontSize: 20)
                        ),
                      ],
                    ),
                    const VerticalDivider(thickness: 1, width: 20),
                    Row(
                      children: [
                        Icon(Icons.emoji_events_outlined,
                            color: Theme.of(context).colorScheme.tertiary, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          "$award TL",
                          style: AppTextStyles.medium.copyWith(color: Theme.of(context).colorScheme.tertiary,fontSize: 20)
                        ),
                      ],
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.primary,
              ),
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
                  hintStyle: TextStyle(
                    color: colors.onSurface.withOpacity(0.4),
                  ),
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
                onPressed: (!widget.isPremium || hasSubmitted || isLoading)
                    ? null
                    : _submitStory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.isPremium
                      ? colors.primary
                      : colors.primary.withOpacity(0.5), // Premium değilse daha soluk gözüksün
                  foregroundColor: colors.onPrimary,
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
                      widget.isPremium
                          ? "Hikayemi Gönder"
                          : "Premium Üye Değilsiniz", // Farklı mesaj gösterebilirsiniz
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Geçmiş kazananlar
            Center(
              child: TextButton(
                onPressed: () {
                  // Geçmiş kazananlar sayfasına yönlendirme
                },
                style: TextButton.styleFrom(
                  foregroundColor: colors.primary,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Geçmiş Kazananlara Göz At",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}