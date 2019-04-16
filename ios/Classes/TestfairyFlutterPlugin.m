#import "TestfairyFlutterPlugin.h"
#import "TestFairy.h"

@implementation TestfairyFlutterPlugin {
//    private WeakReference<Context> contextWeakReference = new WeakReference<>(null);
//    private WeakReference<MethodChannel> methodChannelWeakReference = new WeakReference<>(null);
//    private WeakReference<Activity> activityWeakReference = new WeakReference<>(null);
//    private WeakReference<FlutterView> flutterViewWeakReference = new WeakReference<>(null);
    
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
            methodChannelWithName:@"testfairy"
            binaryMessenger:[registrar messenger]];
    TestfairyFlutterPlugin* instance = [[TestfairyFlutterPlugin alloc] init];
    
//    [channel setMethodCallHandler:^(FlutterMethodCall *call, FlutterResult result) {
//        [instance handleMethodCall:call result:result];
//    }];
    
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    @try {
        NSDictionary* args = nil;
        if (call.arguments != nil && [call.arguments isKindOfClass:[NSDictionary class]]) {
            args = call.arguments;
        }
        
        if ([@"begin" isEqualToString:call.method]) {
            [self begin:call.arguments];
            result(nil);
        } else if ([@"beginWithOptions" isEqualToString:call.method]) {
            [self begin:[args valueForKey:@"appToken"] withOptions:[args valueForKey:@"options"]];
            result(nil);
        } else if ([@"setServerEndpoint" isEqualToString:call.method]) {
            [self setServerEndpoint:call.arguments];
            result(nil);
        } else if ([@"getVersion" isEqualToString:call.method]) {
            result([self version]);
        } else {
            result(FlutterMethodNotImplemented);
        }
    }
    @catch (NSException* exception) {
        NSLog(@"Exception: %@", exception.reason);
        result([FlutterError errorWithCode:[[exception class] description]
                                   message:exception.reason
                                   details:nil]);
    }
    @finally {
    }
    
//    switch (call.method) {
//        case "sendUserFeedback":
//            sendUserFeedback((String) call.arguments());
//            result.success(null);
//            break;
//        case "addCheckpoint":
//            addCheckpoint((String) call.arguments());
//            result.success(null);
//            break;
//        case "addEvent":
//            addEvent((String) call.arguments());
//            result.success(null);
//            break;
//        case "setCorrelationId":
//            setCorrelationId((String) call.arguments());
//            result.success(null);
//            break;
//        case "identifyWithTraits":
//            identifyWithTraits((String) args.get("id"), (Map) args.get("traits"));
//            result.success(null);
//            break;
//        case "identify":
//            identify((String) call.arguments());
//            result.success(null);
//            break;
//        case "setUserId":
//            setUserId((String) call.arguments());
//            result.success(null);
//            break;
//        case "setAttribute":
//            setAttribute((String) args.get("key"), (String) args.get("value"));
//            result.success(null);
//            break;
//        case "getSessionUrl":
//            result.success(getSessionUrl());
//            break;
//        case "showFeedbackForm":
//            showFeedbackForm();
//            result.success(null);
//            break;
//        case "stop":
//            stop();
//            result.success(null);
//            break;
//        case "resume":
//            resume();
//            result.success(null);
//            break;
//        case "pause":
//            pause();
//            result.success(null);
//            break;
//        case "log":
//            log((String) call.arguments());
//            result.success(null);
//            break;
//        case "setScreenName":
//            setScreenName((String) call.arguments());
//            result.success(null);
//            break;
//        case "didLastSessionCrash":
//            result.success(didLastSessionCrash());
//            break;
//        case "enableCrashHandler":
//            enableCrashHandler();
//            result.success(null);
//            break;
//        case "disableCrashHandler":
//            disableCrashHandler();
//            result.success(null);
//            break;
//        case "enableMetric":
//            enableMetric((String) call.arguments());
//            result.success(null);
//            break;
//        case "disableMetric":
//            disableMetric((String) call.arguments());
//            result.success(null);
//            break;
//        case "enableVideo":
//            enableVideo(
//                        (String) args.get("policy"),
//                        (String) args.get("quality"),
//                        (double) args.get("framesPerSecond")
//                        );
//            result.success(null);
//            break;
//        case "disableVideo":
//            disableVideo();
//            result.success(null);
//            break;
//        case "enableFeedbackForm":
//            enableFeedbackForm((String) call.arguments());
//            result.success(null);
//            break;
//        case "disableFeedbackForm":
//            disableFeedbackForm();
//            result.success(null);
//            break;
//        case "setMaxSessionLength":
//            setMaxSessionLength((double) call.arguments());
//            result.success(null);
//            break;
//        case "bringFlutterToFront":
//            bringFlutterToFront();
//            result.success(null);
//            break;
//        case "takeScreenshot":
//            takeScreenshot();
//            result.success(null);
//            break;
//        case "logError":
//            logError((String) call.arguments());
//            result.success(null);
//            break;
//        case "setFeedbackOptions":
//            setFeedbackOptions(
//                               (String) args.get("browserUrl"),
//                               (boolean) args.get("emailFieldVisible"),
//                               (boolean) args.get("emailMandatory"),
//                               (int) args.get("callId")
//                               );
//            break;
//        default:
//            result.notImplemented();
//            break;
//    }
}

- (void) begin:(NSString*)appToken {
    [TestFairy begin:appToken];
}

- (void) begin:(NSString*)appToken withOptions:(NSDictionary*)options {
    [TestFairy begin:appToken withOptions:options];
}

- (void) setServerEndpoint:(NSString*)endpoint {
    [TestFairy setServerEndpoint:endpoint];
}

- (NSString*) version {
    return [TestFairy version];
}

- (void) sendUserFeedback:(NSString*)feedback {
    [TestFairy sendUserFeedback:feedback];
}

- (void) addCheckpoint:(NSString*)cp {
    [TestFairy checkpoint:cp];
}

- (void) addEvent:(NSString*)e {
    [TestFairy addEvent:e];
}

- (void) setCorrelationId:(NSString*)cid {
    [TestFairy setCorrelationId:cid];
}

- (void) identify:(NSString*)cid withTraits:(NSDictionary*)traits {
    [TestFairy identify:cid traits:traits];
}

- (void) identify:(NSString*)cid {
    [TestFairy identify:cid];
}

- (void) setUserId:(NSString*)uid {
    [TestFairy setUserId:uid];
}

- (void) setAttribute:(NSString*)key withValue:(NSString*)value {
    [TestFairy setAttribute:key withValue:value];
}

- (NSString*) sessionUrl {
    return [TestFairy sessionUrl];
}

- (void) showFeedbackForm {
    return [TestFairy showFeedbackForm];
}

- (void) stop {
    return [TestFairy stop];
}

- (void) resume {
    return [TestFairy resume];
}

- (void) pause {
    return [TestFairy pause];
}

- (void) logError:(NSString*)error {
    [TestFairy log:error]; // TODO : fix this
}

- (void) log:(NSString*)msg {
    [TestFairy log:msg];
}

- (void) setScreenName:(NSString*)name {
    [TestFairy setScreenName:name];
}

- (BOOL) didLastSessionCrash {
    return [TestFairy didLastSessionCrash];
}

- (void) enableCrashHandler {
    [TestFairy enableCrashHandler];
}

- (void) disableCrashHandler {
    [TestFairy disableCrashHandler];
}

- (void) enableMetric:(NSString*)metric {
    [TestFairy enableMetric:metric];
}

- (void) disableMetric:(NSString*)metric {
    [TestFairy disableMetric:metric];
}

- (void) enableVideo:(NSString*)metric quality:(NSString*)quality framesPerSecond:(NSNumber*)framesPerSecond {
    [TestFairy enableVideo:metric quality:quality framesPerSecond:[framesPerSecond floatValue]];
}

- (void) disableVideo {
    [TestFairy disableVideo];
}

- (void) enableFeedbackForm:(NSString*)method {
    [TestFairy enableFeedbackForm:method];
}

- (void) disableFeedbackForm {
    [TestFairy disableFeedbackForm];
}

- (void) setMaxSessionLength:(NSNumber*)seconds {
    [TestFairy setMaxSessionLength:[seconds floatValue]];
}

- (void) bringFlutterToFront {
    // TODO : test this, dunno if works
    FlutterViewController *rootVC =
        (FlutterViewController*)[[(FlutterAppDelegate*)[[UIApplication sharedApplication]delegate] window] rootViewController];
    
    UINavigationController* nav = rootVC.navigationController;
    if (nav != nil) {
        [[[nav viewControllers] lastObject] showViewController:rootVC sender:nil];
    }
}

- (void) takeScreenshot {
    [TestFairy takeScreenshot];
}

@end

/*
 
 private void setFeedbackOptions(String browserUrl, boolean emailFieldVisible, boolean emailMandatory, final int callId) {
 FeedbackOptions.Builder builder = new FeedbackOptions.Builder();
 
 if (browserUrl != null) builder.setBrowserUrl(browserUrl);
 builder.setEmailFieldVisible(emailFieldVisible);
 builder.setEmailMandatory(emailMandatory);
 
 builder.setCallback(new FeedbackOptions.Callback() {
 @Override
 public void onFeedbackSent(final FeedbackContent feedbackContent) {
 withMethodChannel(new MethodChannelConsumer<Void>() {
 @Override
 public Void consume(MethodChannel channel) {
 Map<String, Object> feedbackContentMap = new HashMap<>();
 
 feedbackContentMap.put("email", feedbackContent.getEmail());
 feedbackContentMap.put("text", feedbackContent.getText());
 feedbackContentMap.put("timestamp", (double) feedbackContent.getTimestamp());
 feedbackContentMap.put("callId", callId);
 
 channel.invokeMethod("callOnFeedbackSent", feedbackContentMap);
 return null;
 }
 });
 }
 
 @Override
 public void onFeedbackCancelled() {
 withMethodChannel(new MethodChannelConsumer<Void>() {
 @Override
 public Void consume(MethodChannel channel) {
 channel.invokeMethod("callOnFeedbackCancelled", callId);
 return null;
 }
 });
 }
 
 @Override
 public void onFeedbackFailed(final int i, final FeedbackContent feedbackContent) {
 withMethodChannel(new MethodChannelConsumer<Void>() {
 @Override
 public Void consume(MethodChannel channel) {
 Map<String, Object> feedbackContentMap = new HashMap<>();
 
 feedbackContentMap.put("email", feedbackContent.getEmail());
 feedbackContentMap.put("text", feedbackContent.getText());
 feedbackContentMap.put("timestamp", (double) feedbackContent.getTimestamp());
 feedbackContentMap.put("i", i);
 feedbackContentMap.put("callId", callId);
 
 channel.invokeMethod("callOnFeedbackFailed", feedbackContentMap);
 return null;
 }
 });
 }
 });
 
 TestFairy.setFeedbackOptions(builder.build());
 }
 */
