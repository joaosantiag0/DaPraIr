import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/profile/profile_bloc.dart';
import 'package:frontend/domain/entities/user_profile.dart';
import 'package:frontend/domain/entities/accessibility_profile.dart';
import 'package:frontend/domain/repositories/auth_repository.dart';
import 'package:frontend/domain/repositories/user_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockUserRepository mockUserRepo;

  const testUser = UserProfile(
    id: 'u-1',
    name: 'Ana Silva',
    email: 'ana@daprair.com',
    handle: 'ana_silva',
  );

  const testProfile = AccessibilityProfile(
    userId: 'u-1',
    disabilityTypes: ['WHEELCHAIR_MANUAL'],
    visibility: 'PRIVATE',
  );

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockUserRepo = MockUserRepository();
  });

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] on LoginEvent',
      build: () {
        when(() => mockAuthRepo.login(email: 'ana@daprair.com', password: 'Password123!'))
            .thenAnswer((_) async => testUser);
        return AuthBloc(repository: mockAuthRepo);
      },
      act: (bloc) => bloc.add(const LoginEvent(email: 'ana@daprair.com', password: 'Password123!')),
      expect: () => [
        AuthLoading(),
        const Authenticated(testUser),
      ],
    );
  });

  group('ProfileBloc', () {
    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] on UpdateProfileEvent',
      build: () {
        when(
          () => mockUserRepo.updateAccessibilityProfile(
            disabilityTypes: ['WHEELCHAIR_MANUAL'],
            assistanceNeeds: [],
            visibility: 'PRIVATE',
            consentGranted: true,
          ),
        ).thenAnswer((_) async => testProfile);
        return ProfileBloc(repository: mockUserRepo);
      },
      act: (bloc) => bloc.add(const UpdateProfileEvent(
        disabilityTypes: ['WHEELCHAIR_MANUAL'],
        assistanceNeeds: [],
        visibility: 'PRIVATE',
        consentGranted: true,
      )),
      expect: () => [
        ProfileLoading(),
        const ProfileLoaded(profile: testProfile),
      ],
    );
  });
}
