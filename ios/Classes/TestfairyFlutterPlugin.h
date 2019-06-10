#import <Flutter/Flutter.h>

@interface TestfairyFlutterPlugin : NSObject<FlutterPlugin>

// Static factory required by Flutter
+ (void) registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;

+ (void) takeScreenshot;

// Call resolver for all integrations
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;

// Integrations
- (void) addNetworkEvent: (NSString*)uri method:(NSString*)method code:(NSNumber*)code startTimeInMillis:(NSNumber*)startTimeInMillis endTimeInMillis:(NSNumber*)endTimeInMillis requestSize:(NSNumber*)requestSize responseSize:(NSNumber*)responseSize errorMessage:(NSString*)errorMessage;

- (void) sendScreenshot:(FlutterStandardTypedData*)pixels width:(NSNumber*)width height:(NSNumber*)height;

- (void) begin:(NSString*)appToken;

- (void) begin:(NSString*)appToken withOptions:(NSDictionary*)options;

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

- (void) bringFlutterToFront;

@end
