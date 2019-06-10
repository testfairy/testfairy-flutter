#import "TestfairyFlutterPlugin.h"
#import "TestFairy.h"

@implementation TestfairyFlutterPlugin {
}

// Static
NSMutableDictionary* viewControllerMethodChannelMapping;

+ (void) takeScreenshot {
    id appDelegate = UIApplication.sharedApplication.delegate;
    
    if ([appDelegate isKindOfClass:[FlutterAppDelegate class]]) {             // check to see if response is `NSHTTPURLResponse`
        FlutterAppDelegate* flutterAppDelegate = appDelegate;
        NSString* currentViewControllerKey = [[NSNumber numberWithUnsignedLong:flutterAppDelegate.window.rootViewController.hash] stringValue];
        FlutterMethodChannel* channel = [viewControllerMethodChannelMapping objectForKey:currentViewControllerKey];
        
        if (channel != nil) {
            [channel invokeMethod:@"takeScreenshot" arguments:nil];
        }
    }
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
            methodChannelWithName:@"testfairy"
            binaryMessenger:[registrar messenger]];
    TestfairyFlutterPlugin* instance = [[TestfairyFlutterPlugin alloc] init];
    
    if (viewControllerMethodChannelMapping == nil) {
        viewControllerMethodChannelMapping = [[NSMutableDictionary alloc] init];
    }
    
    id appDelegate = UIApplication.sharedApplication.delegate;
    
    if ([appDelegate isKindOfClass:[FlutterAppDelegate class]]) {
        FlutterAppDelegate* flutterAppDelegate = appDelegate;
        NSString* currentViewControllerKey = [[NSNumber numberWithUnsignedLong:flutterAppDelegate.window.rootViewController.hash] stringValue];
        [viewControllerMethodChannelMapping setObject:channel forKey:currentViewControllerKey];
    }
    
    [registrar addMethodCallDelegate:instance channel:channel];
}

// Instance
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    @try {
        NSDictionary* args = nil;
        if (call.arguments != nil && [call.arguments isKindOfClass:[NSDictionary class]]) {
            args = call.arguments;
        }
        
        if ([@"addNetworkEvent" isEqualToString:call.method]) {
            [self addNetworkEvent:[args valueForKey:@"uri"]
                           method:[args valueForKey:@"method"]
                             code:[args valueForKey:@"code"]
                startTimeMillis:[args valueForKey:@"startTimeMillis"]
                  endTimeMillis:[args valueForKey:@"endTimeMillis"]
                      requestSize:[args valueForKey:@"requestSize"]
                     responseSize:[args valueForKey:@"responseSize"]
                     errorMessage:[args valueForKey:@"errorMessage"]];
            result(nil);
        } else if ([@"takeScreenshot" isEqualToString:call.method]) {
            [TestfairyFlutterPlugin takeScreenshot];
            result(nil);
        } else if ([@"sendScreenshot" isEqualToString:call.method]) {
            [self sendScreenshot:[args valueForKey:@"pixels"] width:[args valueForKey:@"width"] height:[args valueForKey:@"height"]];
            result(nil);
        } else if ([@"begin" isEqualToString:call.method]) {
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
        } else if ([@"sendUserFeedback" isEqualToString:call.method]) {
            [self sendUserFeedback:call.arguments];
            result(nil);
        } else if ([@"addCheckpoint" isEqualToString:call.method]) {
            [self addCheckpoint:call.arguments];
            result(nil);
        } else if ([@"addEvent" isEqualToString:call.method]) {
            [self addEvent:call.arguments];
            result(nil);
        } else if ([@"setCorrelationId" isEqualToString:call.method]) {
            [self setCorrelationId:call.arguments];
            result(nil);
        } else if ([@"identifyWithTraits" isEqualToString:call.method]) {
            [self identify: [args valueForKey:@"id"] withTraits:[args valueForKey:@"traits"]];
            result(nil);
        } else if ([@"identify" isEqualToString:call.method]) {
            [self identify:call.arguments];
            result(nil);
        } else if ([@"setUserId" isEqualToString:call.method]) {
            [self setUserId:call.arguments];
            result(nil);
        } else if ([@"setAttribute" isEqualToString:call.method]) {
            [self setAttribute:[args valueForKey:@"key"] withValue:[args valueForKey:@"value"]];
            result(nil);
        } else if ([@"getSessionUrl" isEqualToString:call.method]) {
            result([self sessionUrl]);
        } else if ([@"showFeedbackForm" isEqualToString:call.method]) {
            [self showFeedbackForm];
            result(nil);
        } else if ([@"stop" isEqualToString:call.method]) {
            [self stop];
            result(nil);
        } else if ([@"resume" isEqualToString:call.method]) {
            [self resume];
            result(nil);
        } else if ([@"pause" isEqualToString:call.method]) {
            [self pause];
            result(nil);
        } else if ([@"log" isEqualToString:call.method]) {
            [self log:call.arguments];
            result(nil);
        } else if ([@"setScreenName" isEqualToString:call.method]) {
            [self setScreenName:call.arguments];
            result(nil);
        } else if ([@"didLastSessionCrash" isEqualToString:call.method]) {
            result([self didLastSessionCrash]);
        } else if ([@"enableCrashHandler" isEqualToString:call.method]) {
            [self enableCrashHandler];
            result(nil);
        } else if ([@"disableCrashHandler" isEqualToString:call.method]) {
            [self disableCrashHandler];
            result(nil);
        } else if ([@"enableMetric" isEqualToString:call.method]) {
            [self enableMetric:call.arguments];
            result(nil);
        } else if ([@"disableMetric" isEqualToString:call.method]) {
            [self disableMetric:call.arguments];
            result(nil);
        } else if ([@"enableVideo" isEqualToString:call.method]) {
            [self enableVideo:[args valueForKey:@"policy"] quality:[args valueForKey:@"quality"] framesPerSecond:[args valueForKey:@"framesPerSecond"]];
            result(nil);
        } else if ([@"disableVideo" isEqualToString:call.method]) {
            [self disableVideo];
            result(nil);
        } else if ([@"enableFeedbackForm" isEqualToString:call.method]) {
            [self enableFeedbackForm:call.arguments];
            result(nil);
        } else if ([@"disableFeedbackForm" isEqualToString:call.method]) {
            [self disableFeedbackForm];
            result(nil);
        } else if ([@"setMaxSessionLength" isEqualToString:call.method]) {
            [self setMaxSessionLength: call.arguments];
            result(nil);
        } else if ([@"bringFlutterToFront" isEqualToString:call.method]) {
            [self bringFlutterToFront];
            result(nil);
        } else if ([@"logError" isEqualToString:call.method]) {
            [self logError:call.arguments];
            result(nil);
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

- (void) sendScreenshot:(FlutterStandardTypedData*)pixels width:(NSNumber*)width height:(NSNumber*)height {
    void* outputData = (void*) [[pixels data] bytes];
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapContext = CGBitmapContextCreate(outputData, [width intValue], [height intValue], 8, 4*[width intValue], colorSpace,  kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);
    CFRelease(colorSpace);
    CGImageRef cgImage = CGBitmapContextCreateImage(bitmapContext);
    CGContextRelease(bitmapContext);
    
    UIImage * newimage = [UIImage imageWithCGImage:cgImage];
    
    // TODO : send newImage
    UIImageWriteToSavedPhotosAlbum(newimage, nil, nil, nil);

    CGImageRelease(cgImage);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [TestfairyFlutterPlugin takeScreenshot];
    });
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
    [TestFairy logError:[NSError errorWithDomain:@"testfairy" code:-1 userInfo:@{NSLocalizedDescriptionKey:error}]];
}

- (void) log:(NSString*)msg {
    [TestFairy log:msg];
}

- (void) setScreenName:(NSString*)name {
    [TestFairy setScreenName:name];
}

- (NSNumber*) didLastSessionCrash {
    return [NSNumber numberWithBool:[TestFairy didLastSessionCrash]];
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
    FlutterViewController *rootVC =
        (FlutterViewController*)[[(FlutterAppDelegate*)[[UIApplication sharedApplication]delegate] window] rootViewController];
    
    UINavigationController* nav = rootVC.navigationController;
    if (nav != nil) {
        [nav popToRootViewControllerAnimated:true];
    } else {
        [rootVC dismissViewControllerAnimated:true completion:nil];
    }
}

- (void) addNetworkEvent: (NSString*)uri method:(NSString*)method code:(NSNumber*)code startTimeMillis:(NSNumber*)startTimeMillis endTimeMillis:(NSNumber*)endTimeMillis requestSize:(NSNumber*)requestSize responseSize:(NSNumber*)responseSize errorMessage:(id)errorMessage {
    NSString* error = nil;
    if ([errorMessage isKindOfClass:[NSString class]]) {
        error = errorMessage;
    } else {
        error = @"";
    }
    
    [TestFairy addNetwork:[NSURL URLWithString:uri]
                   method:method
                     code:[code intValue]
        startTimeInMillis:[startTimeMillis longValue]
          endTimeInMillis:[endTimeMillis longValue]
              requestSize:[requestSize longValue]
             responseSize:[responseSize longValue]
             errorMessage:error];
}


@end

/*
 // TODO
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
