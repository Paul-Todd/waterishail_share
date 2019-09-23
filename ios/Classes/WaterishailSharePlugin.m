#import "WaterishailSharePlugin.h"
#import "PLSaveImageActivity.h"

@implementation WaterishailSharePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {

  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"waterishail_share" binaryMessenger:[registrar messenger]];
        WaterishailSharePlugin* instance = [[WaterishailSharePlugin alloc] init];
        [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if([@"share_image" isEqualToString:call.method]) {
        [self shareImage:call.arguments result: result];
  } else if ([@"share_text" isEqualToString:call.method]) {
        [self shareText:call.arguments result: result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)shareText:(NSDictionary *)params result:(FlutterResult) result {
    if(params == nil) {
      return;
    }

    NSString *text = params[@"text"];
    NSMutableArray *activityItems = [NSMutableArray new];
    if (text) {
        [activityItems addObject:text];
    }

     [self share:activityItems result: result];
}

- (void)shareImage:(NSDictionary *)params result:(FlutterResult) result {
    if(params == nil) {
      return;
    }
    NSString *imagePath = params[@"imageFile"];
    NSString *text = params[@"text"];

    NSMutableArray *activityItems = [NSMutableArray new];
    if (text) {
        [activityItems addObject:text];
    }

    UIImage *image = nil;
    if (imagePath) {
        NSURL *imageUrl = [NSURL URLWithString:imagePath];
        if (TARGET_IPHONE_SIMULATOR) {
            if (imageUrl.scheme) {
                NSError *error;
                NSData *data = [NSData dataWithContentsOfURL:imageUrl options:NSDataReadingMappedIfSafe error:&error];
                if (data) {
                    image = [UIImage imageWithData:data];
                }
            } else {
                image = [UIImage imageWithContentsOfFile:imagePath];
            }

        } else {
            if ([imageUrl.scheme isEqualToString:@"file"]) {
                image = [UIImage imageWithContentsOfFile:imagePath];
            } else {
                NSError *error;
                NSData *data = [NSData dataWithContentsOfURL:imageUrl options:NSDataReadingMappedIfSafe error:&error];
                if (data) {
                    image = [UIImage imageWithData:data];
                }
            }
        }

    }

    if (image) {
        [activityItems addObject:image];
    }

    [self share:activityItems result: result];
}


- (void)share:(NSArray *)activityItems result:(FlutterResult) result {

    PLSaveImageActivity *saveImageActivity = [PLSaveImageActivity new];
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:@[saveImageActivity]];

    activityViewController.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll];
    UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    activityViewController.popoverPresentationController.sourceView = controller.view;

    activityViewController.completionWithItemsHandler = ^(NSString *activityType,
                                                          BOOL completed,
                                                          NSArray *returnedItems,
                                                          NSError *error) {

        if (error) {
            result([FlutterError errorWithCode:[NSString stringWithFormat:@"Error %ld", error.code]
            message:error.domain
            details:error.localizedDescription]);
        } else if (completed) {
            // user shared an item
            result(@0);
        } else {
            // user cancelled
            result(@-1);
        }
    };

    [controller presentViewController:activityViewController animated:YES completion:nil];
}

@end
