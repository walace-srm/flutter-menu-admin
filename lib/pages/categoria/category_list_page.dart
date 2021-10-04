import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:menu_admin/pages/categoria/form_category_page.dart';
import 'package:menu_core/widgets/menu_app_bar.dart';
import 'package:menu_core/widgets/menu_button_icon.dart';
import 'package:menu_core/widgets/menu_empty.dart';
import 'package:menu_core/widgets/menu_list_tile.dart';
import 'package:menu_core/widgets/menu_list_view.dart';
import 'package:menu_core/widgets/menu_loading.dart';

import 'category_list_controller.dart';

class CategoryListPage extends StatelessWidget {
  final _controller = ListCategoryController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MenuAppBar(
        title: Text('Lista de Categorias'),
        actions: [
          MenuButtonIcon(
            iconData: Icons.add,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => FormCategoryPage(null)),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.categoryStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final categorias =
                _controller.getCategoryFromDocs(snapshot.data.docs);
            if (categorias.isEmpty || categorias == null) {
              return MenuEmpty();
            } else {
              return MenuListView(
                itemCount: categorias.length,
                itemBuilder: (context, i) => MenuListTile(
                  leading: Hero(
                    tag: categorias[i].id,
                    child: categorias[i].urlImagem != null
                        ? CircleAvatar(
                      backgroundImage:
                      NetworkImage(categorias[i].urlImagem),
                    )
                        : Icon(Icons.category),
                  ) ,
                  title: Text(categorias[i].nome),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await _controller.removeCategory(categorias[i]);
                    },
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => FormCategoryPage(categorias[i])),
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
