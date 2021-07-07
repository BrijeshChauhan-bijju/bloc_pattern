import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app_bloc/BLoC.dart';
import 'package:flutter_app_bloc/Event.dart';
import 'package:flutter_app_bloc/model/Pokemon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with WidgetsBindingObserver {
  final _bloc = BLoC();
  BannerAd myBanner;
  InterstitialAd myInterstitial;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialzeBanners();
    initalizeInterstial();
    myBanner.load();
    _bloc.counter_event_sink.add(ApiEvent());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // initialzeBanners();
      // initalizeInterstial();
      // myBanner.load();
      // _bloc.counter_event_sink.add(ApiEvent());
    }
  }

  void initalizeInterstial() {

    InterstitialAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/8691691433',
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            // Keep a reference to the ad so you can show it later.
            myInterstitial = ad;
            myInterstitial.show();
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error');
          },
        ));

  }

  void initialzeBanners() {
    AdSize adSize = AdSize(width: 300, height: 60);
    myBanner = BannerAd(
      adUnitId: 'ca-app-pub-7410464693885383/1095703406',
      size: adSize,
      request: AdRequest(),
      listener: BannerAdListener(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Block Patter Demo"), automaticallyImplyLeading: false,),
        body: buildPokemonContent());
  }

  Widget buildPokemonContent() {
    return Stack(
      children: <Widget>[Container(
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
                  return buildCircularProgressIndicatorWidget();
              },
            )
          ],
        ),
      ), Align(alignment: Alignment.bottomCenter,
          child: Container(
            child: AdWidget(ad: myBanner,),
            width: myBanner.size.width.toDouble(),
            height: myBanner.size.height.toDouble(),
          ))
      ],
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
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
              title: new Text(item.name),
              subtitle: new Text(
                "Weight: ${item.weight} Height: ${item.height} ",
                style: Theme
                    .of(context)
                    .textTheme
                    .caption,
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
