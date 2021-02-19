#import "TestfairyFlutterPlugin.h"
#import "TestFairy.h"

@interface TestFairy()
+ (void)setExternalRectCapture:(void (^)(void (^)(NSArray*)))provider;
@end

@implementation TestfairyFlutterPlugin {
    BOOL fakeHideViewCalledOnce;
}

// Static
NSMutableDictionary* viewControllerMethodChannelMapping;

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
    
    instance->fakeHideViewCalledOnce = false;
}

+ (void)registerGetHiddenRects {
    [TestFairy setExternalRectCapture:^(void (^provider)(NSArray *rects)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            id appDelegate = UIApplication.sharedApplication.delegate;
            
            if ([appDelegate isKindOfClass:[FlutterAppDelegate class]]) {             // check to see if response is `NSHTTPURLResponse`
                FlutterAppDelegate* flutterAppDelegate = appDelegate;
                NSString* currentViewControllerKey = [[NSNumber numberWithUnsignedLong:flutterAppDelegate.window.rootViewController.hash] stringValue];
                FlutterMethodChannel* channel = [viewControllerMethodChannelMapping objectForKey:currentViewControllerKey];
                
                if (channel != nil) {
                    [channel invokeMethod:@"getHiddenRects" arguments:nil result: ^(id result) {
                        NSArray *dartRects = (NSArray*)result;
                        NSMutableArray *rects = [NSMutableArray array];
                        
                        for (int i = 0; i < [dartRects count]; i++) {
                            NSDictionary *dartRect = [dartRects objectAtIndex:i];
                            CGFloat screenScale = [[UIScreen mainScreen] scale];
                            
                            NSNumber *left = [dartRect valueForKey:@"left"];
                            NSNumber *top = [dartRect valueForKey:@"top"];
                            NSNumber *right = [dartRect valueForKey:@"right"];
                            NSNumber *bottom = [dartRect valueForKey:@"bottom"];
                            
                            CGRect rect = CGRectMake([left intValue] / screenScale, [top intValue] / screenScale, ([right intValue] - [left intValue]) / screenScale, ([bottom intValue] - [top intValue]) / screenScale);
                            
                            [rects addObject:[NSValue valueWithCGRect:rect]];
                        }
                        
                        provider(rects);
                    }];
                }
            }
        });
    }];
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
                     errorMessage:[args valueForKey:@"errorMessage"]
                   requestHeaders:[args valueForKey:@"requestHeaders"]
                      requestBody:[args valueForKey:@"requestBody"]
                  responseHeaders:[args valueForKey:@"responseHeaders"]
                     responseBody:[args valueForKey:@"responseBody"]];
            result(nil);
        } else if ([@"takeScreenshot" isEqualToString:call.method]) {
            [self takeScreenshot];
            result(nil);
        } else if ([@"begin" isEqualToString:call.method]) {
            [self begin:call.arguments];
            result(nil);
        } else if ([@"beginWithOptions" isEqualToString:call.method]) {
            [self begin:[args valueForKey:@"appToken"] withOptions:[args valueForKey:@"options"]];
            result(nil);
        } else if ([@"addUserInteraction" isEqualToString:call.method]) {
            [self addUserInteraction:[args valueForKey:@"kind"] label:[args valueForKey:@"label"] info:[args valueForKey:@"info"]];
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
        } else if ([@"disableAutoUpdate" isEqualToString:call.method]) {
            [self disableAutoUpdate];
            result(nil);
        } else if ([@"setFeedbackOptions" isEqualToString:call.method]) {
            [self setFeedbackOptions:[args valueForKey:@"defaultText"]
                          browserUrl:nil
                   emailFieldVisible:[args valueForKey:@"emailFieldVisible"]
                      emailMandatory:[args valueForKey:@"emailMandatory"]];
            result(nil);
        } else if ([@"installCrashHandler" isEqualToString:call.method]) {
            [self installCrashHandler:call.arguments];
            result(nil);
        } else if ([@"installFeedbackHandler" isEqualToString:call.method]) {
            [self installFeedbackHandler:call.arguments];
            result(nil);
        } else if ([@"hideWidget" isEqualToString:call.method]) {
            [self hideWidget];
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
}

- (void) takeScreenshot {
    [TestFairy takeScreenshot];
}

- (void) hideWidget {
    if (self->fakeHideViewCalledOnce) {
        return;
    }
    
    self->fakeHideViewCalledOnce = true;
    
    UIView* dummyView = [[UIView alloc] initWithFrame:CGRectZero];
    [TestFairy hideView:dummyView];
}

- (void) begin:(NSString*)appToken {
    [TestFairy begin:appToken];
    
    [TestfairyFlutterPlugin registerGetHiddenRects];
}

- (void) begin:(NSString*)appToken withOptions:(NSDictionary*)options {
    [TestFairy begin:appToken withOptions:options];
    
    [TestfairyFlutterPlugin registerGetHiddenRects];
}

- (void) addUserInteraction:(NSString*)kind label:(NSString*)label info:(NSDictionary*)info {
    int interactionKind = 1; // Press as default
    if ([kind isEqualToString:@"UserInteractionKind.USER_INTERACTION_BUTTON_PRESSED"]) {
        interactionKind = 1;
    } else if ([kind isEqualToString:@"UserInteractionKind.USER_INTERACTION_BUTTON_LONG_PRESSED"]) {
        interactionKind = 8;
    } else if ([kind isEqualToString:@"UserInteractionKind.USER_INTERACTION_BUTTON_DOUBLE_PRESSED"]) {
        interactionKind = 9;
    }
    
    NSMutableDictionary* sanitizedInfo = [NSMutableDictionary new];
    
    if ([info valueForKey:@"accessibilityLabel"] != nil) {
        [sanitizedInfo setValue:[info valueForKey:@"accessibilityLabel"] forKey:@"accessibilityLabel"];
    }
    
    if ([info valueForKey:@"accessibilityIdentifier"] != nil) {
        [sanitizedInfo setValue:[info valueForKey:@"accessibilityIdentifier"] forKey:@"accessibilityIdentifier"];
    }
    
    if ([info valueForKey:@"accessibilityHint"] != nil) {
        [sanitizedInfo setValue:[info valueForKey:@"accessibilityHint"] forKey:@"accessibilityHint"];
    }
    
    if ([info valueForKey:@"className"] != nil) {
        [sanitizedInfo setValue:[info valueForKey:@"className"] forKey:@"className"];
    }
    
    [TestFairy addUserInteraction:interactionKind label:label info:sanitizedInfo];
}

- (void) installFeedbackHandler:(NSString *)appToken {
    [TestFairy installFeedbackHandler:appToken];
    
    [TestfairyFlutterPlugin registerGetHiddenRects];
}

- (void) installCrashHandler:(NSString *)appToken {
    [TestFairy installCrashHandler:appToken];
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

- (void) disableAutoUpdate {
    [TestFairy disableAutoUpdate];
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

- (void) addNetworkEvent: (NSString*)uri method:(NSString*)method code:(NSNumber*)code startTimeMillis:(NSNumber*)startTimeMillis endTimeMillis:(NSNumber*)endTimeMillis requestSize:(NSNumber*)requestSize responseSize:(NSNumber*)responseSize errorMessage:(id)errorMessage requestHeaders:(NSString*)requestHeaders requestBody:(FlutterStandardTypedData*)requestBody responseHeaders:(NSString*)responseHeaders responseBody:(FlutterStandardTypedData*)responseBody {
    NSString* error = nil;
    if ([errorMessage isKindOfClass:[NSString class]]) {
        error = errorMessage;
    } else {
        error = @"";
    }
    
    if (
        (requestHeaders == nil || requestHeaders == [NSNull null]) &&
        (requestBody == nil || requestBody == [NSNull null]) &&
        (responseHeaders == nil || responseHeaders == [NSNull null]) &&
        (responseBody == nil || responseBody == [NSNull null])
        ) {
        
        [TestFairy addNetwork:[NSURL URLWithString:uri]
                       method:method
                         code:[code intValue]
            startTimeInMillis:[startTimeMillis longValue]
              endTimeInMillis:[endTimeMillis longValue]
                  requestSize:[requestSize longValue]
                 responseSize:[responseSize longValue]
                 errorMessage:error];
    } else {
        NSData* requestBodyData = nil;
        if ([requestBody isKindOfClass:[FlutterStandardTypedData class]]) {
            requestBodyData = [requestBody data];
        }
        
        NSData* responseBodyData = nil;
        if ([responseBody isKindOfClass:[FlutterStandardTypedData class]]) {
            responseBodyData = [responseBody data];
        }
        
        [TestFairy addNetwork:[NSURL URLWithString:uri]
                       method:method code:[code intValue]
            startTimeInMillis:[startTimeMillis longValue]
              endTimeInMillis:[endTimeMillis longValue]
                  requestSize:[requestSize longValue]
                 responseSize:[responseSize longValue]
                 errorMessage:error
               requestHeaders:requestHeaders
                  requestBody:requestBodyData
              responseHeaders:responseHeaders
                 responseBody:responseBodyData];
    }
}

- (void) setFeedbackOptions: (NSString*)defaultText browserUrl:(NSString*)browserUrl emailFieldVisible:(NSNumber*)emailFieldVisible emailMandatory:(NSNumber*)emailMandatory {
    NSMutableDictionary* feedbackOptions = [NSMutableDictionary new];
    
    if (defaultText != nil && defaultText != [NSNull null]) {
        [feedbackOptions setValue:defaultText forKey:@"defaultText"];
    }
    
    // TODO : Browser url is not supported in iOS SDK yet
    
    if (emailFieldVisible != nil && emailFieldVisible != [NSNull null]) {
        [feedbackOptions setValue:emailFieldVisible forKey:@"isEmailVisible"];
    }
    
    if (emailMandatory != nil && emailMandatory != [NSNull null]) {
        [feedbackOptions setValue:emailMandatory forKey:@"isEmailMandatory"];
    }
    
    [TestFairy setFeedbackOptions:feedbackOptions];
}

@end
