part of testfairy;

/// Feedback options returned after a feedback is sent.
class FeedbackOptions {
  /// Feedback user's email.
  final String email;

  /// Feedback message.
  final String text;

  /// Timestamp in session.
  final double timestamp;

  /// Feedback number.
  final int feedbackNo;

  /// Constructor
  FeedbackOptions(this.email, this.text, this.timestamp, this.feedbackNo);
}

/// Utility no argument function to use as an empty callback.
void emptyFunction() {}

/// Utility single [FeedbackOptions] argument function to use as an empty callback.
void emptyFeedbackOptionsFunction(FeedbackOptions feedbackContent) {}
