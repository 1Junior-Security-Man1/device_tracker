import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:device_tracker/helper/validators.dart';
import 'package:device_tracker/repository/user_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:device_tracker/login/bloc/login_event.dart';
import 'package:device_tracker/login/bloc/login_state.dart';

/// BLoC responsible for the business logic behind the login process. In particular this BLoC will
/// map the incoming [LoginEvent] to the correct [LoginState].
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  /// Authentication repository that provides to the user the methods to sign-in
  /// with credentials and to sign-in with a Google account.
  final UserRepository userRepository;

  LoginBloc({required this.userRepository}) : assert(userRepository != null), super(LoginState.empty());

  @override
  LoginState get initialState => LoginState.empty();

  // Overriding transformEvents in order to debounce the EmailChanged and PasswordChanged events
  // so that we give the user some time to stop typing before validating the input.
  @override
  Stream<Transition<LoginEvent, LoginState>> transformEvents(Stream<LoginEvent> events, TransitionFunction<LoginEvent, LoginState> transitionFn,) {
    final nonDebounceStream = events.where((event) {
      return (event is! EmailChanged && event is! PasswordChanged);
    });
    final debounceStream = events.where((event) {
      return (event is EmailChanged || event is PasswordChanged);
    }).debounceTime(Duration(milliseconds: 300));
    return super.transformEvents(nonDebounceStream.mergeWith([debounceStream]),
      transitionFn,
    );
  }

  @override
  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is LoginWithCredentialsPressed) {
      yield* _mapLoginWithCredentialsPressedToState(
        email: event.email,
        password: event.password,
      );
    }
  }

  Stream<LoginState> _mapEmailChangedToState(String email) async* {
    yield state.update(
      isEmailValid: Validators.isValidEmail(email),
    );
  }

  Stream<LoginState> _mapPasswordChangedToState(String password) async* {
    yield state.update(
      isPasswordValid: Validators.isValidPassword(password),
    );
  }

  Stream<LoginState> _mapLoginWithCredentialsPressedToState({
    required String email,
    required String password,
  }) async* {
    yield LoginState.loading();
    try {
      await userRepository.signInWithCredentials(email: email, password: password);
      yield LoginState.success();
    } catch (_) {
      yield LoginState.failure();
    }
  }
}