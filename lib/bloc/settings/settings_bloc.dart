
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pingme/bloc/settings/%20settings_event.dart';
import 'package:pingme/bloc/settings/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState>{

  SettingsBloc() : super(SettingsState(isDark: false)){

    on<ToggleThemeEvent>((event, emit) {
      emit(SettingsState(isDark: !state.isDark));
    },);

  }

}