#import <MessageUI/MessageUI.h>
#import "RNShare.h"
// import RCTConvert
#if __has_include(<React/RCTConvert.h>)
#import <React/RCTConvert.h>
#elif __has_include("RCTConvert.h")
#import "RCTConvert.h"
#else
#import "React/RCTConvert.h"   // Required when used as a Pod in a Swift project
#endif
// import RCTLog
#if __has_include(<React/RCTLog.h>)
#import <React/RCTLog.h>
#elif __has_include("RCTLog.h")
#import "RCTLog.h"
#else
#import "React/RCTLog.h"   // Required when used as a Pod in a Swift project
#endif
// import RCTUtils
#if __has_include(<React/RCTUtils.h>)
#import <React/RCTUtils.h>
#elif __has_include("RCTUtils.h")
#import "RCTUtils.h"
#else
#import "React/RCTUtils.h"   // Required when used as a Pod in a Swift project
#endif
// import RCTBridge
#if __has_include(<React/RCTBridge.h>)
#import <React/RCTBridge.h>
#elif __has_include("RCTBridge.h")
#import "RCTBridge.h"
#else
#import "React/RCTBridge.h"   // Required when used as a Pod in a Swift project
#endif
// import RCTBridge
#if __has_include(<React/RCTUIManager.h>)
#import <React/RCTUIManager.h>
#elif __has_include("RCTUIManager.h")
#import "RCTUIManager.h"
#else
#import "React/RCTUIManager.h"   // Required when used as a Pod in a Swift project
#endif
#import "GenericShare.h"
#import "WhatsAppShare.h"
#import "InstagramShare.h"
#import "InstagramStories.h"
#import "FacebookStories.h"
#import "GooglePlusShare.h"
#import "EmailShare.h"
#import "RNShareActivityItemSource.h"

@implementation RNShare

RCTResponseErrorBlock rejectBlock;
RCTResponseSenderBlock resolveBlock;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (CGRect)sourceRectInView:(UIView *)sourceView
             anchorViewTag:(NSNumber *)anchorViewTag
{
    if (anchorViewTag) {
        UIView *anchorView = [self.bridge.uiManager viewForReactTag:anchorViewTag];
        return [anchorView convertRect:anchorView.bounds toView:sourceView];
    } else {
        return (CGRect){sourceView.center, {1, 1}};
    }
}

- (BOOL)isImageMimeType:(NSString *)data {
    NSRange range = [data rangeOfString:@"data:image" options:NSCaseInsensitiveSearch];
    if (range.location != NSNotFound) {
        return true;
    } else {
        return false;
    }
}

RCT_EXPORT_MODULE()

- (NSDictionary *)constantsToExport
{
    return @{
        @"FACEBOOK": @"facebook",
        @"FACEBOOK_STORIES": @"facebook-stories",
        @"TWITTER": @"twitter",
        @"GOOGLEPLUS": @"googleplus",
        @"WHATSAPP": @"whatsapp",
        @"INSTAGRAM": @"instagram",
        @"INSTAGRAM_STORIES": @"instagramstories",
        @"EMAIL": @"email",
        
        @"SHARE_BACKGROUND_IMAGE": @"shareBackgroundImage",
        @"SHARE_BACKGROUND_VIDEO": @"shareBackgroundVideo",
        @"SHARE_STICKER_IMAGE": @"shareStickerImage",
        @"SHARE_BACKGROUND_AND_STICKER_IMAGE": @"shareBackgroundAndStickerImage",
    };
}

RCT_EXPORT_METHOD(shareSingle:(NSDictionary *)options
                  failureCallback:(RCTResponseErrorBlock)failureCallback
                  successCallback:(RCTResponseSenderBlock)successCallback)
{
    NSString *social = [RCTConvert NSString:options[@"social"]];
    if (social) {
        NSLog(@"%@", social);
        if([social isEqualToString:@"facebook"]) {
            NSLog(@"TRY OPEN FACEBOOK");
            GenericShare *shareCtl = [[GenericShare alloc] init];
            [shareCtl shareSingle:options failureCallback: failureCallback successCallback: successCallback serviceType: SLServiceTypeFacebook inAppBaseUrl:@"fb://"];
        } else if([social isEqualToString:@"facebook-stories"]) {
            NSString *appId = [RCTConvert NSString:options[@"appId"]];
            if (appId) {
                NSLog(@"TRY OPEN FACEBOOK STORIES");
                FacebookStories *shareCtl = [[FacebookStories alloc] init];
                [shareCtl shareSingle:options failureCallback: failureCallback successCallback: successCallback];
            } else {
                RCTLogError(@"key 'appId' missing in options");
                return;
            }
        } else if([social isEqualToString:@"twitter"]) {
            NSLog(@"TRY OPEN Twitter");
            GenericShare *shareCtl = [[GenericShare alloc] init];
            [shareCtl shareSingle:options failureCallback: failureCallback successCallback: successCallback serviceType: SLServiceTypeTwitter inAppBaseUrl:@"twitter://"];
        } else if([social isEqualToString:@"googleplus"]) {
            NSLog(@"TRY OPEN google plus");
            GooglePlusShare *shareCtl = [[GooglePlusShare alloc] init];
            [shareCtl shareSingle:options failureCallback: failureCallback successCallback: successCallback];
        } else if([social isEqualToString:@"whatsapp"]) {
            NSLog(@"TRY OPEN whatsapp");
            WhatsAppShare *shareCtl = [[WhatsAppShare alloc] init];
            [shareCtl shareSingle:options failureCallback: failureCallback successCallback: successCallback];
        } else if([social isEqualToString:@"instagram"]) {
            NSLog(@"TRY OPEN instagram");
            InstagramShare *shareCtl = [[InstagramShare alloc] init];
            if([self isImageMimeType:options[@"url"]]) {// Condition to handle image
                [shareCtl shareSingleImage:options failureCallback: failureCallback successCallback: successCallback];
            } else {
                [shareCtl shareSingle:options failureCallback: failureCallback successCallback: successCallback];
            }
        } else if([social isEqualToString:@"instagramstories"]) {
            NSLog(@"TRY OPEN instagram-stories");
            InstagramStories *shareCtl = [[InstagramStories alloc] init];
            [shareCtl shareSingle:options failureCallback: failureCallback successCallback: successCallback];
        } else if([social isEqualToString:@"email"]) {
            NSLog(@"TRY OPEN email");
            EmailShare *shareCtl = [[EmailShare alloc] init];
            [shareCtl shareSingle:options failureCallback: failureCallback successCallback: successCallback];
        }
    } else {
        RCTLogError(@"key 'social' missing in options");
        return;
    }
}

RCT_EXPORT_METHOD(open:(NSDictionary *)options
                  failureCallback:(RCTResponseErrorBlock)failureCallback
                  successCallback:(RCTResponseSenderBlock)successCallback)
{
    if (RCTRunningInAppExtension()) {
        RCTLogError(@"Unable to show action sheet from app extension");
        return;
    }
    
    NSMutableArray<id> *items = [NSMutableArray array];
    NSString *message = [RCTConvert NSString:options[@"message"]];
    [options setValue:message forKey:@"subject"];
    if (message) {
        // following code to get iamge from text dynamically
        //[items addObject:message];
        /* NSString *string = message;
         UIGraphicsBeginImageContext(CGSizeMake(1000, 100));
         //UIGraphicsGetCurrentContext().draw
         UILabel * lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1000, 100)];
         [lbl setNumberOfLines: 0];
         [lbl setText:message];
         [lbl setFont:[UIFont systemFontOfSize:20]];
         [lbl setBackgroundColor:UIColor.clearColor];
         [lbl setTextColor:[UIColor whiteColor]];
         //[lbl drawTextInRect:lbl.frame];
         // [string drawAtPoint:CGPointMake(10, 20)
         // withFont:[UIFont systemFontOfSize:20]];
         [lbl drawRect:lbl.frame];
         UIImage *result =  UIGraphicsGetImageFromCurrentImageContext();//[self imageFromView:lbl];//
         // UIGraphicsEndImageContext();
         NSArray *paths = NSSearchPathForDirectoriesInDomains
         (NSDocumentDirectory, NSUserDomainMask, YES);
         NSString *documentsDirectory = [paths objectAtIndex:0];
         
         //make a file name to write the data to using the documents directory:
         NSString *fileName = [NSString stringWithFormat:@"%@/textfile.png",
         documentsDirectory];
         //create content - four lines of text
         NSString *content = message;
         //save content to the documents directory
         NSData * d =  UIImagePNGRepresentation(result);
         [d writeToFile:fileName
         atomically:NO
         ];*/
        
        // for now with good quality, image saved locally
        // if confirmed can make sure of getting an image from text dynamically with good quality
        
        UIFont* font = [UIFont systemFontOfSize:22.0f];
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:22]};
        CGSize size = [message sizeWithAttributes:attributes];
        // Create a bitmap context into which the text will be rendered.
        UIGraphicsBeginImageContext(size);
        // Render the text
        [message drawAtPoint:CGPointMake(0.0, 0.0) withAttributes:attributes];
        // Retrieve the image
        UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
        // Convert to JPEG
        NSData* data = UIImageJPEGRepresentation(image, 1.0);
        // Figure out a safe path
        NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(
                                                                  NSDocumentDirectory,
                                                                  NSUserDomainMask,
                                                                  YES);
        NSString *docDir = [arrayPaths objectAtIndex:0];
        // Write the file
        NSString *filePath = [docDir stringByAppendingPathComponent:@"Kevin.jpg"];
        BOOL success = [data writeToFile:filePath atomically:YES];
        if(!success)
        {
            NSLog(@"Failed to write to file. Perhaps it already exists?");
        }
        else
        {
            NSLog(@"JPEG file successfully written to %@", filePath);
        }
        // Clean up
        UIGraphicsEndImageContext();
        [items addObject:[NSURL fileURLWithPath:filePath]];
        
        // for static image
        // [items addObject:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"share_text_img" ofType:@"png"]]];
        
    }
    
    BOOL saveToFiles = [RCTConvert BOOL:options[@"saveToFiles"]];
    NSArray *urlsArray = options[@"urls"];
    
    for (int i=0; i<urlsArray.count; i++) {
        NSURL *URL = [RCTConvert NSURL:urlsArray[i]];
        if (URL) {
            if ([URL.scheme.lowercaseString isEqualToString:@"data"]) {
                NSError *error;
                NSData *data = [NSData dataWithContentsOfURL:URL
                                                     options:(NSDataReadingOptions)0
                                                       error:&error];
                if (!data) {
                    failureCallback(error);
                    return;
                }
                if //(saveToFiles){
                    (1 == 1) { //here there are either data share cse or url share case
                        // i need to work on url case share
                        
                        NSURL *filePath = [self getPathFromBase64:URL.absoluteString with:data];
                        if (filePath) {
                            [items addObject: filePath];
                        }
                    } else {
                        [items addObject:data];
                    }
            } else {
                /*NSError *error;
                 NSData *data = [NSData dataWithContentsOfURL:URL
                 options:(NSDataReadingOptions)0
                 error:&error];
                 if (!data) {
                 failureCallback(error);
                 return;
                 }
                 [items addObject:data];*/
                [items addObject:URL];
            }
        }
    }
    
    NSArray *activityItemSources = options[@"activityItemSources"];
    if (activityItemSources) {
        [activityItemSources enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RNShareActivityItemSource *activityItemSource = [[RNShareActivityItemSource alloc] initWithOptions:obj];
            [items addObject:activityItemSource];
        }];
    }
    
    if (items.count == 0) {
        RCTLogError(@"No `url` or `message` to share");
        return;
    }
    
    UIViewController *controller = RCTPresentedViewController();
    
    if (saveToFiles) {
        NSArray *urls = [items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            return [evaluatedObject isKindOfClass:[NSURL class]];
        }]];
        
        if (urls.count == 0) {
            RCTLogError(@"No `urls` to save in Files");
            return;
        }
        if (@available(iOS 11.0, *)) {
            resolveBlock = successCallback;
            rejectBlock = failureCallback;
            UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithURLs:urls inMode:UIDocumentPickerModeExportToService];
            [documentPicker setDelegate:self];
            [controller presentViewController:documentPicker animated:YES completion:nil];
            return;
        }
    }
    
    UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    
    NSString *subject = [RCTConvert NSString:options[@"subject"]];
    if (subject) {
        [shareController setValue:subject forKey:@"subject"];
    }
    
    NSArray *excludedActivityTypes = [RCTConvert NSStringArray:options[@"excludedActivityTypes"]];
    if (excludedActivityTypes) {
        shareController.excludedActivityTypes = excludedActivityTypes;
    }
    
    shareController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, __unused NSArray *returnedItems, NSError *activityError) {
        if (activityError) {
            [controller  dismissViewControllerAnimated:true completion:nil];
            failureCallback(activityError);
        } else if (completed || activityType == nil) {
            successCallback(@[@(completed), RCTNullIfNil(activityType)]);
        }
    };
    
    shareController.modalPresentationStyle = UIModalPresentationPopover;
    NSNumber *anchorViewTag = [RCTConvert NSNumber:options[@"anchor"]];
    if (!anchorViewTag) {
        shareController.popoverPresentationController.permittedArrowDirections = 0;
    }
    shareController.popoverPresentationController.sourceView = controller.view;
    shareController.popoverPresentationController.sourceRect = [self sourceRectInView:controller.view anchorViewTag:anchorViewTag];
    
    [controller presentViewController:shareController animated:YES completion:nil];
    
    shareController.view.tintColor = [RCTConvert UIColor:options[@"tintColor"]];
}

- (NSURL*)getPathFromBase64:(NSString*)base64String with:(NSData*)data {
    NSRange   searchedRange = NSMakeRange(0, [base64String length]);
    NSString *pattern = @"/[a-zA-Z0-9]+;";
    NSError  *error = nil;
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:&error];
    NSArray* matches = [regex matchesInString:base64String options:0 range: searchedRange];
    NSString * mimeType = @"png";
    for (NSTextCheckingResult* match in matches) {
        NSString* matchText = [base64String substringWithRange:[match range]];
        mimeType = [matchText substringWithRange:(NSMakeRange(1, matchText.length - 2))];
    }
    
    NSString *pathComponent = [NSString stringWithFormat:@"file.%@", mimeType];
    NSString *writePath = [NSTemporaryDirectory() stringByAppendingPathComponent:pathComponent];
    if ([data writeToFile:writePath atomically:YES]) {
        return [NSURL fileURLWithPath:writePath];
    }
    return NULL;
}

-(void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    if (rejectBlock) {
        NSError *error = [NSError errorWithDomain:@"CANCELLED" code: 500 userInfo:@{NSLocalizedDescriptionKey:@"PICKER_WAS_CANCELLED"}];
        rejectBlock(error);
    }
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (resolveBlock) {
        resolveBlock(@[@(YES), @"com.apple.DocumentsApp"]);
    }
}
- (UIImage *)imageFromView:(UIView *)view
{
    size_t width = view.bounds.size.width*2;
    size_t height = view.bounds.size.height*2;
    
    unsigned char *imageBuffer = (unsigned char *)malloc(width*height*8);
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef imageContext = CGBitmapContextCreate(imageBuffer, width, height, 8, width*4, colourSpace,kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
    
    CGColorSpaceRelease(colourSpace);
    
    CGContextTranslateCTM(imageContext, 0.0, height);
    CGContextScaleCTM(imageContext, 2.0, -2.0);
    
    [view.layer renderInContext:imageContext];
    
    CGImageRef outputImage = CGBitmapContextCreateImage(imageContext);
    UIImage *image = [[UIImage alloc] initWithCGImage:outputImage];
    
    CGImageRelease(outputImage);
    CGContextRelease(imageContext);
    free(imageBuffer);
    
    return image;
}
@end
