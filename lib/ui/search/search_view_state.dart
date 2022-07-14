import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_view_state.freezed.dart';

@freezed
class SearchViewState with _$SearchViewState {
  factory SearchViewState({
    required String query,
    required List<SearchViewEvent> events,
  }) = _SearchViewState;

  SearchViewState._();

  SearchViewState enqueueEvent(SearchViewEvent event) {
    return copyWith(events: [...events, event]);
  }
}

@freezed
class SearchViewEvent with _$SearchViewEvent {
  factory SearchViewEvent.emptyQuery() = SearchViewEventEmptyQuery;

  factory SearchViewEvent.waitSearch() = SearchViewEventWaitSearch;
}
