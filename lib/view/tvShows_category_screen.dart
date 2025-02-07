import 'package:flutter/material.dart';
import 'package:movies/utilities/app_color.dart';
import 'package:movies/view/full_tvshow_info_screen.dart';
import 'package:movies/view/home_screen.dart';
import 'package:provider/provider.dart';
import '../resources/constants.dart';
import '../view_model/tvShow_category_view_model.dart';
import '../view_model/tvShows_dropDown_view_model.dart';

class TvShowsCategoryScreen extends StatefulWidget {
  const TvShowsCategoryScreen({super.key});
  @override
  State<TvShowsCategoryScreen> createState() => TvShowsCategoryScreenState();
}

class TvShowsCategoryScreenState extends State<TvShowsCategoryScreen> {
  @override
  void initState() {
    super.initState();

    final tvShowsCategoryProvider =
        Provider.of<TvShowsCategoryViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      tvShowsCategoryProvider.fetchDifferentTvShowsCategory();
    });
  }

  bool _isTvShowsNearEnd(ScrollNotification scrollInfo) {
    return scrollInfo.metrics.pixels >=
        scrollInfo.metrics.maxScrollExtent * 0.95;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      backgroundColor: appColor,
      appBar: AppBar(
        backgroundColor: appColor,
        elevation: 1,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          Consumer<TvShowsDropDownViewModel>(
            builder: (context, tvShowsDropDownProvider, child) {
              return tvShowsDropDownProvider.getButtonList();
            },
          ),
          SizedBox(
            width: height * .02,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              Expanded(
                child: Consumer<TvShowsCategoryViewModel>(
                  builder: (context, tvShowsCategoryProvider, child) {
                    if (tvShowsCategoryProvider.allTvShows.isEmpty &&
                        !tvShowsCategoryProvider.isFetching) {
                      return notFoundMessage;
                    }
                    return NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (_isTvShowsNearEnd(scrollInfo)) {
                          tvShowsCategoryProvider
                              .fetchDifferentTvShowsCategory();
                        }
                        return true;
                      },
                      child: GridView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: tvShowsCategoryProvider.allTvShows.length +
                            (tvShowsCategoryProvider.isFetching ? 1 : 0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 7,
                          mainAxisSpacing: 7,
                          mainAxisExtent: 177,
                        ),
                        itemBuilder: (context, index) {
                          if (index ==
                              tvShowsCategoryProvider.allTvShows.length) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          }
                          final tvShow =
                              tvShowsCategoryProvider.allTvShows[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FullTvShowInfoScreen(tvShow: tvShow),
                                ),
                              );
                            },
                            child: MoviesInfoContainer(
                              height: height,
                              title: tvShow.name ?? 'Unknown',
                              posterUrl: tvShow.posterPath,
                              year: tvShow.firstAirDate ?? '---',
                              averageVote: tvShow.voteAverage ?? 0.0,
                              icon: Icons.star,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
