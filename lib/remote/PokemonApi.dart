import 'package:flutter_app_bloc/model/Pokemon.dart';

abstract class PokemonApi{
  Future<List<Pokemon>> getPokemonList();
}