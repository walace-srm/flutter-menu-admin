import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_core/core/model/product_model.dart';

class FormProductController {
  FormProductController(this.product);

  final _categoryRef = FirebaseFirestore.instance.collection('categorias');
  final _productRef = FirebaseFirestore.instance.collection('produtos');
  ProductModel product;
  final _firebaseStorage = FirebaseStorage.instance.ref();
  final _imagePicker = ImagePicker();

  Future<QuerySnapshot> get categoryFuture => _categoryRef.get();

  List<String> getCategoryFromData(List<QueryDocumentSnapshot> docs) {
    return List.generate(docs.length, (i) {
      final doc = docs[i];
      return doc.data()['nome'];
    });
  }

  Future<String> selectAndSaveImage(ImageSource source) async {
    final pickedFile = await _imagePicker.getImage(source: source);
    if (pickedFile != null) {
      final image = await pickedFile.readAsBytes();
      final dataImage = image.buffer.asUint8List();
      final uploadTask = _firebaseStorage
          .child('produtos')
          .child(dataImage.hashCode.toString()).putData(dataImage);
      final onTaskCompleted = await uploadTask.onComplete;
      final categoryUrl = await onTaskCompleted.ref.getDownloadURL();
      return categoryUrl;
    }
    return null;
  }

  Future<void> saveProduct() async {
    if (product.id != null) {
      await _productRef.doc(product.id).update(product.toJson());
    } else {
      await _productRef.add(product.toJson());
    }
  }

  void setNameProduct(String name) {
    product.nome = name;
  }

  void setPriceProduct(String price) {
    product.preco = price;
  }

  void setDescriptionProduct(String description) {
    product.descricao = description;
  }

  void setCategoryProduct(String category) {
    product.categoria = category;
  }

  void setUrlImageProduct(String urlImage) {
    product.urlImagem = urlImage;
  }
}