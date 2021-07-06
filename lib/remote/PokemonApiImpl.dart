import 'dart:convert';

import 'package:flutter_app_bloc/model/Pokemon.dart';
import 'package:flutter_app_bloc/remote/PokemonApi.dart';
import 'package:http/http.dart';

class PokemonApiImpl implements PokemonApi {
  @override
  Future<List<Pokemon>> getPokemonList() async {
    try{
      final response = await get(Uri.parse('https://raw.githubusercontent.com/Biuni/PokemonGO-Pokedex/master/pokedex.json'));
      if (response.statusCode == 200) {
        Map<String, dynamic> mapResponse = json.decode(response.body);
        var list = mapResponse['pokemon'] as List;
        List<Pokemon> listPokemon = List();
        for (var idx=0;idx<list.length;idx++) {
          Pokemon pokemon = Pokemon();
          pokemon.name = list.asMap()[idx]['name'];
          pokemon.url = list.asMap()[idx]['img'];
          pokemon.weight = list.asMap()[idx]['weight'];
          pokemon.height = list.asMap()[idx]['height'];
          var typelist = list.asMap()[idx]['type'] as List;
          pokemon.type = typelist.asMap()[0];
          listPokemon.add(pokemon);
        }
        return listPokemon;
      }else{
        throw Exception("Error Code: ${response.statusCode}");
      }
    }catch(e){
      throw Exception("There was a problem with the connection");
    }
  }
}
