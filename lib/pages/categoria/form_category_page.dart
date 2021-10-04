import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_admin/pages/categoria/form_category_controller.dart';
import 'package:menu_core/core/model/category_model.dart';
import 'package:menu_core/widgets/menu_button_icon.dart';

class FormCategoryPage extends StatefulWidget {
  const FormCategoryPage(this.categoria, {Key key}) : super(key: key);

  final CategoryModel categoria;

  @override
  _FormCategoryPageState createState() => _FormCategoryPageState();
}

class _FormCategoryPageState extends State<FormCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  FormCategoryController _controller;

  @override
  void initState() {
    _controller = FormCategoryController(widget.categoria ?? CategoryModel());
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
                title: Text(_controller.category.nome == null
                    ? 'Criar Categoria'
                    : 'Editar categoria'),
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
                        await _controller.saveCategory();
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
                                child: _controller.category.urlImagem == null
                                    ? Center(
                                        child: Icon(
                                          Icons.image_outlined,
                                          size: 100,
                                          color: Theme.of(context)
                                              .primaryColorLight,
                                        ),
                                      )
                                    : Hero(
                                        tag: _controller.category.id ?? '',
                                        child: Image.network(
                                            _controller.category.urlImagem,
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
                                    _controller.setUrlImageCategory(imageUrl);
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      width: 300,
                      child: TextFormField(
                        initialValue: _controller.category.nome ?? '',
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelText: 'Nome',
                          hintText: 'Nome',
                        ),
                        validator: (nome) =>
                            nome.isEmpty ? 'Campo Obrigatório' : null,
                        onSaved: _controller.setNameCategory,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      width: 400,
                      child: TextFormField(
                        initialValue: _controller.category.descricao ?? '',
                        maxLines: 5,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          labelText: 'Descrição',
                          hintText: 'Descrição',
                        ),
                        validator: (descricao) =>
                            descricao.isEmpty ? 'Campo Obrigatório' : null,
                        onSaved: _controller.setDescriptionCategory,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
