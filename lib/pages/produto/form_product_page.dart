import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_admin/pages/produto/form_product_controller.dart';
import 'package:menu_core/core/model/product_model.dart';
import 'package:menu_core/core/priceUtils.dart';
import 'package:menu_core/widgets/menu_button_icon.dart';
import 'package:menu_core/widgets/menu_loading.dart';
import 'package:menu_core/widgets/toasts/toast_utils.dart';
import 'package:select_form_field/select_form_field.dart';

class FormProductPage extends StatefulWidget {
  const FormProductPage(this.product, {Key key}) : super(key: key);

  final ProductModel product;

  @override
  _FormProductPageState createState() => _FormProductPageState();
}

class _FormProductPageState extends State<FormProductPage> {
  final _formKey = GlobalKey<FormState>();
  MoneyMaskedTextController _priceController;
  FormProductController _controller;

  @override
  void initState() {
    _controller = FormProductController(
      widget.product ?? ProductModel(),
    );
    _priceController = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      leftSymbol: 'R\$',
    )..text = _controller.product.preco;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (_, __) {
            return [
              SliverAppBar(
                expandedHeight: 240,
                collapsedHeight: 40,
                toolbarHeight: 38,
                elevation: 0.5,
                floating: false,
                pinned: true,
                title: Text(_controller.product.nome == null
                    ? 'Criar Produto'
                    : 'Editar Produto'),
                leadingWidth: 40,
                leading: MenuButtonIcon(
                  iconData: Icons.chevron_left,
                  onTap: () => Navigator.of(context).pop(),
                ),
                actions: [
                  MenuButtonIcon(
                    iconData: Icons.check,
                    onTap: () async {
                      final form = _formKey.currentState;
                      if (form.validate()) {
                        form.save();
                        await _controller.saveProduct();
                        showSuccessToast(_controller.product == null
                            ? 'Produto Criado com Sucesso!'
                            : 'Produto Alterado com sucesso!');
                        Navigator.of(context).pop();
                      }
                    },
                  )
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                      padding: EdgeInsets.fromLTRB(16, 44, 16, 20),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                                width: double.maxFinite,
                                color: Theme.of(context).colorScheme.surface,
                                child: _controller.product.urlImagem == null
                                    ? Center(
                                        child: Icon(
                                          Icons.image_outlined,
                                          size: 100,
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                        ),
                                      )
                                    : Hero(
                                        tag: _controller.product.id ?? '',
                                        child: Image.network(
                                            _controller.product.urlImagem,
                                            fit: BoxFit.cover),
                                      )),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Material(
                              borderRadius: BorderRadius.circular(30),
                              color: Theme.of(context)
                                  .colorScheme
                                  .background
                                  .withOpacity(.7),
                              child: PopupMenuButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Theme.of(context).primaryColor,
                                ),
                                itemBuilder: (_) => [
                                  PopupMenuItem<String>(
                                    value: 'Camera',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.photo_camera,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Camera',
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: 'Galeria',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.photo_library,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Galeria',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (valor) async {
                                  final imageUrl =
                                      await _controller.selectAndSaveImage(
                                    valor == 'Camera'
                                        ? ImageSource.camera
                                        : ImageSource.gallery,
                                  );
                                  setState(() {
                                    _controller.setUrlImageProduct(imageUrl);
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              )
            ];
          },
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FutureBuilder<QuerySnapshot>(
                  future: _controller.categoryFuture,
                  builder: (_, snapshop) {
                    if (snapshop.hasData) {
                      final data = snapshop.data;
                      final categorias =
                          _controller.getCategoryFromData(data.docs);
                      return Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          //alinhar no inicio
                          children: [
                            Container(
                              width: 300,
                              child: SelectFormField(
                                initialValue: _controller.product.categoria,
                                labelText: 'Categoria',
                                items: categorias
                                    .map((categoria) => {
                                          'value': categoria,
                                          'label': categoria,
                                        })
                                    .toList(),
                                validator: (categoria) => categoria.isEmpty
                                    ? 'Campo Obrigatório'
                                    : null,
                                onSaved: _controller.setCategoryProduct,
                              ),
                            ),
                            SizedBox(height: 12),
                            Container(
                              width: 300,
                              child: TextFormField(
                                initialValue: _controller.product.nome ?? '',
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  labelText: 'Nome',
                                  hintText: 'Nome',
                                ),
                                validator: (nome) =>
                                    nome.isEmpty ? 'Campo Obrigatório' : null,
                                onSaved: _controller.setNameProduct,
                              ),
                            ),
                            SizedBox(height: 12),
                            Container(
                              width: 400,
                              child: TextFormField(
                                initialValue:
                                    _controller.product.descricao ?? '',
                                maxLines: 5,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  labelText: 'Descrição',
                                  hintText: 'Descrição',
                                ),
                                validator: (descricao) => descricao.isEmpty
                                    ? 'Campo Obrigatório'
                                    : null,
                                onSaved: _controller.setDescriptionProduct,
                              ),
                            ),
                            SizedBox(height: 12),
                            Container(
                              width: 150,
                              child: TextFormField(
                                controller: _priceController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r"\d+"),
                                  ),
                                ],
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  labelText: 'Preço',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (preco) {
                                  if (preco == null || preco == 'R\$') {
                                    return 'Campo Obrigatório';
                                  } else if (PriceUtils.getNumberStringPrice(
                                          preco) ==
                                      0) {
                                    return 'O preço do produto não pode ser 0';
                                  }
                                  return null;
                                },
                                onSaved: _controller.setPriceProduct,
                                onChanged: (preco) =>
                                    _priceController.text = preco,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: MenuLoading(),
                      );
                    }
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
