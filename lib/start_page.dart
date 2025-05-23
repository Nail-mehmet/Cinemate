import 'package:flutter/material.dart';
import 'package:Cinemate/features/movies/presentation/components/tab_item.dart';
import 'package:Cinemate/features/communities/presentation/pages/communities.page.dart';
import 'package:Cinemate/features/movies/presentation/pages/movie_home_page.dart';
import 'package:Cinemate/features/settings/pages/settings_page.dart';

import 'config/home_widget_helper.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      WidgetHelper.updateWidgetFromFirebase();
    });
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(

          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(5),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  labelColor: Theme.of(context).colorScheme.tertiary,
                  unselectedLabelColor: Theme.of(context).colorScheme.primary,
                  tabs: [
                    TabItem(title: 'Popüler',),
                    TabItem(title: 'Topluluklar'),

                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            MovieHomePage(),
            CommunitiesPage(),
          ],
        ),
      ),
    );
  }
}