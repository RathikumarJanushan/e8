import 'package:e8/view/user/home/km/FinishedOrdersPage.dart';
import 'package:flutter/material.dart';
import 'package:e8/common/color_extension.dart';
import 'package:e8/common_widget/tab_button.dart';
import 'package:e8/view/user/home/h_view.dart';

import 'package:e8/view/user/home/home_screen.dart';
import 'package:e8/view/user/home/sound/sound.dart';
import 'package:e8/view/user/home/user_orders/ViewOrdersPage.dart';

import 'package:e8/view/user/report.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selctTab = 2;
  PageStorageBucket storageBucket = PageStorageBucket();
  Widget selectPageView = const ViewOrdersPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(bucket: storageBucket, child: selectPageView),
      backgroundColor: const Color.fromARGB(255, 61, 60, 60),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: () {
            if (selctTab != 2) {
              selctTab = 2;
              selectPageView = const ViewOrdersPage();
            }
            if (mounted) {
              setState(() {});
            }
          },
          shape: const CircleBorder(),
          backgroundColor: selctTab == 2 ? TColor.primary : TColor.placeholder,
          child: Image.asset(
            "assets/img/tab_home.png",
            width: 30,
            height: 30,
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color:
            const Color.fromARGB(255, 21, 14, 14), // Dark color for the app bar
        surfaceTintColor: Colors.black, // Remove unwanted surface tint effects
        shadowColor: Colors.black54, // Subtle shadow for elevation
        elevation: 2,
        notchMargin: 12,
        height: 64,
        shape: const CircularNotchedRectangle(),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TabButton(
                title: "profile",
                icon: "assets/img/tab_order.png",
                onTap: () {
                  if (selctTab != 1) {
                    selctTab = 1;
                    selectPageView = DetailsScreen();
                  }
                  if (mounted) {
                    setState(() {});
                  }
                },
                isSelected: selctTab == 1,
              ),
              const SizedBox(
                width: 150,
                height: 150,
              ),
              TabButton(
                title: "Km",
                icon: "assets/img/tap_km.png", //
                onTap: () {
                  if (selctTab != 3) {
                    selctTab = 3;
                    selectPageView = FinishedOrdersPage();
                  }
                  if (mounted) {
                    setState(() {});
                  }
                },
                isSelected: selctTab == 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
