import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:neend_companion/models/feedback_entry.dart';
import 'package:neend_companion/data/repositories/feedback_repository.dart';

class FeedbackState {
  final List<FeedbackEntry> history;
  final bool isLoading;

  FeedbackState({this.history = const [], this.isLoading = false});

  FeedbackState copyWith({List<FeedbackEntry>? history, bool? isLoading}) {
    return FeedbackState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FeedbackController extends StateNotifier<FeedbackState> {
  final FeedbackRepository _feedbackRepo = FeedbackRepository();

  FeedbackController() : super(FeedbackState()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    state = state.copyWith(isLoading: true);
    final history = await _feedbackRepo.getFeedback();
    state = state.copyWith(isLoading: false, history: history);
  }

  Future<void> saveFeedback({
    required FeedbackType type,
    required String rating,
    required List<String> interventionIds,
    int? sleepDurationMinutes,
    String? notes,
  }) async {
    final entry = FeedbackEntry(
      id: const Uuid().v4(),
      type: type,
      rating: rating,
      interventionIds: interventionIds,
      sleepDurationMinutes: sleepDurationMinutes,
      notes: notes,
      createdAt: DateTime.now(),
    );

    await _feedbackRepo.saveFeedback(entry);
    final newHistory = [entry, ...state.history];
    state = state.copyWith(history: newHistory);
  }

  List<FeedbackEntry> getFeedbackHistory(int limit) {
    return state.history.take(limit).toList();
  }
}

final feedbackControllerProvider =
    StateNotifierProvider<FeedbackController, FeedbackState>((ref) {
  return FeedbackController();
});
