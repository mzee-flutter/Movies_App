import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:movies/utilities/app_color.dart';
import 'package:movies/view/full_tvshow_info_screen.dart';
import 'package:provider/provider.dart';

import '../resources/components/media_card.dart';
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
    return Scaffold(
      backgroundColor: appColor,
      appBar: AppBar(
        backgroundColor: appColor,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Same note as MoviesCategoryScreen's dropdown: `getButtonList()`
          // (named differently from Movies' `buttonsList()` for what looks
          // like the identical job — worth unifying the two names once
          // you're consolidating) builds a widget from inside the
          // ViewModel. Not touched here since I don't have
          // TvShowsDropDownViewModel's source, but it's the same MVVM
          // boundary crossing flagged on the movies screen.
          Consumer<TvShowsDropDownViewModel>(
            builder: (context, tvShowsDropDownProvider, child) {
              return tvShowsDropDownProvider.getButtonList();
            },
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(5.w),
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
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 7.w,
                          mainAxisSpacing: 7.h,
                          mainAxisExtent: 177.h,
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
                          return MediaCard(
                            title: tvShow.name ?? 'Unknown',
                            posterPath: tvShow.posterPath,
                            dateLabel: tvShow.firstAirDate ?? '',
                            voteAverage: tvShow.voteAverage ?? 0.0,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullTvShowInfoScreen(tvShow: tvShow),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
