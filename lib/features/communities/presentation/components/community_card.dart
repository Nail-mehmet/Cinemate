import 'package:flutter/material.dart';
import 'package:Cinemate/themes/font_theme.dart';

class CommunityCard extends StatefulWidget {
  final String name;
  final String imageUrl;
  final int membersCount;
  final bool isMember;
  final VoidCallback onJoin;
  final VoidCallback onTap;

  const CommunityCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.membersCount,
    required this.isMember,
    required this.onJoin,
    required this.onTap,
  });

  @override
  State<CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends State<CommunityCard> {
  late bool _isMember;

  @override
  void initState() {
    super.initState();
    _isMember = widget.isMember;
  }

  void _toggleMembership() {
    widget.onJoin();
    setState(() {
      _isMember = !_isMember;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isMember ? widget.onTap : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background image
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Dark overlay
            Container(
              height: 180,
              width: double.infinity,
              color: Colors.black.withOpacity(0.3),
            ),
            // Info
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.membersCount} üye',
                          style: AppTextStyles.bold.copyWith(color: Theme.of(context).colorScheme.tertiary
                          )
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Text(
                        widget.name,
                        style: AppTextStyles.semiBold.copyWith(fontSize: 20, color: Colors.white)
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: ElevatedButton(
                        onPressed: _toggleMembership,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isMember ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _isMember ? 'Ayrıl' : 'Katıl',
                          style: AppTextStyles.bold.copyWith(color:_isMember ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.tertiary),
                        ),
                      ),
                    ),
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
