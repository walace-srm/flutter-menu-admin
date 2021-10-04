import 'package:flutter/material.dart';
import 'package:menu_admin/pages/categoria/category_list_page.dart';
import 'package:menu_admin/pages/finalized_orders/finalized_orders_page.dart';
import 'package:menu_admin/pages/pending_orders/pending%20_orders_page.dart';
import 'package:menu_admin/pages/produto/product_list_page.dart';
import 'package:menu_admin/pages/promotion/promotion_list_page.dart';
import 'package:menu_core/core/model/UserModel.dart';
import 'package:menu_core/widgets/menu_app_bar.dart';
import 'package:menu_core/widgets/menu_logo.dart';
import 'package:menu_core/widgets/menu_logo_admin.dart';

class HomePage extends StatelessWidget {
  const HomePage(this.user, {Key key}) : super(key: key);

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MenuAppBar(
        title: Container(
          child: MenuLogoAdmin(
            fontSize: 28,
          ),
        ),
        withLeading: false,
      ),
      body: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _Button(
              text: 'Categorias',
              iconData: Icons.category,
              page: CategoryListPage(),
            ),
            _Button(
              text: 'Produtos',
              iconData: Icons.fastfood,
              page: ProductListPage(),
            ),
            _Button(
              text: 'Promoções',
              iconData: Icons.campaign,
              page: PromotionListPage(),
            ),
            _Button(
              text: 'Pedidos Pendentes',
              iconData: Icons.pending,
              page: PendingOrdersPage(),
            ),
            _Button(
              text: 'Pedidos Finalizados',
              iconData: Icons.flag,
              page: FinalizedOrdersPage(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  _Button({
    this.page,
    this.iconData,
    this.text,
  });

  final Widget page;
  final IconData iconData;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => page),
          );
        },
        child: Container(
          width: 100,
          height: 90,
          padding: EdgeInsets.all(8),
          child: Column(
            children: [
              Icon(iconData, size: 32, color: Theme.of(context).primaryColor),
              SizedBox(height: 6),
              Expanded(child: Text(text, style: TextStyle(fontSize: 16))),
            ],
          ),
        ),
      ),
    );
  }
}
