import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart'; // Adapte o import
import 'active_store_state.dart';

class ActiveStoreCubit extends Cubit<ActiveStoreState> {
  final RealtimeRepository _realtimeRepository;
  late final StreamSubscription _storeSubscription;

  ActiveStoreCubit({required RealtimeRepository realtimeRepository})
      : _realtimeRepository = realtimeRepository,
        super(ActiveStoreInitial()) {

    _storeSubscription = _realtimeRepository.onActiveStoreUpdated.listen((store) {
      if (store != null) {
        emit(ActiveStoreLoaded(store));
      }
    });
  }

  @override
  Future<void> close() {
    _storeSubscription.cancel();
    return super.close();
  }
}