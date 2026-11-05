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
import 'package:frontend/presentation/components/responsive_container.dart';
import 'package:frontend/presentation/views/home/main_navigation_screen.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}
class MockFeedBloc extends MockBloc<FeedEvent, FeedState> implements FeedBloc {}
class MockPlacesBloc extends MockBloc<PlacesEvent, PlacesState> implements PlacesBloc {}
class MockEventsBloc extends MockBloc<EventsEvent, EventsState> implements EventsBloc {}
class MockSocialBloc extends MockBloc<SocialEvent, SocialState> implements SocialBloc {}
class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState> implements ProfileBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockFeedBloc mockFeedBloc;
  late MockPlacesBloc mockPlacesBloc;
  late MockEventsBloc mockEventsBloc;
  late MockSocialBloc mockSocialBloc;
  late MockProfileBloc mockProfileBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockFeedBloc = MockFeedBloc();
    mockPlacesBloc = MockPlacesBloc();
    mockEventsBloc = MockEventsBloc();
    mockSocialBloc = MockSocialBloc();
    mockProfileBloc = MockProfileBloc();

    when(() => mockAuthBloc.state).thenReturn(Unauthenticated());
    when(() => mockFeedBloc.state).thenReturn(const FeedState());
    when(() => mockPlacesBloc.state).thenReturn(PlacesInitial());
    when(() => mockEventsBloc.state).thenReturn(const EventsState());
    when(() => mockSocialBloc.state).thenReturn(SocialInitial());
    when(() => mockProfileBloc.state).thenReturn(ProfileInitial());
  });

  Widget createTestWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<FeedBloc>.value(value: mockFeedBloc),
        BlocProvider<PlacesBloc>.value(value: mockPlacesBloc),
        BlocProvider<EventsBloc>.value(value: mockEventsBloc),
        BlocProvider<SocialBloc>.value(value: mockSocialBloc),
        BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
      ],
      child: const MaterialApp(
        home: MainNavigationScreen(),
      ),
    );
  }

  testWidgets('Renders bottom NavigationBar on mobile screens (< 768px)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('Renders side NavigationRail on tablet/desktop screens (>= 768px)', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Locais'), findsOneWidget);
  });

  testWidgets('ResponsiveContainer constrains child width on wide screens', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResponsiveContainer.narrow(
            child: SizedBox(height: 50, key: Key('test_box')),
          ),
        ),
      ),
    );

    final box = tester.renderObject<RenderBox>(find.byKey(const Key('test_box')));
    expect(box.size.width, lessThanOrEqualTo(480));
  });
}
