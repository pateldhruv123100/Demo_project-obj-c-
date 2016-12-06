//
//  ViewController.m
//  IM-HERE
//
//  Created by dhruv patel on 16/06/16.
//  Copyright © 2016 dhruv patel. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Map_VC.h"
#import "HOMEScreen_VC.h"
#import "Alert_ListVC.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "OpenUDID.h"

@interface ViewController ()<UINavigationControllerDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtUserID;
@property (weak, nonatomic) IBOutlet UITextField *txtPassWord;
- (IBAction)btnCheckBox:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIButton *checkBox;
- (IBAction)btnLogin:(UIButton *)sender;
@end

@implementation ViewController{
    NSDictionary *jsonDict;
    NSString *strReg;
    NSString* openUDID;
    
}

@synthesize checkBox;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    [self.view setUserInteractionEnabled:NO];
    
    self.interactivePopGestureRecognizer.delegate=self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled=NO;
    }
    
    myAppDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
   
    openUDID=[OpenUDID value];
    strReg=[[NSString alloc]init];
    //For Push Notification Handler
    [SVProgressHUD showWithStatus:@"Preparing For Login"];
    
    /////For Hide Navigation Bar
    if([[myAppDelegate.dictLogin valueForKey:@"bIsAssetTracking"]integerValue])
    {
        [self.navigationController setTitle:@"Asset List"];
    }
    else
    {
        [self.navigationController setTitle:@"Vehical List"];
    }
    
    [self.txtUserID setDelegate:self];
    [self.txtPassWord setDelegate:self];
    
    
    
    UIView *paddingViewUserID = [[UIView alloc] initWithFrame:CGRectMake(0, 0,60,40)];
    
    _txtUserID.leftView = paddingViewUserID;
    _txtUserID.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *paddingViewPassWord = [[UIView alloc] initWithFrame:CGRectMake(0, 0,60,40)];
    
    _txtPassWord.leftView = paddingViewPassWord;
    _txtPassWord.leftViewMode = UITextFieldViewModeAlways;
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // D_ispose of any resources that can be recreated.
}


#pragma mark-textField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField


{
    if(textField == self.txtUserID){
        
        [self.txtPassWord becomeFirstResponder];
    }
    else if(textField == self.txtPassWord) {
        
        [textField resignFirstResponder];
        [self btnLogin:nil];
    }
    
    return YES;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self.view setUserInteractionEnabled:YES];
    self.checkBox.tag=0;
    [self.checkBox setBackgroundImage:[UIImage imageNamed:@"cb_glossy_off.png"] forState:UIControlStateNormal];
    if ([USERDEFAULT boolForKey:@"isRemember"])
    {
        self.checkBox.tag=1;
        [self.checkBox setBackgroundImage:[UIImage imageNamed:@"cb_glossy_on.png"] forState:UIControlStateNormal];
        self.txtUserID.text=[USERDEFAULT valueForKey:@"username"];
        self.txtPassWord.text=[USERDEFAULT valueForKey:@"password"];
        
    }
    
}


#pragma mark - Touch Events
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch=[[event allTouches] anyObject];
    if([self.txtUserID isFirstResponder] && [touch view] != self.txtUserID){
        [self.txtUserID resignFirstResponder];
    }
    
    if([self.txtPassWord isFirstResponder] && [touch view] != self.txtPassWord) {
        [self.txtPassWord resignFirstResponder];
        
    }
    
    [super touchesBegan:touches withEvent:event];
}

-(void)hidesIndicator
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.txtPassWord resignFirstResponder];
        [self.txtUserID setText:@""];
        [self.txtPassWord setText:@""];
        
        [self.view setUserInteractionEnabled:YES];
        
        
        // [self.imageView setImage:[UIImage imageWithData:data]];
    });
}
-(void)dataRequire:(NSString*)urlRequest{
    
    NSURLSessionConfiguration* sessionConfig=[NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session=[NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:Nil];
    
    NSURLSessionDownloadTask* downloadTask=[session downloadTaskWithURL:[NSURL URLWithString:urlRequest]];
    
    [downloadTask resume];
    
}
#pragma mark - Session Data Delegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    
    
    NSData *data = [NSData dataWithContentsOfURL:location];
    
    NSError* jsonParseingError;
    
    // NSString* datarcv=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //  NSLog(@"data :: %@",datarcv);
    
    myAppDelegate.vehicleList=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonParseingError];
    if (jsonParseingError!=NULL) {
        
        NSLog(@"JSON Parseing Error: %@",jsonParseingError.domain);
        
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.txtUserID setText:@""];
        [self.txtPassWord setText:@""];
        
        [self.view setUserInteractionEnabled:YES];
        //[self performSegueWithIdentifier:@"loginSuccess" sender:nil];
        
        
        // [self.imageView setImage:[UIImage imageWithData:data]];
    });
    
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    // [self performSegueWithIdentifier:@"loginSuccess" sender:nil];
    //[_indicatorView setHidden:YES];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self.progressView setProgress:progress];
    });
}



- (IBAction)btnCheckBox:(UIButton *)sender;
{
    UIButton *btn=(UIButton *)sender;
    if(btn.tag == 0)
    {
        btn.tag=1;
        [btn setBackgroundImage:[UIImage imageNamed:@"cb_glossy_on.png"] forState:UIControlStateNormal];
        
    }
    else
    {
        btn.tag=0;
        [btn setBackgroundImage:[UIImage imageNamed:@"cb_glossy_off.png"] forState:UIControlStateNormal];
    }}

-(void)loginRequest:(NSString*)urlLoginRequest{
    
    [self.view setUserInteractionEnabled:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, NO), ^{
        NSURLSessionConfiguration* sessionConfiguration=[NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSURLSession* session=[NSURLSession sessionWithConfiguration:sessionConfiguration];
        NSURL *requestURL=[NSURL URLWithString:urlLoginRequest];
        
        NSURLSessionDataTask* sessionTask=[session dataTaskWithURL:requestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
            {
                if(data)
                {
                    jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                        if (jsonDict.count>0)
                        {
                            NSString *strmsg=jsonDict[@"Message"];
                            if ([strmsg  isEqual: @"Success"])
                            {NSArray *arrVehicleDetail=jsonDict[@"vehicleDetails"];
                                NSMutableArray *arrVehicleNo=[[NSMutableArray alloc]init];
                                NSMutableArray *arrVehicleID=[[NSMutableArray alloc]init];
                                NSMutableArray *arrTrackerName=[[NSMutableArray alloc]init];
                                for (int i=0; i<arrVehicleDetail.count; i++)
                                {
                                    [arrVehicleNo addObject:[NSString stringWithFormat:@"%@",arrVehicleDetail[i][@"vnumber"]]];
                                    [arrVehicleID addObject:[NSString stringWithFormat:@"%@",arrVehicleDetail[i][@"VehicleId"]]];
                                    [arrTrackerName addObject:[NSString stringWithFormat:@"%@",arrVehicleDetail[i][@"trackername"]]];
                                }
                                [USERDEFAULT setObject:arrVehicleNo forKey:@"vehicle NUmber"];
                                [USERDEFAULT setObject:arrVehicleID forKey:@"Vehicle id"];
                                [USERDEFAULT setObject:arrTrackerName forKey:@"Tracker Name"];
                                [USERDEFAULT setObject:jsonDict[@"loginModel"][@"Customerid"] forKey:@"userId"];
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                [self.view setUserInteractionEnabled:YES];
                                [self uploadIphoneInformationForPushNotification ];
                                HOMEScreen_VC *HomeScreen=[self.storyboard instantiateViewControllerWithIdentifier:@"HOMEScreen_VC"];
                                [self.navigationController pushViewController:HomeScreen animated:YES];
                                });
                            }
                            else{
                                dispatch_sync(dispatch_get_main_queue(), ^{
                                UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NULL message:@"Please Enter Valid UserID Or PassWord" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                                [self.view setUserInteractionEnabled:YES];
                                [SVProgressHUD dismiss];
                                [alert show];
                                });
                                }
                        }
                }
                else{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NULL message:@"Please Enter Valid UserID Or PassWord" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                        [self.view setUserInteractionEnabled:YES];
                        [SVProgressHUD dismiss];
                        [alert show];
                    });
                }

                
            }];
        
        [sessionTask resume];
    });
    
}

-(void)uploadIphoneInformationForPushNotification
{
    
    NSMutableString *loginrequest=[[NSMutableString alloc] initWithString:myAppDelegate.request];
    [loginrequest appendString:@"CustomerRegisterDetail/"];
    NSString *strDevice=[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceID"];
    if (!(strDevice ==NULL)) {
        NSDictionary *parameters = @{
                                     @"CustomerId":[NSString stringWithFormat:@"%@",[USERDEFAULT valueForKey:@"userId"]],
                                     @"IMEI":[NSString stringWithFormat:@"%@",openUDID],
                                     @"GcmRegID":[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceID"],
                                     @"DeviceType":@"iPhone",
                                     @"DeviceInfo":@"iPhone",
                                     };
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, NO), ^{
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",loginrequest]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"content-type"];
            
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            NSURLSessionUploadTask *dataTask = [session uploadTaskWithRequest: request
                                                                     fromData: data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                                {
                                                    dispatch_sync(dispatch_get_main_queue(), ^
                                                    {
                                                        if (error)
                                                        {
                                                            NSLog(@"Error while Uploading Device Token For Push Notification :%@",error.description);
                                                        }
                                                        if (response)
                                                        {
                                                            NSLog(@"Response is :%@",response);
                                                        }
                                                     });
                                                  }];
            
            [dataTask resume];
        });
 
    }
    else{
            UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NULL message:@"Simulator cant get devicetoken Please install application on Device " delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [self.view setUserInteractionEnabled:YES];
            [SVProgressHUD dismiss];
            [alert show];
    }
    
    
}

//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if([[textField text] length] > 0) {
//        if([[textField text] characterAtIndex:([[textField text] length]-1)] == ' ' &&
//           [string isEqualToString:@" "]) return NO;
//    }
//    return YES;
//}
- (IBAction)btnLogin:(UIButton *)sender {
    [SVProgressHUD showWithStatus:@"Logging..."];
    if ([_txtUserID.text length]==0)
    {
        
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"" message:@"Enter User Name" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        [SVProgressHUD dismiss];
        
    }
    else if ([_txtPassWord.text length]==0)
    {
        
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"" message:@"Enter Password" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        [SVProgressHUD dismiss];
        
    }else if([_txtUserID.text length]==0 && [_txtPassWord.text length]==0)
    {
        
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"" message:@"Enter User name and Password" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        [SVProgressHUD dismiss];
        
    }  else
    {
        
        
        [myAppDelegate.internetReachability startNotifier];
        
        NetworkStatus status = [myAppDelegate.internetReachability currentReachabilityStatus];
        //BOOL connectionRequired = [self.internetReachability connectionRequired];
        
        if(status==NotReachable)
        {
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Internet Connection Required" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
            [SVProgressHUD dismiss];
        }
        
        else{
            
            NSMutableString*loginrequest=[[NSMutableString alloc] initWithString:myAppDelegate.request];
            
            NSLog(@"userid is:%@",_txtUserID.text);
            
            
//            NSString *trimmedUserID = [_txtUserID.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSArray* words = [_txtUserID.text componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString* nospacestring = [words componentsJoinedByString:@""];
            _txtUserID.text=[NSString stringWithFormat:@"%@",nospacestring];
            [loginrequest appendString:@"Login/"];
            [loginrequest appendString:nospacestring];
            [loginrequest appendString:@"/"];
            [loginrequest appendString:_txtPassWord.text];
            if (self.checkBox.tag==1)
            {
                
                [USERDEFAULT setObject:_txtPassWord.text forKey:@"password"];
                
                
                [USERDEFAULT setObject:nospacestring forKey:@"username"];
                
                [USERDEFAULT setBool:YES forKey:@"isRemember"];
                [USERDEFAULT synchronize];
            }
            else
            {
                [USERDEFAULT removeObjectForKey:@"password"];
                [USERDEFAULT removeObjectForKey:@"username"];
                [USERDEFAULT removeObjectForKey:@"userId"];
                [USERDEFAULT setBool:NO forKey:@"isRemember"];
                [USERDEFAULT synchronize];
            }
            [self loginRequest:loginrequest];
            
        }
    }
}
@end



