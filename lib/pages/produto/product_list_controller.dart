import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_core/core/model/product_model.dart';
import 'package:menu_core/core/model/promotion_model.dart';

class ProductListController {
  CollectionReference productRef =
      FirebaseFirestore.instance.collection('produtos');
  CollectionReference promotionRef =
      FirebaseFirestore.instance.collection('promocoes');
  final Stream<QuerySnapshot> _productStream =
      FirebaseFirestore.instance.collection('produtos').snapshots();

  Stream<QuerySnapshot> productStream() => _productStream;

  List<ProductModel> getProductFromDocs(List<QueryDocumentSnapshot> docs) {
    return List.generate(docs.length, (i) {
      final productDoc = docs[i];
      return ProductModel.fromJson(
        productDoc.id,
        productDoc.data(),
      );
    });
  }

  Future<List<PromotionModel>> getPromotionProduct(ProductModel product) async {
    final querySnapshot =
        await promotionRef.where('idProduto', isEqualTo: product.id).get();
    final docs = querySnapshot.docs;
    return List.generate(docs.length,
        (i) => PromotionModel.fromJson(docs[i].id, docs[i].data()));
  }

  Future<void> removeProduct(ProductModel product) async {
    await productRef.doc(product.id).delete();
    final promotionProduct = await getPromotionProduct(product);
    promotionProduct.forEach((promocao) async {
      await promotionRef.doc(promocao.id).delete();
    });
  }
}
