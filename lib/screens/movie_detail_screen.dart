import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movie_app/Super_base.dart';
import 'package:movie_app/models/Genre.dart';
import 'package:movie_app/models/Movie.dart';
import 'package:movie_app/models/MovieDetail.dart';
import 'package:movie_app/provider/FavouriteProvider.dart';
import 'package:movie_app/screens/favorite_screen.dart';
import 'package:movie_app/widgets/casts_widget.dart';
import 'package:movie_app/widgets/recommendations.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({Key? key, required this.movie}) : super(key: key);

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> with SuperBase {
  MovieDetail? movieDetail;
  bool isLoading=true;
  int _selectedStar=0;
  bool isSavingRating=false;
  bool isSavingFavourite=false;
  bool isFavourites=false;

  List<Genre> genres=[];




  /// this method is used to load movie detail from server
  Future<void> _loadMovieDetails(){
    return ajax(url: "/movie/${widget.movie.id}",
        context: context,
        onValue: (response,url){
          setState(() {
            movieDetail=MovieDetail.fromJson(response);
            genres=movieDetail?.genres??[];
          });
        },error: (s,v){
        },onEnd: (){
          setState(() {
            isLoading=false;
          });
        });
  }
  /// this method is used to load guest session id from server
  /// which is required to rate movie
  _loadGuestSessionId(){
    return ajax(url: "/authentication/guest_session/new",
        method: "GET",
        context: context,
        onValue: (response,url){
          setState(() {
            SuperBase.sessionId=response["guest_session_id"];
          });
        },error: (s,v){
        },onEnd: (){
        });
  }

  /// this method is used to get youtube trailer if of movie
  _getYoutubeTrailer(){
    return ajax(url: "/movie/${widget.movie.id}/videos",
        method: "GET",
        context: context,
        onValue: (response,url){
          setState(() {
            SuperBase.youtubeTrailerId=response["results"][0]["key"];
          });
        },error: (s,v){
        },onEnd: (){
        });
  }

  /// rating star icon
  _buildRateButton(int rateValue) {

    return InkWell(
      onTap: () {
        setState(() {
          _selectedStar=rateValue;
        });
      },
      child:Icon(Icons.star,color: _selectedStar>=rateValue?Colors.yellow[800]:Colors.grey,size: 16,) ,
    );
  }


  /// this method is used to save the movie rating to the server
  _saveRating() async {
    if (_selectedStar > 0) {
      setState(() {
        isSavingRating = true;
      });
      await ajax(url: "/movie/${widget.movie.id}/rating",
          method: "POST",
          context: context,
          json: true,
          jsonData: jsonEncode({
            "value": _selectedStar
          }),
          onValue: (response, url) {
            showSnack("Rating saved", context);
            _selectedStar= 0;
          },
          error: (s, v) {

            showSnack("Error Occurred", context);
          },
          onEnd: () {
            setState(() {
              isSavingRating = false;
            });
          });
    }else{
      showSnack("Please select a rating", context);
    }
  }




  @override
  void initState() {
    _loadMovieDetails();
    _loadGuestSessionId();
    _getYoutubeTrailer();
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        body:isLoading?Center(child: loadBox()):_buildDetailBody(context),
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
      ),
      onWillPop: () async => true,
    );
  }

  Widget _buildDetailBody(BuildContext context) {
   if(movieDetail !=null){
     return Stack(
        children: <Widget>[
          ClipPath(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: CachedNetworkImage(
                imageUrl:
                'https://image.tmdb.org/t/p/original/${movieDetail?.backdropPath}',
                height: MediaQuery.of(context).size.height / 2.5,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const CupertinoActivityIndicator(),
                errorWidget: (context, url, error) => Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/img_not_found.jpg'),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  Consumer<FavouriteProvider>(
                    builder: (context, provider, child) {
                      return IconButton(
                        icon:provider.isFavourite(widget.movie)?const Icon(Icons.favorite,color: Colors.red,):const Icon(Icons.favorite_border),
                        onPressed: () {
                          if(provider.isFavourite(widget.movie)) {
                            provider.deleteItem(widget.movie);
                          }else{
                            provider.addItem(widget.movie);
                          }
                        });
                    }
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.only(top: 120),
                child: GestureDetector(
                  onTap: () async {
                    final youtubeUrl =
                        'https://www.youtube.com/embed/${SuperBase.youtubeTrailerId}';
                    if (await canLaunch(youtubeUrl)) {
                      await launch(youtubeUrl);
                    }
                  },
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        const Icon(
                          Icons.play_circle_outline,
                          color: Colors.yellow,
                          size: 65,
                        ),
                        Text(
                          movieDetail!.title!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'muli',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Overview'.toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: 35,
                        child: Text(
                          "${movieDetail?.overview}",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontFamily: 'muli'),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Release Year'.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'muli',
                                ),
                              ),
                              Text(
                                DateFormat.y().format(DateTime.parse(movieDetail!.releaseDate!)),
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    ?.copyWith(
                                  color: Colors.yellow[800],
                                  fontSize: 12,
                                  fontFamily: 'muli',
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Rating'.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'muli',
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                  ),
                                  const SizedBox(
                                    width: 3,
                                  ),
                                  Text(
                                    "${movieDetail?.voteAverage}",
                                    style: TextStyle(
                                      color: Colors.yellow[800],
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Vote Count'.toUpperCase(),
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'muli',
                                ),
                              ),
                              Text(
                                "${movieDetail?.voteCount}",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle2
                                    ?.copyWith(
                                  color: Colors.yellow[800],
                                  fontSize: 12,
                                  fontFamily: 'muli',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Genres'.toUpperCase(),
                        style: Theme.of(context).textTheme.caption?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'muli',
                        ),
                      ),
                      SizedBox(
                        height: 45,
                        child: ListView.separated(
                          separatorBuilder: (BuildContext context, int index) =>
                          const VerticalDivider(
                            color: Colors.transparent,
                            width: 5,
                          ),
                          scrollDirection: Axis.horizontal,
                          itemCount: genres.length,
                          itemBuilder: (context, index) {
                            Genre genre = genres[index];
                            return Column(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black45,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(25),
                                      ),
                                      color:  Colors.white,
                                    ),
                                    child: Text(
                                      genre.name!.toUpperCase(),
                                      style:const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color:Colors.black45,
                                        fontFamily: 'muli',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),
                      Text(
                        'Casts'.toUpperCase(),
                        style: Theme.of(context).textTheme.caption?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'muli',
                        ),
                      ),
                      CastsWidget(movie: widget.movie),
                      const SizedBox(height: 10),
                      Text(
                        'Rate Movie'.toUpperCase(),
                        style: Theme.of(context).textTheme.caption?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'muli',
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            Row(
                              children: <Widget>[
                                for(int i=0;i<10;i++)
                                _buildRateButton(i+1),
                                // _buildRateButton(2),
                                // _buildRateButton(3),
                                // _buildRateButton(4),
                                // _buildRateButton(5),
                                // _buildRateButton(6),
                                // _buildRateButton(7),
                                // _buildRateButton(8),
                                // _buildRateButton(9),
                                // _buildRateButton(10)
                              ],
                            ),
                           const SizedBox(
                              width: 10,
                            ),
                            Row(children: [
                              isSavingRating?Container(
                                  margin: const EdgeInsets.only(left: 10,top: 10),
                                  child: loadBox()):OutlinedButton(
                                  style: ButtonStyle(side: MaterialStateProperty.all(const BorderSide(color: Colors.yellow,width: 1))),
                                  onPressed: (){
                                    _saveRating();
                                  }, child:  Text('Save Rating',style: TextStyle(color:Colors.yellow[800] ),))
                            ],),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'recommendations'.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black45,
                          fontFamily: 'muli',
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Recommendations(movie: widget.movie),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }else{
     return Container();
   }

  }



}