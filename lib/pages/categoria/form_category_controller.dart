import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_core/core/model/category_model.dart';

class FormCategoryController {
  FormCategoryController(this._categoria);
  CategoryModel _categoria = CategoryModel();

  final _firebaseStorage = FirebaseStorage.instance.ref();

  final _imagePicker = ImagePicker();

  final _categoryRef = FirebaseFirestore.instance.collection('categorias');

  CategoryModel get category => _categoria;

  Future<void> saveCategory() async {
    if (_categoria.id != null) {
      await _categoryRef.doc(_categoria.id).update(_categoria.toJson());
    } else {
      await _categoryRef.add(_categoria.toJson());
    }
  }

  Future<String> selectAndSaveImage(ImageSource source) async {
    final pickedFile = await _imagePicker.getImage(source: source);
    if (pickedFile != null) {
      final image = await pickedFile.readAsBytes();
      final dataImage = image.buffer.asUint8List();
      final uploadTask = _firebaseStorage
          .child('categorias')
          .child(dataImage.hashCode.toString()).putData(dataImage);
      final onTaskCompleted = await uploadTask.onComplete;
      final categoryUrl = await onTaskCompleted.ref.getDownloadURL();
      return categoryUrl;
    }
    return null;
  }

  void setNameCategory(String nome) => _categoria.nome = nome;

  void setDescriptionCategory(String descricao) =>
      _categoria.descricao = descricao;

  void setUrlImageCategory(String urlImage) =>
      _categoria.urlImagem = urlImage;
}
