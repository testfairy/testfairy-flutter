// @dart = 2.12
part of testfairy;

/// Feedback content returned after a feedback is sent.
class FeedbackContent {
  /// Feedback user's email.
  final String email;

  /// Feedback message.
  final String text;

  /// Timestamp in session, in seconds.
  final double timestamp;

  /// Feedback number.
  final int feedbackNo;

  /// Constructor
  FeedbackContent(this.email, this.text, this.timestamp, this.feedbackNo);
}

/// Utility no argument function to use as an empty callback.
void emptyFunction() {}

/// Utility single [FeedbackContent] argument function to use as an empty callback.
void emptyFeedbackContentFunction(FeedbackContent feedbackContent) {}

/// Common interface for all feedback form fields (this is just a proxy for the native interface
///
/// You must use one of the concrete classes.
abstract class FeedbackFormField {
  Map<String, dynamic> toMap();
}

/// A single line text input that accepts strings
class StringFeedbackFormField implements FeedbackFormField {
  /// The attribute name this fields value will set
  final String attribute;

  /// Placeholder value shown when the field is empty
  final String placeholder;

  /// Default value set when the form is initialized for the first time
  final String defaultValue;

  /// Constructor
  StringFeedbackFormField(this.attribute, this.placeholder, this.defaultValue);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': 'StringFeedbackFormField',
      'attribute': attribute,
      'placeholder': placeholder,
      'defaultValue': defaultValue
    };
  }
}

/// A multi line text input that accepts strings
class TextAreaFeedbackFormField implements FeedbackFormField {
  /// The attribute name this fields value will set
  final String attribute;

  /// Placeholder value shown when the field is empty
  final String placeholder;

  /// Default value set when the form is initialized for the first time
  final String defaultValue;

  /// Constructor
  TextAreaFeedbackFormField(
      this.attribute, this.placeholder, this.defaultValue);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': 'TextAreaFeedbackFormField',
      'attribute': attribute,
      'placeholder': placeholder,
      'defaultValue': defaultValue
    };
  }
}

/// A drop-down or picker of multiple values
class SelectFeedbackFormField implements FeedbackFormField {
  /// The attribute name this fields value will set
  final String attribute;

  /// A human readable label that describes purpose of th
  final String label;

  /// Selection options. Keys will be shown in UI in a human readable form, values will be interpreted as attributes and sent to server.
  final Map<String, String> values;

  /// Default value set when the form is initialized for the first time
  final String defaultValue;

  /// Constructor
  SelectFeedbackFormField(
      this.attribute, this.label, this.values, this.defaultValue);

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': 'SelectFeedbackFormField',
      'attribute': attribute,
      'label': label,
      'defaultValue': defaultValue,
      'values': values
    };
  }
}
