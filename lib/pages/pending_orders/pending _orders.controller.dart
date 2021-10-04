import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:menu_core/core/model/orders_model.dart';

class PendingOrdersController {
  CollectionReference pendingOrdersRef = FirebaseFirestore.instance.collection('pedidos_pendentes');
  CollectionReference finalizedOrdersRef = FirebaseFirestore.instance.collection('pedidos_finalizados');
  final Stream<QuerySnapshot> _pendingOrdersStream =
      FirebaseFirestore.instance.collection('pedidos_pendentes').snapshots();

  Stream<QuerySnapshot> get pendingOrdersStream => _pendingOrdersStream;

  List<OrdersModel> getOrdersFromDocs(List<QueryDocumentSnapshot> docs) {
    return List.generate(docs.length, (i) {
      final pedidoDoc = docs[i];
      return OrdersModel.fromJson(pedidoDoc.id, pedidoDoc.data());
    });
  }
  Future<void> finishOrders(OrdersModel pedido) async {
    await finalizedOrdersRef.doc(pedido.id).set(pedido.toJson());
    await pendingOrdersRef.doc(pedido.id).delete();
  }
}
