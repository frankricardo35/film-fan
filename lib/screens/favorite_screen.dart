import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/Super_base.dart';
import 'package:movie_app/provider/FavouriteProvider.dart';
import 'package:movie_app/screens/movie_detail_screen.dart';
import 'package:movie_app/widgets/movie_item.dart';
import 'package:provider/provider.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> with SuperBase {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Favorite Movies'.toUpperCase(),
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
          child:_buildBody(context)),
    );
  }


  Widget _buildBody(BuildContext context) {
    return Consumer<FavouriteProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          itemCount: provider.count,
            itemBuilder: (context, index) {
          return InkWell(onTap: (){
            Navigator.push(context, CupertinoPageRoute(builder: (context)=>
                MovieDetailScreen(movie: provider.favouriteMovies[index])));
          },child: MovieItem(movie:provider.favouriteMovies[index]));
          },);
      }
    );
    }
}

