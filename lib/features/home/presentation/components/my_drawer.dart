/*
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:Cinemate/features/home/presentation/components/my_drawer_tile.dart';
import 'package:Cinemate/features/profile/presentation/pages/profile_page.dart';
import 'package:Cinemate/features/profile/presentation/pages/profile_page2.dart';
import 'package:Cinemate/features/search/presentation/pages/search_page.dart';
import 'package:Cinemate/features/settings/pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [          
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              Divider(color: Theme.of(context).colorScheme.secondary,),
              MyDrawerTile(title: "ANASAYFA", icon: Icons.home, onTap: ()=>Navigator.of(context).pop(),),

              Divider(color: Theme.of(context).colorScheme.secondary,),
              MyDrawerTile(title: "PROFİL", icon: Icons.person, onTap: (){
                Navigator.of(context).pop();
                final user = context.read<AuthCubit>().currentUser;
                String? uid = user!.uid;
                Navigator.push(
                  context, MaterialPageRoute(
                    builder: (context)=> ProfilePage2(uid: uid,),
                    ),
                  );

              } ),

              Divider(color: Theme.of(context).colorScheme.secondary,),
              MyDrawerTile(
                title: "ARA",
                 icon: Icons.search,
                 onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage())) ),

              Divider(color: Theme.of(context).colorScheme.secondary,),
              MyDrawerTile(title: "AYARLAR", icon: Icons.settings, onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage())) ),
              Spacer(),
              MyDrawerTile(title: "ÇIKIŞ YAP", icon: Icons.logout_rounded, onTap: ()=>  context.read<AuthCubit>().logout(), )
            ],
          ),
        ),
      ),
    );
  }
}*/