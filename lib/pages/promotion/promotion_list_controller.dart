import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_core/core/model/promotion_model.dart';

class PromotionListController {
  CollectionReference promotionRef = FirebaseFirestore.instance.collection('promocoes');
  final Stream<QuerySnapshot> _promocoesStream =
      FirebaseFirestore.instance.collection('promocoes').snapshots();

  Stream<QuerySnapshot> promocoesStream() => _promocoesStream;

  List<PromotionModel> getPromotionFromDocs(List<QueryDocumentSnapshot> docs) {
    return List.generate(docs.length, (i) {
      final promotionDoc = docs[i];
      return PromotionModel.fromJson(
        promotionDoc.id,
        promotionDoc.data(),
      );
    });
  }

  Future<void> removePromotion(PromotionModel promotion) async {
    await promotionRef.doc(promotion.id).delete();
  }
}
