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
    NSString* text = params[@"text"];
    if (!text || text.length == 0) {
        result([FlutterError
               errorWithCode:@"MISSING_TEXT_PARAM"
               message:@"The text parameter is required"
               details:nil]);
        return;
    }
    
    NSMutableArray *activityItems = [NSMutableArray new];
    [activityItems addObject:text];

     [self share:activityItems result: result];
}

- (void)shareImage:(NSDictionary *)params result:(FlutterResult) result {
    NSString* text = params[@"text"];
    NSString *imagePath = params[@"imageFile"];
    
    if (!imagePath || imagePath.length == 0) {
        result([FlutterError
              errorWithCode:@"MISSING_IMAGEPATH_PARAM"
              message:@"The image path parameter is missing"
              details:nil]);
        return;
    }

    NSMutableArray *activityItems = [NSMutableArray new];
    
    UIImage *image = nil;

    NSURL *imageUrl = [NSURL URLWithString:imagePath];
    if (imageUrl.scheme) {
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:imageUrl options:NSDataReadingMappedIfSafe error:&error];
        if (data) {
            image = [UIImage imageWithData:data];
        }
    } else {
        image = [UIImage imageWithContentsOfFile:imagePath];
    }

    if (text) {
        [activityItems addObject:text];
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
