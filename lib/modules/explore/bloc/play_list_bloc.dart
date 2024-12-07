import 'dart:async';

import 'package:ai_music/common/log_util.dart';
import 'package:bloc/bloc.dart';

import '../repos/play_list_repo.dart';
import 'play_list_event.dart';
import 'play_list_state.dart';

class PlayListBloc extends Bloc<PlayListEvent, PlayListState> {
  static const String _tag = "PlayListBloc";

  final PlayListRepo playListRepo;

  PlayListBloc({required this.playListRepo}) : super(PlayListInitial()) {
    on<RequestHotPlayListEvent>(_onRequestHotPlayListEvent);
    on<RequestHighQualityPlayListEvent>(_onRequestHighQualityPlayListEvent);
  }

  void _onRequestHotPlayListEvent(
      RequestHotPlayListEvent event, Emitter<PlayListState> emit) async {
    LogUtil.i("requestHotPlayListEvent", tag: _tag);
    try {
      emit(RequestHotPlayListLoading());
      final playListCatagories = await playListRepo.requestHotPlayList();
      LogUtil.i("playListCatagories: ${playListCatagories.tags.length}",
          tag: _tag);
      emit(RequestHotPlayListSuccess(playListCatagories));
    } catch (e, stackTrace) {
      LogUtil.e("错误详情: $e\n$stackTrace", tag: _tag);
      emit(RequestHotPlayListError(e.toString()));
    }
  }

  void _onRequestHighQualityPlayListEvent(RequestHighQualityPlayListEvent event,
      Emitter<PlayListState> emit) async {
    LogUtil.i("requestHighQualityPlayListEvent", tag: _tag);
    try {
      emit(RequestHighQualityPlayListLoading());
      final playListHighQulity =
          await playListRepo.requestHighQualityPlayList();
      LogUtil.i("playListHighQulity: ${playListHighQulity.playlists?.length}",
          tag: _tag);
      emit(RequestHighQualityPlayListSuccess(playListHighQulity));
    } catch (e, stackTrace) {
      LogUtil.e("错误详情: $e\n$stackTrace", tag: _tag);
      emit(RequestHighQualityPlayListError(e.toString()));
    }
  }
}