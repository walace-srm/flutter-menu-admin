import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_core/core/model/category_model.dart';
import 'package:menu_core/core/model/product_model.dart';
import 'package:menu_core/core/model/promotion_model.dart';

class ListCategoryController {
  CollectionReference categoryRef =
  FirebaseFirestore.instance.collection('categorias');
  CollectionReference productRef =
  FirebaseFirestore.instance.collection('produtos');
  CollectionReference promotionRef =
  FirebaseFirestore.instance.collection('promocoes');
  final Stream<QuerySnapshot> _categoriasStream =
  FirebaseFirestore.instance.collection('categorias').snapshots();

  Stream<QuerySnapshot> categoryStream() => _categoriasStream;

  List<CategoryModel> getCategoryFromDocs(List<QueryDocumentSnapshot> docs) {
    return List.generate(docs.length, (i) {
      final categoriaDoc = docs[i];
      return CategoryModel.fromJson(
        categoriaDoc.id,
        categoriaDoc.data(),
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

  Future<List<ProductModel>> getProductCategory(CategoryModel categoria) async {
    final querySnapshot = await productRef.where(
        'categoria', isEqualTo: categoria.nome).get();
    final docs = querySnapshot.docs;
    return List.generate(
        docs.length, (i) => ProductModel.fromJson(docs[i].id, docs[i].data()));
  }

  Future<void> removeCategory(CategoryModel categoria) async {
    await categoryRef.doc(categoria.id).delete();
    final productCategory = await getProductCategory(categoria);
    productCategory.forEach((product) async {
      await productRef.doc(product.id).delete();
      final promotionProduct = await getPromotionProduct(product);
      promotionProduct.forEach((promocao) async {
        await promotionRef.doc(promocao.id).delete();
      });
    });
  }
}
