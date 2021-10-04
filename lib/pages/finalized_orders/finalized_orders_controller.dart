import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_core/core/model/orders_model.dart';

class FinalizedOrdersController {
  final Stream<QuerySnapshot> _finalizedOrdersStream =
  FirebaseFirestore.instance.collection('pedidos_finalizados').snapshots();

  Stream<QuerySnapshot> get finalizesOrdersStream => _finalizedOrdersStream;

  List<OrdersModel> getFinalizedOrdersFromDocs(List<QueryDocumentSnapshot> docs) {
    return List.generate(docs.length, (i) {
      final pedidoDoc = docs[i];
      return OrdersModel.fromJson(pedidoDoc.id, pedidoDoc.data());
    });
  }
}
