import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:menu_admin/pages/promotion/form_promotion_controller.dart';
import 'package:menu_core/core/model/product_model.dart';
import 'package:menu_core/core/model/promotion_model.dart';
import 'package:menu_core/core/priceUtils.dart';
import 'package:menu_core/widgets/menu_app_bar.dart';
import 'package:menu_core/widgets/menu_button_icon.dart';
import 'package:menu_core/widgets/menu_loading.dart';
import 'package:menu_core/widgets/price_discount_product.dart';
import 'package:menu_core/widgets/toasts/toast_utils.dart';
import 'package:select_form_field/select_form_field.dart';

class FormPromotionPage extends StatefulWidget {
  const FormPromotionPage(this.promotion, {Key key}) : super(key: key);

  final PromotionModel promotion;

  @override
  _FormPromotionPageState createState() => _FormPromotionPageState();
}

class _FormPromotionPageState extends State<FormPromotionPage> {
  final _formKey = GlobalKey<FormState>();
  MoneyMaskedTextController _descontoController;
  FormPromotionController _controller;

  @override
  void initState() {
    _controller = FormPromotionController(
      widget.promotion ?? PromotionModel(),
    );
    _descontoController = MoneyMaskedTextController(
      decimalSeparator: ',',
      thousandSeparator: '.',
      precision: 2,
      rightSymbol: '%',
      initialValue: _controller.promocao.desconto ?? 0,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MenuAppBar(
        title: Text(
            _controller.promocao.id == null ? 'Criar Promoção' :
            'Editar Promoção'
        ),
        actions: [
          MenuButtonIcon(
            iconData: Icons.check,
            onTap: () async {
              final form = _formKey.currentState;
              if (form.validate()) {
                form.save();
                await _controller.savePromotion();
                showSuccessToast('Promoção foi salva');
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Form(
              key: _formKey,
              child: FutureBuilder<List<ProductModel>>(
                future: _controller.productFuture,
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    final produtos = snapshot.data;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 300,
                          child: SelectFormField(
                            initialValue: _controller.promocao.idProduto,
                            labelText: 'Produto',
                            enabled: _controller.promocao.id == null,
                            items: produtos.map((produto) => {
                              'value': produto.id,
                              'label': produto.nome,
                            }).toList(),
                            validator: (produto) =>
                            produto.isEmpty
                                ? 'Campo Obrigatório'
                                : null,
                            onChanged: (produto) {
                              setState(() {
                                _controller.setInfoProductPromotion(produto);
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 12),
                        Container(
                          width: 150,
                          child: TextFormField(
                            controller: _descontoController,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r"\d+"),
                              ),
                            ],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              labelText: 'Desconto',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (desconto) {
                              if (desconto == null || desconto == 'R\$') {
                                return 'Campo Obrigatório';
                              } else if (double.parse(
                                  PriceUtils.cleanStringDiscount(desconto)) ==
                                  0) {
                                return 'O desconto deve ser maior que 0%';
                              } else if (double.parse(
                                  PriceUtils.cleanStringDiscount(desconto)) >=
                                  100) {
                                return 'O desconto não pode ser de 100%';
                              }
                              return null;
                            },
                            onSaved: (desconto) {
                              final stringDesconto = PriceUtils.cleanStringDiscount(desconto);
                              _controller.setDiscountPromotion(double.parse(stringDesconto));

                            },
                            onChanged: (desconto) {
                              final doubleDesconto = double.parse(desconto) / 100;
                              setState(() {
                                _controller.setDiscountPromotion(doubleDesconto);
                              });
                            }
                          ),
                        ),
                        SizedBox(height: 12),
                        if (_controller.promocao.id != null || _controller.heveProductSelected)
                        PriceDiscountProduct(
                          desconto: _controller.promocao.desconto,
                          preco: _controller.calcPriceDiscount(),
                        ),
                      ],
                    );
                  } else {
                    return Center(
                        child:MenuLoading()
                    );
                  }
                },
              )
          ),
        ),
      ),
    );
  }
}
