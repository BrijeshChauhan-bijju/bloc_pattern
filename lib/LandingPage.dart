import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_bloc/BLoC.dart';
import 'package:flutter_app_bloc/Event.dart';
import 'package:flutter_app_bloc/model/Pokemon.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _bloc = BLoC();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc.counter_event_sink.add(ApiEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Block Patter Demo"),automaticallyImplyLeading: false,),
        body: buildPokemonContent());
  }

  Widget buildPokemonContent() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          StreamBuilder(
            stream: _bloc.stream_counter,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return buildCircularProgressIndicatorWidget();
              }
              else if (snapshot.hasError) {
                showSnackBar(context, snapshot.error.toString());
                return buildListViewNoDataWidget();
              }
              else if (snapshot.connectionState == ConnectionState.active) {
                var pokemonList = snapshot.data;
                if (null != pokemonList)
                  return buildListViewWidget(pokemonList);
                else
                  return buildListViewNoDataWidget();
              }
              else
                return buildListViewNoDataWidget();

            },
          )
        ],
      ),
    );
  }

  @override
  dispose() {
    super.dispose();
    _bloc.dispose();
  }

  Widget buildListViewWidget(List<Pokemon> pokemonList) {
    return Flexible(
        child: new ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: pokemonList.length,
      itemBuilder: (BuildContext context, int index) {
        var item = pokemonList[index];
        var _colors = Colors.primaries;
        final MaterialColor color = _colors[index % _colors.length];
        return new ListTile(
          dense: false,
          leading: new CircleAvatar(
            backgroundColor: Colors.white,
            child: CachedNetworkImage(
              imageUrl: item.url,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          title: new Text(item.name),
          subtitle: new Text(
            "Weight: ${item.weight} Height: ${item.height} ",
            style: Theme.of(context).textTheme.caption,
          ),
          onTap: () {
            // Navigator.push(
            //     context,
            //     new MaterialPageRoute(
            //         builder: (context) => new ViewPokemonDetail()));
          },
        );
      },
    ));
  }

  Widget buildListViewNoDataWidget() {
    return Expanded(
      child: Center(
        child: Text("No Data Available"),
      ),
    );
  }

  Widget buildCircularProgressIndicatorWidget() {
    return Expanded(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void showSnackBar(BuildContext context, String errorMessage) async {
    await Future.delayed(Duration.zero);
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
  }

}
