#import <Flutter/Flutter.h>

@interface TestfairyFlutterPlugin : NSObject<FlutterPlugin>

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;

- (void) begin:(NSString*)appToken;
- (void) begin:(NSString*)appToken withOptions:(NSDictionary*)options;

@end
