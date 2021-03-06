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

    NSNumber *originX = params[@"originX"];
    NSNumber *originY = params[@"originY"];
    NSNumber *originWidth = params[@"originWidth"];
    NSNumber *originHeight = params[@"originHeight"];

    CGRect originRect = CGRectZero;
    if (originX != nil && originY != nil && originWidth != nil && originHeight != nil) {
    originRect = CGRectMake([originX doubleValue], [originY doubleValue],
                            [originWidth doubleValue], [originHeight doubleValue]);
    }

    [self share:activityItems :originRect result: result];
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

    if (!image) {
        image = [UIImage imageNamed:@"AppIcon"];
    }

    if (image) {
        [activityItems addObject:image];
    }

    NSNumber *originX = params[@"originX"];
    NSNumber *originY = params[@"originY"];
    NSNumber *originWidth = params[@"originWidth"];
    NSNumber *originHeight = params[@"originHeight"];
    
    CGRect originRect = CGRectZero;
    if (originX != nil && originY != nil && originWidth != nil && originHeight != nil) {
        originRect = CGRectMake([originX doubleValue], [originY doubleValue],
                                [originWidth doubleValue], [originHeight doubleValue]);
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [self share:activityItems :originRect result: result];
    });
}


- (void)share:(NSArray *)activityItems :(CGRect) origin result:(FlutterResult) result {

    //PLSaveImageActivity *saveImageActivity = [PLSaveImageActivity new];
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                      applicationActivities: nil];

    //activityViewController.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll];
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

//    [controller presentViewController:activityViewController animated:YES completion:nil];

   //if iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Change Rect to position Popover
        if (CGRectIsEmpty(origin)) {
            NSLog(@"Rect is empty - using default");
            origin = CGRectMake(controller.view.frame.size.width/2, controller.view.frame.size.height/4, 0, 0);
        }
        activityViewController.popoverPresentationController.sourceRect = origin;
    }
    
    [controller presentViewController:activityViewController animated:YES completion:nil];
}

@end
