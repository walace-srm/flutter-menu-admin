import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_core/core/model/product_model.dart';
import 'package:menu_core/core/model/promotion_model.dart';
import 'package:menu_core/core/priceUtils.dart';

class FormPromotionController {
  FormPromotionController(this.promocao);

  final _produtosRef = FirebaseFirestore.instance.collection('produtos');
  final _promocoesRef = FirebaseFirestore.instance.collection('promocoes');
  final PromotionModel promocao;
  List<ProductModel> listProduct;

  bool get heveProductSelected => promocao.idProduto != null;

  Future<List<ProductModel>> get productFuture => getAllProducts();
  Future<List<ProductModel>> getAllProducts() async {
    final querySnapshot = await _produtosRef.get();
    listProduct = querySnapshot.docs
        .map((doc) => ProductModel.fromJson(doc.id, doc.data()))
        .toList();
    return listProduct;
  }

  void setInfoProductPromotion(String produtoId) {
    final produto = listProduct.firstWhere((prod) => prod.id == produtoId);
    if (produto != null) {
      promocao.idProduto = produto.id;
      promocao.nomeProduto = produto.nome;
      promocao.urlImagem = produto.urlImagem;
      promocao.valorOriginalProduto = double.parse(PriceUtils.cleanStringPrice(produto.preco));
    }
  }

  void setDiscountPromotion(double desconto) {
    promocao.desconto = desconto;
  }

  ProductModel getProductSelected() {
    return listProduct.firstWhere((produto) => produto.id == promocao.idProduto);
  }

  double calcPriceDiscount() {
    final produto = getProductSelected();
    final preco = double.parse(PriceUtils.cleanStringPrice(produto.preco));
    return preco - ((preco *(promocao.desconto ?? 0)) / 100);
  }

  Future<void> savePromotion() async {
    await _promocoesRef.doc(promocao.idProduto).set(promocao.toJson());
  }
}
