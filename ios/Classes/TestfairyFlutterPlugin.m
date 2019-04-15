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
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
//    if ([@"getPlatformVersion" isEqualToString:call.method]) {
//        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
//    } else {
//        result(FlutterMethodNotImplemented);
//    }
    result(FlutterMethodNotImplemented);
    
//    switch (call.method) {
//        case "begin":
//            begin((String) call.arguments());
//            result.success(null);
//            break;
//        case "beginWithOptions":
//            beginWithOptions((String) args.get("appToken"), (Map) args.get("options"));
//            result.success(null);
//            break;
//        case "setServerEndpoint":
//            setServerEndpoint((String) call.arguments());
//            result.success(null);
//            break;
//        case "getVersion":
//            result.success(getVersion());
//            break;
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

@end
