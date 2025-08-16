import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:petshop/core/navigation/navigation_cubit.dart';
import 'package:petshop/core/navigation/tab_item.dart';
import 'package:petshop/core/themes/colors.dart';

class MainNavigation extends StatefulWidget {
  final Widget screen;

  const MainNavigation({super.key, required this.screen});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary_700,
      body: widget.screen,
      bottomNavigationBar: BlocBuilder<NavigationCubit, TabItem>(
        builder: (context, selectedTab) {
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: AppColors.primary_700,
            selectedItemColor: AppColors.primary_50,
            unselectedItemColor: AppColors.primary_300,
            currentIndex: selectedTab.index,
            onTap: (index) {
              final tab = TabItem.values[index];
              context.read<NavigationCubit>().selectTab(tab);
              _navigateToTab(context, tab);
            },
            items: TabItem.values.map((tab) {
              final tabInfo = TabItemData.tabInfo[tab]!;
              return BottomNavigationBarItem(
                icon: Icon(tabInfo.icon),
                label: tabInfo.label,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _navigateToTab(BuildContext context, TabItem tab) {
    final tabInfo = TabItemData.tabInfo[tab]!;
    context.goNamed(tabInfo.route);
  }
}
