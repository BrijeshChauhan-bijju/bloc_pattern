import 'dart:async';

import 'package:flutter_app_bloc/Event.dart';
import 'package:flutter_app_bloc/model/Pokemon.dart';
import 'package:flutter_app_bloc/remote/PokemonApiImpl.dart';

class BLoC {
  final pokemonapiImpl = PokemonApiImpl();

  // init and get StreamController
  final _pokemonListSubject = StreamController<List<Pokemon>>();

  StreamSink<List<Pokemon>> get counter_sink => _pokemonListSubject.sink;

  // expose data from stream
  Stream<List<Pokemon>> get stream_counter => _pokemonListSubject.stream;

  final _pokemonlistcontroller = StreamController<Event>();

  // expose sink for input events
  Sink<Event> get counter_event_sink => _pokemonlistcontroller.sink;

  BLoC() {
    _pokemonlistcontroller.stream.listen(_count);
  }

  _count(Event event) => counter_sink.add(fetchdata());

  dispose() {
    _pokemonListSubject.close();
    _pokemonlistcontroller.close();
  }

  List<Pokemon> fetchdata()  {
      fetchpokemonlist().then((value){
      return value;
    });
  }

  Future<List<Pokemon>> fetchpokemonlist() async {
    try {
      _pokemonListSubject.sink.add(await pokemonapiImpl.getPokemonList());
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 500));
      _pokemonListSubject.sink.addError(e);
    }
  }
}
