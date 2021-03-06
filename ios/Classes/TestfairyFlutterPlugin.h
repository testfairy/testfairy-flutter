#import <Flutter/Flutter.h>

@interface TestfairyFlutterPlugin : NSObject<FlutterPlugin>

// Static factory required by Flutter
+ (void) registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;

// Call resolver for all integrations
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;

// Integrations
- (void) setFeedbackOptions: (NSString*)defaultText browserUrl:(NSString*)browserUrl emailFieldVisible:(NSNumber*)emailFieldVisible emailMandatory:(NSNumber*)emailMandatory  takeScreenshotButtonVisible:(NSNumber*)takeScreenshotButtonVisible recordVideoButtonVisible:(NSNumber*)recordVideoButtonVisible feedbackFormFields:(NSArray*)feedbackFormFields;
    
- (void) addNetworkEvent: (NSString*)uri method:(NSString*)method code:(NSNumber*)code startTimeMillis:(NSNumber*)startTimeMillis endTimeMillis:(NSNumber*)endTimeMillis requestSize:(NSNumber*)requestSize responseSize:(NSNumber*)responseSize errorMessage:(id)errorMessage requestHeaders:(NSString*)requestHeaders requestBody:(FlutterStandardTypedData*)requestBody responseHeaders:(NSString*)responseHeaders responseBody:(FlutterStandardTypedData*)responseBody;

//- (void) takeScreenshot;

- (void) begin:(NSString*)appToken;

- (void) begin:(NSString*)appToken withOptions:(NSDictionary*)options;

- (void) addUserInteraction:(NSString*)kind label:(NSString*)label info:(NSDictionary*)info;

- (void) setServerEndpoint:(NSString*)endpoint;

- (NSString*) version;

- (void) sendUserFeedback:(NSString*)feedback;

- (void) addCheckpoint:(NSString*)cp;

- (void) addEvent:(NSString*)e;

- (void) setCorrelationId:(NSString*)cid;

- (void) identify:(NSString*)cid withTraits:(NSDictionary*)traits;

- (void) identify:(NSString*)cid;

- (void) setUserId:(NSString*)uid;

- (void) setAttribute:(NSString*)key withValue:(NSString*)value;

- (NSString*) sessionUrl;

- (void) showFeedbackForm;

- (void) stop;

- (void) resume;

- (void) pause;

- (void) logError:(NSString*)error;

- (void) log:(NSString*)msg;

- (void) setScreenName:(NSString*)name;

- (NSNumber*) didLastSessionCrash;

- (void) enableCrashHandler;

- (void) disableCrashHandler;

- (void) enableMetric:(NSString*)metric;

- (void) disableMetric:(NSString*)metric;

- (void) enableVideo:(NSString*)metric quality:(NSString*)quality framesPerSecond:(NSNumber*)framesPerSecond;

- (void) disableVideo;

- (void) enableFeedbackForm:(NSString*)method;

- (void) disableFeedbackForm;

- (void) setMaxSessionLength:(NSNumber*)seconds;

- (void) disableAutoUpdate;

- (void) bringFlutterToFront;

- (void) installCrashHandler:(NSString*)appToken;

- (void) installFeedbackHandler:(NSString*)appToken;

@end
