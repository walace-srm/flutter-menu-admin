import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:menu_admin/pages/finalized_orders/finalized_orders_controller.dart';
import 'package:menu_core/core/model/product_model.dart';
import 'package:menu_core/widgets/menu_app_bar.dart';
import 'package:menu_core/widgets/menu_empty.dart';
import 'package:menu_core/widgets/menu_list_view.dart';
import 'package:menu_core/widgets/menu_loading.dart';

class FinalizedOrdersPage extends StatefulWidget {
  const FinalizedOrdersPage({Key key}) : super(key: key);

  @override
  _FinalizedOrdersPageState createState() => _FinalizedOrdersPageState();
}

class _FinalizedOrdersPageState extends State<FinalizedOrdersPage> {
  final _controller = FinalizedOrdersController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MenuAppBar(
          title: Text('Pedidos Finalizados'),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _controller.finalizesOrdersStream,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              final pedidos =
                  _controller.getFinalizedOrdersFromDocs(snapshot.data.docs);
              if (pedidos == null || pedidos.length == 0) {
                return MenuEmpty();
              }
              return MenuListView(
                itemCount: pedidos.length,
                itemBuilder: (_, i) => ExpansionTile(
                  title: Text(
                    DateFormat("d MMM y 'às' HH:mm", 'pt_br').format(
                      DateFormat('yyyy-MM-dd HH:mm:ss').parse(
                        pedidos[i].dataPedido.toString(),
                      ),
                    ),
                  ),
                  subtitle: Text(
                    pedidos[i].nomeUsuario,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  trailing: Text(
                    'R\$ ${pedidos[i].valorPedido.toString()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  children: getProduct(pedidos[i].produtos),
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: MenuLoading(),
              );
            } else {
              return MenuEmpty();
            }
          },
        ));
  }

  List<Widget> getProduct(List<ProductModel> produtos) {
    if (produtos != null && produtos.isNotEmpty) {
      return produtos
          .map(
            (produto) => ListTile(
              leading: produto.urlImagem != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(produto.urlImagem),
                    )
                  : Icon(Icons.add_box),
              title: Text(produto.nome),
              trailing: Text(produto.quantidade.toString()),
            ),
          )
          .toList();
    }
  }
}
