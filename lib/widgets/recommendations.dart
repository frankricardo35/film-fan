
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/Super_base.dart';
import 'package:movie_app/models/Movie.dart';
import 'package:movie_app/screens/movie_detail_screen.dart';

class Recommendations extends StatefulWidget {
  final Movie movie;
  const Recommendations({Key? key, required this.movie}) : super(key: key);

  @override
  State<Recommendations> createState() => _RecommendationsState();
}

class _RecommendationsState extends State<Recommendations> with SuperBase {

  List<Movie> movieList=[];
  bool isLoadingMovieList=true;

  Future<void> _loadMovieList(){
    return ajax(url: "/movie/${widget.movie.id}/recommendations",
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
  @override
  initState(){
    super.initState();
    _loadMovieList();
  }

  @override
  Widget build(BuildContext context) {
    return isLoadingMovieList?loadBox():SizedBox(
      height: 300,
      child: ListView.separated(
        separatorBuilder: (context, index) => const VerticalDivider(
          color: Colors.transparent,
          width: 15,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: movieList.length,
        itemBuilder: (context, index) {
          Movie movie = movieList[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MovieDetailScreen(movie: movie),
                    ),
                  );
                },
                child: ClipRRect(
                  child: CachedNetworkImage(
                    imageUrl:
                    'https://image.tmdb.org/t/p/original/${movie.backdropPath}',
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        width: 180,
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                    placeholder: (context, url) => SizedBox(
                      width: 180,
                      height: 250,
                      child: Center(
                        child: Platform.isAndroid
                            ? const CircularProgressIndicator()
                            : const CupertinoActivityIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 180,
                      height: 250,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                              'assets/images/img_not_found.jpg'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: 180,
                child: Text(
                  movie.title!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'muli',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: 14,
                  ),
                  Text(
                    "${movie.voteAverage}",
                    style: const TextStyle(
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
