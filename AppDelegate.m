//
//  AppDelegate.m
//  IM-HERE
//
//  Created by dhruv patel on 16/06/16.
//  Copyright © 2016 dhruv patel. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
@import GoogleMaps;
#import <Google/CloudMessaging.h>
#import "ViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>


@interface AppDelegate ()
@property(nonatomic,strong)UILocalNotification *localNotification;

@end


@implementation AppDelegate
NSString *const SubscriptionTopic = @"/topics/global";

@synthesize request;
@synthesize loginResponse;
@synthesize vehicleList;
@synthesize vehicleNumber;
@synthesize vehicleInformation;
@synthesize internetReachability;


//git hub setted
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    UILocalNotification *localNotif =
    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
       
        application.applicationIconBadgeNumber = localNotif.applicationIconBadgeNumber-1;
        
    }
    
    [_window makeKeyAndVisible];
    
    UIUserNotificationType allNotificationTypes =
    (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
 
    
    //for google map
    [GMSServices provideAPIKey:@"AIzaSyAtWwoW85HqgagmSXDh3H3SRB3ZByXXSbo"];
    internetReachability = [Reachability reachabilityForInternetConnection];
    
    
    request=@"http://163.172.20.165/ImHereWebAPI/Api/";
    UINavigationController *nvi=[[UINavigationController alloc]init];
    if ([UINavigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        nvi.interactivePopGestureRecognizer.enabled = NO;
    }
    self.interactivePopGestureRecognizer.delegate=self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled=NO;
    }
    
    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"device token :%@",deviceToken);
    
    NSString *strDeviceToken=[NSString stringWithFormat:@"%@",deviceToken];
    NSString *newString = [strDeviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([newString hasPrefix:@"<"] && [newString length] > 1) {
        newString = [newString substringFromIndex:1];
    }
    NSString *newStringfinal = [newString substringToIndex:[newString length]-1];


    [[NSUserDefaults standardUserDefaults] setObject:newStringfinal forKey:@"deviceID"];
    [[NSUserDefaults standardUserDefaults]synchronize];

}


- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Registration for remote notification failed with error: %@", error.localizedDescription);
    
}


- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Notification received: %@", userInfo);
   
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler {
    
    NSLog(@"Notification received: %@", userInfo);
    application.applicationIconBadgeNumber=0;
    
    handler(UIBackgroundFetchResultNewData);
    if(application.applicationState == UIApplicationStateInactive) {
        application.applicationIconBadgeNumber=0;

    }
    else if (application.applicationState == UIApplicationStateBackground) {
        
        NSLog(@"Background");

        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        ViewController *main = (ViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"ViewController"];
        
        self.window.rootViewController = main;
        application.applicationIconBadgeNumber=0;
        //Refresh the local model
        
        handler(UIBackgroundFetchResultNewData);
        
    } else {
        
        NSLog(@"Active");
        //Show an in-app banner
        
        handler(UIBackgroundFetchResultNewData);
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Alert" message:userInfo[@"aps"][@"alert"] delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        
        application.applicationIconBadgeNumber=0;
        
    }
     
    
    // [END_EXCLUDE]
}


- (void)didDeleteMessagesOnServer {
    // Some messages sent to this device were deleted on the GCM server before reception, likely
    // because the TTL expired. The client should notify the app server of this, so that the app
    // server can resend those messages.
}
-(void)directCall
{
    NSString *strPhone=@"+919099905688";
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@",strPhone]];
    if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
        [[UIApplication sharedApplication] openURL:phoneURL];
    }
    else{
        UIAlertView *callAlert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [callAlert show];
        
    }
    
}
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    self.interactivePopGestureRecognizer.delegate=self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled=NO;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma  mark- General Web service GET Method
///block webserice method
-(void)webserviceCallFor2:(NSString *)mainUrl appendUrl1:(NSString *)appendUrlStr
               appendUrl2:(NSString *)appendSecondUrl AndPerformCompletion:(void(^)(NSData *responseData))getMethod{
    [SVProgressHUD  showWithStatus:@"Loading.."];
    [self.window setUserInteractionEnabled:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, NO), ^{
        
        NSMutableString *loginrequest=[[NSMutableString alloc] initWithString:mainUrl];
        [loginrequest appendString:[NSString stringWithFormat:@"%@",appendUrlStr]];
        [loginrequest appendString:[NSString stringWithFormat:@"%@",appendSecondUrl]];
        
        NSURLSessionConfiguration* sessionConfiguration=[NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSURLSession* session=[NSURLSession sessionWithConfiguration:sessionConfiguration];
        NSURL *requestURL=[NSURL URLWithString:loginrequest];
        
        NSURLSessionDataTask* sessionTask=[session dataTaskWithURL:requestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                if (data) {
                    getMethod(data);
                    [self.window setUserInteractionEnabled:YES];
                    [SVProgressHUD dismiss];
                    
                }
                else{
                    [self.window setUserInteractionEnabled:YES];
                    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NULL message:@"Server Error..." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [alert show];
                    [self performSelector:@selector(dismiss:) withObject:alert afterDelay:1.0];
                    [SVProgressHUD dismiss];
                }
                
            });
            
        }];
        [sessionTask resume];
        
    });
}

///////////
-(void)webserviceCallFor3:(NSString *)mainUrl appendUrl1:(NSString *)appendUrlStr appendUrl2:(NSString *)appendSecondUrl appendUrl3:(NSString *)appendThirdUrl AndPerformCompletion:(void (^)(NSData *))getMethod{
    
     [SVProgressHUD  showWithStatus:@"Loading.."];
    [self.window setUserInteractionEnabled:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, NO), ^{
        
        NSMutableString *loginrequest=[[NSMutableString alloc] initWithString:mainUrl];
        [loginrequest appendString:[NSString stringWithFormat:@"%@",appendUrlStr]];
        [loginrequest appendString:[NSString stringWithFormat:@"%@",appendSecondUrl]];
        [loginrequest appendString:[NSString stringWithFormat:@"%@",appendThirdUrl]];
        
        NSURLSessionConfiguration* sessionConfiguration=[NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSURLSession* session=[NSURLSession sessionWithConfiguration:sessionConfiguration];
        NSURL *requestURL=[NSURL URLWithString:loginrequest];
        
        NSURLSessionDataTask* sessionTask=[session dataTaskWithURL:requestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                if (data) {
                    getMethod(data);
                    [self.window setUserInteractionEnabled:YES];
                    [SVProgressHUD dismiss];
                    
                }
                else{
                    [self.window setUserInteractionEnabled:YES];
                    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NULL message:@"Server Error..." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    
                    
                    [alert show];
                    [self performSelector:@selector(dismiss:) withObject:alert afterDelay:1.0];

                }
                
            });
            
        }];
        [sessionTask resume];
        
    });
    
    
}
-(void)webserviceCallFor4:(NSString *)mainUrl appendUrl1:(NSString *)appendUrlStr
               appendUrl2:(NSString *)appendSecondUrl appendUrl3:(NSString *)appendThirdUrl appendUrl4:(NSString *)append4thUrl AndPerformCompletion:(void(^)(NSData *responseData))getMethod{
    
     [SVProgressHUD  showWithStatus:@"Loading.."];
    [self.window setUserInteractionEnabled:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, NO), ^{
        
        NSMutableString *loginrequest=[[NSMutableString alloc] initWithString:mainUrl];
        [loginrequest appendString:[NSString stringWithFormat:@"%@",appendUrlStr]];
        [loginrequest appendString:[NSString stringWithFormat:@"%@",appendSecondUrl]];
        [loginrequest appendString:[NSString stringWithFormat:@"%@",appendThirdUrl]];
        [loginrequest appendString:[NSString stringWithFormat:@"%@",append4thUrl]];
        
        NSURLSessionConfiguration* sessionConfiguration=[NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSURLSession* session=[NSURLSession sessionWithConfiguration:sessionConfiguration];
        NSURL *requestURL=[NSURL URLWithString:loginrequest];
        
        NSURLSessionDataTask* sessionTask=[session dataTaskWithURL:requestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                if (data) {
                    getMethod(data);
                    [self.window setUserInteractionEnabled:YES];
                    [SVProgressHUD dismiss];
                    
                }
                else{
                    [self.window setUserInteractionEnabled:YES];
                    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NULL message:@" Server Error..." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    
                    
                    [alert show];
                    [self performSelector:@selector(dismiss:) withObject:alert afterDelay:1.0];
                }
                
            });
            
        }];
        [sessionTask resume];
        
    });
    
}

/////post webservice call
-(void)postWebserviceCall:(NSString *)mainUrl appendUrl1:(NSString *)appendUrlStr  appendDictionary:(NSDictionary *)appendDictionary AndPerformCompletion:(void(^)(NSData *responseData))PostMethod{
    
     [SVProgressHUD  showWithStatus:@"Loading Data..."];
    [self.window setUserInteractionEnabled:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, NO), ^{
        
        NSMutableString *loginrequest=[[NSMutableString alloc] initWithString:mainUrl];
        [loginrequest appendString:appendUrlStr];
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:appendDictionary options:0 error:nil];
        NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc]init];
        [request1 setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",loginrequest]]];
        [request1 setHTTPMethod:@"POST"];
        [request1 setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSURLSessionUploadTask *dataTask = [session uploadTaskWithRequest: request1 fromData: data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            dispatch_sync(dispatch_get_main_queue(), ^
            {
                if (data)
                {
                    PostMethod(data);
                    [self.window setUserInteractionEnabled:YES];
                    
                    [SVProgressHUD dismiss];
                }
                else{
                    [self.window setUserInteractionEnabled:YES];
                    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NULL message:@" Server Error..." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                    [alert show];
                    [self performSelector:@selector(dismiss:) withObject:alert afterDelay:1.0];

                    [SVProgressHUD dismiss];
                }
            });
        }];
        
        [dataTask resume];
    });
    
}


-(void)dismiss:(UIAlertView*)alert
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}
@end
 