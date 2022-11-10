
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/Super_base.dart';
import 'package:movie_app/models/Movie.dart';
import 'package:movie_app/models/castList.dart';

class CastsWidget extends StatefulWidget {
  final Movie movie;
  const CastsWidget({Key? key, required this.movie}) : super(key: key);

  @override
  State<CastsWidget> createState() => _CastsWidgetState();
}

class _CastsWidgetState extends State<CastsWidget> with SuperBase {
  List<Cast> castList=[];
  bool isLoading=true;
  Future<void> _loadMovieCastList(){
    return ajax(url: "/movie/${widget.movie.id}/credits",
        context: context,
        onValue: (response,v){
          setState(() {
            castList = (response["cast"] as Iterable?)?.map((e){
              return Cast.fromJson(e);
            }).toList() ?? [];
          });

        },error: (s,v){

        },onEnd: (){
          setState(() {
            isLoading=false;
          });
        });
  }

  @override
  void initState() {
    _loadMovieCastList();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return isLoading?Center(child: loadBox()):SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) =>
        const VerticalDivider(
          color: Colors.transparent,
          width: 5,
        ),
        itemCount: castList.length,
        itemBuilder: (context, index) {
          Cast cast = castList[index];
          return Column(
            children: <Widget>[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(100),
                ),
                elevation: 3,
                child: ClipRRect(
                  child: CachedNetworkImage(
                    imageUrl:
                    'https://image.tmdb.org/t/p/w200${cast.profilePath}',
                    imageBuilder:
                        (context, imageBuilder) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                              Radius.circular(100)),
                          image: DecorationImage(
                            image: imageBuilder,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                    placeholder: (context, url) =>
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Center(
                            child: Platform.isAndroid
                                ? const CircularProgressIndicator()
                                : const CupertinoActivityIndicator(),
                          ),
                        ),
                    errorWidget: (context, url, error) =>
                        Container(
                          width: 80,
                          height: 80,
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
              Center(
                child: Text(
                  cast.name!.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 8,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    cast.character!.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
