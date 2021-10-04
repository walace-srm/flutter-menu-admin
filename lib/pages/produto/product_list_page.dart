import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menu_admin/pages/produto/form_product_page.dart';
import 'package:menu_admin/pages/produto/product_list_controller.dart';
import 'package:menu_core/widgets/menu_app_bar.dart';
import 'package:menu_core/widgets/menu_button_icon.dart';
import 'package:menu_core/widgets/menu_empty.dart';
import 'package:menu_core/widgets/menu_list_tile.dart';
import 'package:menu_core/widgets/menu_list_view.dart';
import 'package:menu_core/widgets/menu_loading.dart';


class ProductListPage extends StatelessWidget {
  final _controller = ProductListController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MenuAppBar(
        title: Text('Lista de Produtos'),
        actions: [
          MenuButtonIcon(
            iconData: Icons.add,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => FormProductPage(null)),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.productStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final produtos =
            _controller.getProductFromDocs(snapshot.data.docs);
            if (produtos.isEmpty || produtos == null) {
              return MenuEmpty();
            } else {
              return MenuListView(
                itemCount: produtos.length,
                itemBuilder: (context, i) => MenuListTile(
                  leading: Hero(
                    tag: produtos[i].id,
                    child: produtos[i].urlImagem != null
                        ? CircleAvatar(
                      backgroundImage:
                      NetworkImage(produtos[i].urlImagem),
                    )
                        : Icon(Icons.fastfood),
                  ) ,
                  title: Text(produtos[i].nome),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await _controller.removeProduct(produtos[i]);
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => FormProductPage(produtos[i])),
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
