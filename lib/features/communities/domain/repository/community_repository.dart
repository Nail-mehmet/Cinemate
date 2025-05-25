import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:Cinemate/features/communities/domain/entities/community_post_model.dart';

class CommuneRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Komünleri getir
  Future<List<Commune>> fetchCommunes({
    required String communityId,
    required int limit,
    Commune? lastFetched,
  }) async {
    try {
      final List data;

      if (lastFetched != null) {
        data = await _supabase
            .from('communes')
            .select()
            .eq('community_id', communityId)
            .lt('created_at', lastFetched.createdAt.toIso8601String()) // en son çekilenin öncesi
            .order('created_at', ascending: false)
            .limit(limit);
      } else {
        data = await _supabase
            .from('communes')
            .select()
            .eq('community_id', communityId)
            .order('created_at', ascending: false)
            .limit(limit);
      }

      return data.map((e) => Commune.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Komünler alınırken hata oluştu: $e');
    }
  }

  /// Komün oluştur
  Future<void> createCommune({
    required String communityId,
    required Commune commune,
    File? image,
  }) async {
    try {
      String? imageUrl;

      if (image != null) {
        final fileName = '${const Uuid().v4()}.jpg';
        await _supabase.storage
            .from('communeimages')
            .upload('public/$fileName', image);
        imageUrl = _supabase.storage
            .from('communeimages')
            .getPublicUrl('public/$fileName');
      }

      await _supabase.from('communes').insert({
        'id': commune.id,
        'text': commune.text,
        'image_url': imageUrl,
        'user_id': commune.userId,
        'created_at': commune.createdAt.toIso8601String(),
        'community_id': communityId,
      });
    } catch (e) {
      throw Exception('Komün oluşturulurken hata: $e');
    }
  }

  /// Üyeleri getir
  Future<List<String>> fetchCommunityMembers(String communityId) async {
    try {
      final data = await _supabase
          .from('communities')
          .select('members')
          .eq('id', communityId)
          .single();

      final members = data['members'] as List<dynamic>?;

      return members?.map((e) => e.toString()).toList() ?? [];
    } catch (e) {
      debugPrint('Üyeler yüklenirken hata: $e');
      return [];
    }
  }

  /// Üye ekle
  Future<void> addMemberToCommunity(String communityId, String userId) async {
    try {
      final currentMembers = await fetchCommunityMembers(communityId);
      if (!currentMembers.contains(userId)) {
        currentMembers.add(userId);
        await _supabase
            .from('communities')
            .update({'members': currentMembers})
            .eq('id', communityId);
      }
    } catch (e) {
      debugPrint('Üye eklenirken hata: $e');
    }
  }

  /// Üye çıkar
  Future<void> removeMemberFromCommunity(String communityId, String userId) async {
    try {
      final currentMembers = await fetchCommunityMembers(communityId);
      currentMembers.remove(userId);
      await _supabase
          .from('communities')
          .update({'members': currentMembers})
          .eq('id', communityId);
    } catch (e) {
      debugPrint('Üye çıkarılırken hata: $e');
    }
  }
}
