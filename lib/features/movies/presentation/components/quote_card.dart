import 'package:Cinemate/themes/font_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuoteCard extends StatelessWidget {
  Future<DocumentSnapshot> _fetchQuote() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('quotes')
        .limit(1)
        .get();
    return querySnapshot.docs.first;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: _fetchQuote(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Bir hata oluştu'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 114, // Match approximate card height
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Henüz söz eklenmemiş'),
          );
        }

        var quoteData = snapshot.data!.data() as Map<String, dynamic>;

        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                if (quoteData['imageUrl'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      quoteData['imageUrl'],
                      width: 75,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.broken_image, size: 60),
                    ),
                  ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${quoteData['text']}"',
                        style: AppTextStyles.italic.copyWith(fontSize: 14)
                      ),
                      SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '- ${quoteData['author']}',
                          style: AppTextStyles.bold.copyWith(fontSize: 14)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}