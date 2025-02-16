import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movies/view_model/auth_view_model.dart';
import 'package:movies/view_model/home_view_model.dart';
import 'package:movies/view_model/movies_dropDown_view_model.dart';
import 'package:movies/view_model/movies_category_view_model.dart';
import 'package:movies/view_model/movieslist_view_model.dart';
import 'package:movies/view_model/peronlist_view_model.dart';
import 'package:movies/view_model/search_moviestvshow_view_model.dart';
import 'package:movies/view_model/tvShow_category_view_model.dart';
import 'package:movies/view_model/tvShows_dropDown_view_model.dart';
import 'package:movies/view_model/tvshowslist_view-model.dart';
import 'package:movies/view_model/youtube_view_model/episodes_list_view_model.dart';
import 'package:movies/view_model/youtube_view_model/trailer_view_model.dart';
import 'package:movies/view_model/youtube_view_model/tvshow_season_view_model.dart';
import 'package:movies/view_model/youtube_view_model/youtube_videos_view_model.dart';
import 'utilities/routes/routes.dart';
import 'utilities/routes/routes_name.dart';
import 'package:provider/provider.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => MoviesListViewModel()),
        ChangeNotifierProvider(create: (_) => TvShowsListViewModel()),
        ChangeNotifierProvider(create: (_) => PersonListViewModel()),
        ChangeNotifierProvider(create: (_) => MoviesDropDownViewModel()),
        ChangeNotifierProxyProvider<MoviesDropDownViewModel,
            MoviesCategoryViewModel>(
          create: (context) => MoviesCategoryViewModel(
            Provider.of<MoviesDropDownViewModel>(context, listen: false),
          ),
          update: (context, moviesDropDownProvider,
                  previousMoviesCategoryProvider) =>
              previousMoviesCategoryProvider ??
              MoviesCategoryViewModel(moviesDropDownProvider),
        ),
        ChangeNotifierProvider(create: (_) => TvShowsDropDownViewModel()),
        ChangeNotifierProxyProvider<TvShowsDropDownViewModel,
            TvShowsCategoryViewModel>(
          create: (context) => TvShowsCategoryViewModel(
              Provider.of<TvShowsDropDownViewModel>(context, listen: false)),
          update: (context, tvShowsDropDownProvider,
                  previousTvShowsCategoryProvider) =>
              previousTvShowsCategoryProvider ??
              TvShowsCategoryViewModel(tvShowsDropDownProvider),
        ),
        ChangeNotifierProvider(create: (_) => YoutubeVideosViewModel()),
        ChangeNotifierProvider(create: (_) => TrailerViewModel()),
        ChangeNotifierProvider(create: (_) => TvShowSeasonViewModel()),
        ChangeNotifierProvider(create: (_) => EpisodesListViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(
            create: (context) => SearchMoviesTvShowViewModel()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: RoutesName.splashScreen,
        onGenerateRoute: Routes.generateRoutes,
        home: Scaffold(
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}

/// ChangeNotifierProxyProvider:=>refer to the Provider which allow to pass the instance of ChangeNotifier class
/// to another ChangeNotifier class constructor as a parameter
/// Above we have used the ChangeNotifierProxyProvider in which we pass the instance of the dropDownViewModel to
/// the MoviesCategoryViewModel constructor as a parameter
