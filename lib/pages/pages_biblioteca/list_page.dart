import 'package:biblioteca_flutter/data/biblioteca_data.dart';
import 'package:biblioteca_flutter/data/livro_data.dart';
import 'package:biblioteca_flutter/model/biblioteca_model.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import '../../data/favorites_data.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<BibliotecaModel> livros = [];
  List<int> favoriteIds = [];
  List<String> generos = [];
  List<int> leituraIds = [];
  String? _generoSelecionado;

  Future<void> _loadLivros() async {
    final livro = await BibliotecaDatabase.instance.getLivros();
    final allFavoritos = await FavoritesData.instance.getFavoriteIds();
    final allLeitura = await LivroData.instance.getLivroEmLeitura();
    setState(() {
      livros = livro;
      favoriteIds = allFavoritos;
      leituraIds = allLeitura;
    });
  }

  Future<void> _toggleLivroEmLeitura(BibliotecaModel livro) async {
    await LivroData.instance.toggleLivroEmLeitura(livro);
    _loadLivros();
  }

  Future<void> _buscarGeneros() async {
    final listGeneros = await BibliotecaDatabase.instance.getBuscarGeneros();
    setState(() {
      generos = ["Todos", ...listGeneros];
    });
  }

  Future<void> _filtrarLivrosGenero() async {
    if (_generoSelecionado == null || _generoSelecionado == "Todos") {
      _loadLivros();
    } else {
      final books = await BibliotecaDatabase.instance
          .getLivrosByGenero(_generoSelecionado!);
      setState(() {
        livros = books;
      });
    }
  }

  Future<void> _toggleFavorite(BibliotecaModel livro) async {
    await FavoritesData.instance.toggleFavorite(livro);
    _loadLivros();
  }

  @override
  void initState() {
    super.initState();
    _loadLivros();
    _buscarGeneros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text(
          'List Book',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: _generoSelecionado,
              onChanged: (String? newValue) {
                setState(() {
                  _generoSelecionado = newValue;
                  _filtrarLivrosGenero();
                });
              },
              items: generos.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Gênero',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: livros.length,
              itemBuilder: (context, index) {
                final livro = livros[index];
                final isFavorite = favoriteIds.contains(livro.id);
                final isLendo = leituraIds.contains(livro.id);
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.zero,
                    gradient: LinearGradient(
                      colors: index % 2 == 0
                          ? [Colors.green.shade200, Colors.grey.shade600]
                          : [Colors.grey.shade200, Colors.green.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: ListTile(
                    leading: livro.image != null
                        ? CircleAvatar(
                            backgroundImage: FileImage(File(livro.image!)),
                            radius: 30,
                          )
                        : const CircleAvatar(
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.book, color: Colors.white),
                          ),
                    title: Text(livro.nomeLivro),
                    subtitle: Text(
                      'Autor: ${livro.nomeAutor}\nPreço: R\$${livro.preco}\nGênero: ${livro.genero}',
                    ),
                    trailing: Wrap(
                      spacing: 12,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                          onPressed: () => _toggleFavorite(livro),
                        ),
                        IconButton(
                          icon: Icon(
                            isLendo
                                ? Icons.menu_book_outlined
                                : Icons.menu_book,
                            color: isLendo ? Colors.white : null,
                          ),
                          onPressed: () => _toggleLivroEmLeitura(livro),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
