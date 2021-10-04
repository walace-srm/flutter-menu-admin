import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menu_admin/pages/promotion/form_promotion_page.dart';
import 'package:menu_admin/pages/promotion/promotion_list_controller.dart';
import 'package:menu_core/widgets/menu_app_bar.dart';
import 'package:menu_core/widgets/menu_button_icon.dart';
import 'package:menu_core/widgets/menu_empty.dart';
import 'package:menu_core/widgets/menu_list_tile.dart';
import 'package:menu_core/widgets/menu_list_view.dart';
import 'package:menu_core/widgets/menu_loading.dart';


class PromotionListPage extends StatelessWidget {
  final _controller = PromotionListController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MenuAppBar(
        title: Text('Lista de Promoções'),
        actions: [
          MenuButtonIcon(
            iconData: Icons.add,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => FormPromotionPage(null)),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.promocoesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final promocoes =
            _controller.getPromotionFromDocs(snapshot.data.docs);
            if (promocoes.isEmpty || promocoes == null) {
              return MenuEmpty();
            } else {
              return MenuListView(
                itemCount: promocoes.length,
                itemBuilder: (context, i) => MenuListTile(
                  leading: Icon(Icons.campaign),
                  title: Text(promocoes[i].nomeProduto),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await _controller.removePromotion(promocoes[i]);
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => FormPromotionPage(promocoes[i])),
                    );
                  },
                ),
              );
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: MenuLoading(),
            );
          }
          return MenuEmpty();
        },
      ),
    );
  }
}
