import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:Cinemate/features/communities/domain/entities/community_post_model.dart';

class CommuneRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Belirli bir topluluğa ait tüm komünleri getirir
  Future<List<Commune>> fetchCommunes({
    required String communityId,
    required int limit,
    Commune? lastFetched,
  }) async {
    try {
      Query query = _firestore
          .collection('communities')
          .doc(communityId)
          .collection('communes')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastFetched != null) {
        query = query.startAfter([lastFetched.createdAt]);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) {
  final data = doc.data();
  if (data is Map<String, dynamic>) {
    return Commune.fromMap(doc.id, data);
  } else {
    throw Exception('Belge verisi beklenen formatta değil');
  }
}).toList();

    } catch (e) {
      throw Exception('Komünler alınırken hata oluştu: $e');
    }
  }

  Future<void> createCommune({
    required String communityId,
    required Commune commune,
    File? image,
  }) async {
    try {
      String? imageUrl;

      if (image != null) {
        final ref = _storage.ref().child('commune_images/${DateTime.now().millisecondsSinceEpoch}');
        await ref.putFile(image);
        imageUrl = await ref.getDownloadURL();
      }

      await _firestore
          .collection('communities')
          .doc(communityId)
          .collection('communes')
          .add(commune.copyWith(imageUrl: imageUrl).toMap());
    } catch (e) {
      throw Exception('Komün oluşturulurken hata: $e');
    }
  }
  /// Topluluğun üye listesini getirir
  Future<List<String>> fetchCommunityMembers(String communityId) async {
    try {
      final doc = await _firestore.collection('communities').doc(communityId).get();

      if (!doc.exists) {
        debugPrint('Topluluk bulunamadı: $communityId');
        return [];
      }

      final members = doc.data()?['members'] as List<dynamic>?;

      return members?.map((e) => e.toString()).toList() ?? [];
    } catch (e) {
      debugPrint('Üyeler yüklenirken hata: $e');
      return [];
    }
  }



  /// Topluluğa kullanıcı ekler
  Future<void> addMemberToCommunity(String communityId, String userId) async {
    try {
      await _firestore.collection('communities').doc(communityId).update({
        'members': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      debugPrint('Üye eklenirken hata: $e');
    }
  }

  /// Topluluktan kullanıcıyı çıkarır
  Future<void> removeMemberFromCommunity(String communityId, String userId) async {
    try {
      await _firestore.collection('communities').doc(communityId).update({
        'members': FieldValue.arrayRemove([userId]),
      });
    } catch (e) {
      debugPrint('Üye çıkarılırken hata: $e');
    }
  }
}
