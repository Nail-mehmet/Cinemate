/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Cinemate/themes/font_theme.dart';

class PremiumsPage extends StatefulWidget {
  const PremiumsPage({super.key});

  @override
  State<PremiumsPage> createState() => _PremiumsPageState();
}

class _PremiumsPageState extends State<PremiumsPage> {
  final TextEditingController _storyController = TextEditingController();
  bool hasSubmitted = false;
  bool isLoading = true;
  String title = '';
  String story = '';
  String award = '';
  int membersCount = 0;
  final String premiumDocId = "weeklyStory";
  Duration remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _calculateRemainingTime();
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

  Future<void> _fetchData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection("premium").doc(premiumDocId).get();
    final participantDoc = await FirebaseFirestore.instance
        .collection("premium")
        .doc(premiumDocId)
        .collection("participants")
        .doc(user.uid)
        .get();

    setState(() {
      title = doc['title'] ?? '';
      story = doc['story'] ?? '';
      award = doc['award'] ?? '';
      membersCount = doc['membersCount'] ?? 0;
      hasSubmitted = participantDoc.exists;
      isLoading = false;
    });
  }

  Future<void> _submitStory() async {
    final user = FirebaseAuth.instance.currentUser;
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
      await FirebaseFirestore.instance
          .collection("premium")
          .doc(premiumDocId)
          .collection("participants")
          .doc(user.uid)
          .set({
        "userId": user.uid,
        "text": text,
        "timestamp": FieldValue.serverTimestamp(),
      });

      setState(() {
        hasSubmitted = true;
        _storyController.clear();
        membersCount++;
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
                onPressed: hasSubmitted || isLoading ? null : _submitStory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
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
                            "Hikayemi Gönder",
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
}*/