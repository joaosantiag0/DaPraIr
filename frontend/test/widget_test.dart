import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/feed/feed_bloc.dart';
import 'package:frontend/presentation/bloc/places/places_bloc.dart';
import 'package:frontend/presentation/bloc/events/events_bloc.dart';
import 'package:frontend/presentation/bloc/social/social_bloc.dart';
import 'package:frontend/presentation/bloc/profile/profile_bloc.dart';
import 'package:frontend/presentation/bloc/forum/forum_bloc.dart';
import 'package:frontend/presentation/bloc/forum/forum_event.dart';
import 'package:frontend/presentation/bloc/forum/forum_state.dart';
import 'package:frontend/presentation/views/home/main_navigation_screen.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockFeedBloc extends MockBloc<FeedEvent, FeedState> implements FeedBloc {}
class MockPlacesBloc extends MockBloc<PlacesEvent, PlacesState> implements PlacesBloc {}
class MockEventsBloc extends MockBloc<EventsEvent, EventsState> implements EventsBloc {}
class MockSocialBloc extends MockBloc<SocialEvent, SocialState> implements SocialBloc {}
class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState> implements ProfileBloc {}
class MockForumBloc extends MockBloc<ForumEvent, ForumState> implements ForumBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockFeedBloc mockFeedBloc;
  late MockPlacesBloc mockPlacesBloc;
  late MockEventsBloc mockEventsBloc;
  late MockSocialBloc mockSocialBloc;
  late MockProfileBloc mockProfileBloc;
  late MockForumBloc mockForumBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockFeedBloc = MockFeedBloc();
    mockPlacesBloc = MockPlacesBloc();
    mockEventsBloc = MockEventsBloc();
    mockSocialBloc = MockSocialBloc();
    mockProfileBloc = MockProfileBloc();
    mockForumBloc = MockForumBloc();

    when(() => mockAuthBloc.state).thenReturn(Unauthenticated());
    when(() => mockFeedBloc.state).thenReturn(const FeedState());
    when(() => mockPlacesBloc.state).thenReturn(PlacesInitial());
    when(() => mockEventsBloc.state).thenReturn(const EventsState());
    when(() => mockSocialBloc.state).thenReturn(SocialInitial());
    when(() => mockProfileBloc.state).thenReturn(ProfileInitial());
    when(() => mockForumBloc.state).thenReturn(const ForumHomeLoaded(categories: [], highlightedTopics: []));
  });

  testWidgets('MainNavigationScreen smoke test and navigation rendering', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
          BlocProvider<FeedBloc>.value(value: mockFeedBloc),
          BlocProvider<PlacesBloc>.value(value: mockPlacesBloc),
          BlocProvider<EventsBloc>.value(value: mockEventsBloc),
          BlocProvider<SocialBloc>.value(value: mockSocialBloc),
          BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
          BlocProvider<ForumBloc>.value(value: mockForumBloc),
        ],
        child: const MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );
    await tester.pump();

    // Verify app title and navigation bar destinations
    expect(find.text('DáPraIr?'), findsWidgets);
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Locais'), findsOneWidget);
    expect(find.text('Eventos'), findsOneWidget);
    expect(find.text('Debates'), findsOneWidget);
    expect(find.text('Social'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });
}
