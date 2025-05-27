import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/features/auth/domain/entities/app_user.dart';
import 'package:Cinemate/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:Cinemate/features/auth/presentation/cubits/navbar_cubit.dart';
import 'package:Cinemate/features/chat/presentation/pages/chat_list_page.dart';
import 'package:Cinemate/features/movies/presentation/pages/movie_home_page.dart';
import 'package:Cinemate/start_page.dart';
import 'package:Cinemate/features/profile/presentation/pages/profile_page2.dart';
import 'package:Cinemate/features/search/presentation/pages/search_page.dart';

import '../../../home/presentation/pages/home_page.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}
class _NavBarState extends State<NavBar> {
  AppUser? currentUser;
  late final PageStorageBucket bucket;
  late List<Widget> screens;

  @override
  void initState() {
    super.initState();
    currentUser = context.read<AuthCubit>().currentUser;
    bucket = PageStorageBucket();
    screens = [
      StartPage(),
      HomePage(),
      SearchPage(),
      StartPage(),ProfilePage2(uid: currentUser!.uid),

      //HomePage(),
      //SearchPage(),
      //ChatsListPage(),
      //ProfilePage2(uid: currentUser!.uid),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavBarCubit, int>(
      builder: (context, currentTab) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          body: PageStorage(
            bucket: bucket,
            child: screens[currentTab],
          ),
          bottomNavigationBar: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildNavBarItem("assets/icons/popular.png", "Anasayfa", 0),
                buildNavBarItem("assets/icons/home.png", "Gönderiler", 1),
                buildNavBarItem("assets/icons/search.png", "Keşfet", 2),
                buildNavBarItem("assets/icons/chat.png", "Mesajlar", 3),
                buildNavBarItem("assets/icons/profile.png", "Profil", 4),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildNavBarItem(String iconPath, String label, int index) {
    final currentTab = context.watch<NavBarCubit>().state;
    return GestureDetector(
      onTap: () {
        context.read<NavBarCubit>().changeTab(index);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            color: currentTab == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary,
            height: 24,
            width: 24,
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: currentTab == index
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primary,
              fontSize: 12,
            ),
          ),
          if (currentTab == index)
            Container(
              height: 5,
              width: 20,
              margin: EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
        ],
      ),
    );
  }
}
