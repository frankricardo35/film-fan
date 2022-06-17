
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:movie_app/Super_base.dart';
import 'package:movie_app/models/Movie.dart';

class FavouriteProvider extends ChangeNotifier with SuperBase {

  List<Movie> favouriteMovies = [];
  int get count => favouriteMovies.length;

  addItem(Movie item){
    favouriteMovies.add(item);
    saveVal("favourite_movies", jsonEncode(favouriteMovies));
    notifyListeners();
  }
  deleteItem(Movie item){
    favouriteMovies.removeWhere((element) => element.id==item.id);
    saveVal("favourite_movies", jsonEncode(favouriteMovies));
    notifyListeners();
  }
  isFavourite(Movie item){
    return favouriteMovies.any((element) => element.id==item.id);
  }

  setFavouriteMovies(List<Movie> items){
    favouriteMovies=items;
    notifyListeners();
  }

}