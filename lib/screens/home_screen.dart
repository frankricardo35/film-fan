// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/Super_base.dart';
import 'package:movie_app/models/Movie.dart';
import 'package:movie_app/provider/FavouriteProvider.dart';
import 'package:movie_app/screens/favorite_screen.dart';
import 'package:movie_app/screens/movie_detail_screen.dart';
import 'package:movie_app/widgets/movie_item.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SuperBase {
  bool isLoadingMovieList=true;
  List<Movie> movieList=[];

  /// load now playing movie list from api
  /// */
  Future<void> _loadMovieList(){
    return ajax(url: "/movie/now_playing",
        method: "GET",
        context: context,
        onValue: (response,v){
          setState(() {
            movieList = (response["results"] as Iterable?)?.map((e){
              return Movie.fromJson(e);
            }).toList() ?? [];
            if(movieList.isNotEmpty){
              // sort movies by title asc;
              movieList.sort((a,b){
                return a.title!.compareTo(b.title!);
              });
            }
          });
        },error: (s,v){

        },onEnd: (){
          setState(() {
            isLoadingMovieList=false;
          });
        });
  }


  /// load favourite movie list from local storage on app start
  /// */
  getFavouriteMovies() async {
    String? records=(await prefs).getString("favourite_movies");
    if(records!=null) {
      List<Movie> favouriteMovies =[];
      json.decode(records).map((e) {
        favouriteMovies.add(Movie.fromJson(e));
        return Movie.fromJson(e);
      }).toList();
      var store = Provider.of<FavouriteProvider>(context, listen: false);
      store.setFavouriteMovies(favouriteMovies);
    }
  }



  @override
  void initState() {
    getFavouriteMovies();
    _loadMovieList();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Film Fan'.toUpperCase(),
          style: Theme.of(context).textTheme.caption?.copyWith(
            color: Colors.black45,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'muli',
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 10,right: 10),
          child:isLoadingMovieList?Center(child: loadBox(),):_buildBody(context)),
      floatingActionButton: Consumer<FavouriteProvider>(
        builder: (context, provider, child) {
          return provider.count>0? FloatingActionButton(
            onPressed: (){
              Navigator.push(context, CupertinoPageRoute(builder: (context)=>
                  const FavoriteScreen()));
            },
            child: const Icon(Icons.favorite),
          ):const SizedBox.shrink();
        }
      ),
    );
  }


  Widget _buildBody(BuildContext context) {
    return ListView.builder(
      itemCount: movieList.length,
        itemBuilder: (context, index) {
      return InkWell(onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>
            MovieDetailScreen(movie: movieList[index])));
      },child: MovieItem(movie:movieList[index]));
      },);
    }

}



