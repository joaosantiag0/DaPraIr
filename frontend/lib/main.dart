import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/network/dio_client.dart';
import 'data/local/places_dao.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/places_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'data/repositories/social_repository_impl.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'data/repositories/events_repository_impl.dart';
import 'data/repositories/feed_repository_impl.dart';
import 'data/repositories/reports_repository_impl.dart';
import 'data/repositories/forum_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/places_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/repositories/social_repository.dart';
import 'domain/repositories/chat_repository.dart';
import 'domain/repositories/events_repository.dart';
import 'domain/repositories/feed_repository.dart';
import 'domain/repositories/reports_repository.dart';
import 'domain/repositories/forum_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/places/places_bloc.dart';
import 'presentation/bloc/reviews/reviews_bloc.dart';
import 'presentation/bloc/social/social_bloc.dart';
import 'presentation/bloc/chat/chat_bloc.dart';
import 'presentation/bloc/events/events_bloc.dart';
import 'presentation/bloc/feed/feed_bloc.dart';
import 'presentation/bloc/profile/profile_bloc.dart';
import 'presentation/bloc/forum/forum_bloc.dart';
import 'presentation/views/home/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final dioClient = DioClient();
  final placesDao = PlacesDao();

  final placesRepo = PlacesRepositoryImpl(dioClient: dioClient, placesDao: placesDao);
  final authRepo = AuthRepositoryImpl(dioClient: dioClient);
  final userRepo = UserRepositoryImpl(dioClient: dioClient);
  final socialRepo = SocialRepositoryImpl(dioClient: dioClient);
  final chatRepo = ChatRepositoryImpl(dioClient: dioClient);
  final eventsRepo = EventsRepositoryImpl(dioClient.dio);
  final feedRepo = FeedRepositoryImpl(dioClient.dio);
  final reportsRepo = ReportsRepositoryImpl(dioClient.dio);
  final forumRepo = ForumRepositoryImpl(dio: dioClient.dio);

  runApp(
    DaPraIrApp(
      placesRepository: placesRepo,
      authRepository: authRepo,
      userRepository: userRepo,
      socialRepository: socialRepo,
      chatRepository: chatRepo,
      eventsRepository: eventsRepo,
      feedRepository: feedRepo,
      reportsRepository: reportsRepo,
      forumRepository: forumRepo,
    ),
  );
}

class DaPraIrApp extends StatefulWidget {
  final PlacesRepository? placesRepository;
  final AuthRepository? authRepository;
  final UserRepository? userRepository;
  final SocialRepository? socialRepository;
  final ChatRepository? chatRepository;
  final EventsRepository? eventsRepository;
  final FeedRepository? feedRepository;
  final ReportsRepository? reportsRepository;
  final ForumRepository? forumRepository;

  const DaPraIrApp({
    super.key,
    this.placesRepository,
    this.authRepository,
    this.userRepository,
    this.socialRepository,
    this.chatRepository,
    this.eventsRepository,
    this.feedRepository,
    this.reportsRepository,
    this.forumRepository,
  });

  @override
  State<DaPraIrApp> createState() => _DaPraIrAppState();
}

class _DaPraIrAppState extends State<DaPraIrApp> {
  bool _isHighContrast = false;

  void toggleHighContrast() {
    setState(() {
      _isHighContrast = !_isHighContrast;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dioClient = DioClient();
    final placesDao = PlacesDao();

    final placesRepo = widget.placesRepository ?? PlacesRepositoryImpl(dioClient: dioClient, placesDao: placesDao);
    final authRepo = widget.authRepository ?? AuthRepositoryImpl(dioClient: dioClient);
    final userRepo = widget.userRepository ?? UserRepositoryImpl(dioClient: dioClient);
    final socialRepo = widget.socialRepository ?? SocialRepositoryImpl(dioClient: dioClient);
    final chatRepo = widget.chatRepository ?? ChatRepositoryImpl(dioClient: dioClient);
    final eventsRepo = widget.eventsRepository ?? EventsRepositoryImpl(dioClient.dio);
    final feedRepo = widget.feedRepository ?? FeedRepositoryImpl(dioClient.dio);
    final reportsRepo = widget.reportsRepository ?? ReportsRepositoryImpl(dioClient.dio);
    final forumRepo = widget.forumRepository ?? ForumRepositoryImpl(dio: dioClient.dio);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<PlacesRepository>.value(value: placesRepo),
        RepositoryProvider<AuthRepository>.value(value: authRepo),
        RepositoryProvider<ForumRepository>.value(value: forumRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(repository: authRepo)..add(CheckAuthStatusEvent()),
          ),
          BlocProvider<PlacesBloc>(
            create: (_) => PlacesBloc(repository: placesRepo),
          ),
          BlocProvider<ReviewsBloc>(
            create: (_) => ReviewsBloc(repository: placesRepo),
          ),
          BlocProvider<SocialBloc>(
            create: (_) => SocialBloc(repository: socialRepo),
          ),
          BlocProvider<ChatBloc>(
            create: (_) => ChatBloc(repository: chatRepo),
          ),
          BlocProvider<EventsBloc>(
            create: (_) => EventsBloc(eventsRepo),
          ),
          BlocProvider<FeedBloc>(
            create: (_) => FeedBloc(
              feedRepository: feedRepo,
              reportsRepository: reportsRepo,
            ),
          ),
          BlocProvider<ProfileBloc>(
            create: (_) => ProfileBloc(repository: userRepo),
          ),
          BlocProvider<ForumBloc>(
            create: (_) => ForumBloc(forumRepository: forumRepo),
          ),
        ],
        child: MaterialApp(
          title: 'DáPraIr?',
          debugShowCheckedModeBanner: false,
          theme: _isHighContrast ? AppTheme.highContrastTheme : AppTheme.lightTheme,
          home: MainNavigationScreen(
            onToggleHighContrast: toggleHighContrast,
            isHighContrast: _isHighContrast,
          ),
        ),
      ),
    );
  }
}
