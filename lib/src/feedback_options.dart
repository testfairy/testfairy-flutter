part of testfairy;

/// Feedback options returned after a feedback is sent.
class FeedbackOptions {
  /// Feedback user's email.
  String email;

  /// Feedback message.
  String text;

  /// Timestamp in session.
  double timestamp;

  /// Feedback number.
  int feedbackNo = 0;
}

/// Utility no argument function to use as an empty callback.
void emptyFunction() {}

/// Utility single [FeedbackOptions] argument function to use as an empty callback.
void emptyFeedbackOptionsFunction(FeedbackOptions feedbackContent) {}