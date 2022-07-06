import 'package:flutter/material.dart';

import 'scaffold_page.dart';
import '../widgets/my_infinity_list.dart';

class HomePage extends StatelessWidget {
  
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ScaffoldPage(
      child: const TabBarView(
        children: [
          MyInfinityList(tile: 'gral'),
          MyInfinityList(tile: 'mrks'),
          MyInfinityList(tile: 'soli'),
        ],
      ),
    );
  }
}