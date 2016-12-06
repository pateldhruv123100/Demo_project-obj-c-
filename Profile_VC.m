//
//  Profile_VC.m
//  IM-HERE
//
//  Created by dhruv patel on 16/06/16.
//  Copyright © 2016 dhruv patel. All rights reserved.
//

#import "Profile_VC.h"
#import "AppDelegate.h"
#import "HOMEScreen_VC.h"
#import <SVProgressHUD.h>

@interface Profile_VC ()

@end

@implementation Profile_VC
{
    AppDelegate *myAppDelegate;
    NSMutableArray *arrCustomerDetails;
    NSMutableArray *mutarr;
    NSMutableDictionary *dictcustomerProfile;
    UIImagePickerController *imgPicker;
    NSDictionary *dictUserData;
    NSString *strUserId;
    NSString *imageString;
    UIImage *img;
    NSString *documentsDirectory;
    BOOL isFullScreen;
    CGRect prevFrame;
    NSString *filePath ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isFullScreen = FALSE;
    _prewvImg.hidden=YES;
    strUserId=[USERDEFAULT valueForKey:@"userId"];
   
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    myAppDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    imgPicker=[[UIImagePickerController alloc]init];
    imgPicker.delegate=(id)self;
    imgPicker.allowsEditing=YES;
    self.ProfileimgView.layer.cornerRadius = self.ProfileimgView.frame.size.width / 2;
    self.ProfileimgView.clipsToBounds = YES;
    
    
    mutarr=[[NSMutableArray alloc]init];
    dictcustomerProfile=[[NSMutableDictionary alloc]init];
    dictUserData=[[NSDictionary alloc]init];
   
    
    //document directory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"%@",documentsDirectory);
    
    
    //webservice call
    [myAppDelegate webserviceCallFor2:myAppDelegate.request appendUrl1:@"CustomerProfile/" appendUrl2:strUserId AndPerformCompletion:^(NSData *responseData) {
       [SVProgressHUD  show];
        dictUserData=[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSLog(@"arra is :%@",dictUserData);
        
        _lblUserName.text=dictUserData[@"Username"];
        _lblName.text=dictUserData[@"FirstName"];
        _lblCompnyName.text=dictUserData[@"CompanyName"];
        _lblCntctNo.text=dictUserData[@"Mobile"];
        _lblEmailId.text=dictUserData[@"Email"];
        _lblSmsCount.text=[NSString stringWithFormat:@"%@",dictUserData[@"SMSCount"]];
        
        
        NSString *strImgName = dictUserData[@"Photo"];
        
        if ([strImgName isEqual:[NSNull null]]) {
            _ProfileimgView.image=[UIImage imageNamed:@"profilegreyicon.png"];
        }
        else{

        filePath= [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",strImgName]];
        //Add the file name
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
        if (fileExists) {
            
            UIImage *imgpro=[UIImage imageWithContentsOfFile:filePath];
            
            _ProfileimgView.image=imgpro;
            
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, NO), ^{
                NSURL *url=[NSURL URLWithString:[ NSString stringWithFormat:@"http://163.172.20.165/ImHereWebAPI/Images/Customer/%@",dictUserData[@"Photo"]]];
                NSData *data=[NSData dataWithContentsOfURL:url];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    _ProfileimgView.image=[UIImage imageWithData:data];
                     [data writeToFile:filePath atomically:YES];
                });
            });
        }
        
        }
   
        [SVProgressHUD  dismiss];
        
        
    }];
    
    _ProfileimgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapToviewLargeImage)];
    [_ProfileimgView addGestureRecognizer:singleFingerTap];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- Profile Pic Image Picker

- (IBAction)btnActionImagePick:(UIButton *)sender {
    NSLog(@"clicked");
    UIAlertController  *alrt=[UIAlertController alertControllerWithTitle:nil message:@"Add Photo" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *actionGallery=[UIAlertAction actionWithTitle:@"Gallery" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Gallery  Selected");
        imgPicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imgPicker animated:YES completion:nil];
        
    }];
    UIAlertAction *actionCamera=[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imgPicker.sourceType=UIImagePickerControllerSourceTypeCamera;
            [imgPicker setAllowsEditing:YES];

            [self presentViewController:imgPicker animated:YES completion:^{
                
            }];
        }
        else{
            NSLog(@"Camera Hardware  is not found");
            UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"Hardware not Found" message:@"Sorry Hardware is not found" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *alrtActn=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:alrtActn];
            [self presentViewController:alert animated:YES completion:nil];
            
        }
        
    }];
    
    UIAlertAction *actionCancel=[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Cancel");
    }];
    
    [alrt addAction:actionCamera];
    [alrt addAction:actionGallery];
    [alrt addAction:actionCancel];
    
    [self presentViewController:alrt animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"Did finish ..Selected Photo");
    img=info[UIImagePickerControllerEditedImage];
    _ProfileimgView.image=img;
    [imgPicker dismissViewControllerAnimated:YES completion:nil];
    // [self uploadImage];
    
    
    
   //  Upload Image to Web Service
    NSData *imageData = UIImageJPEGRepresentation(img, 1.0);
    NSString *base64String = [imageData base64EncodedStringWithOptions:kNilOptions];
    NSDictionary *parameters = @{
                                 @"CustomerId": strUserId,
                                 @"photoArray": base64String,
                                 
                                 };
    [myAppDelegate postWebserviceCall:myAppDelegate.request appendUrl1:@"ImageUpload/" appendDictionary:parameters AndPerformCompletion:^(NSData *responseData) {
       
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        NSLog(@"response of upload image %@",json);
    }];
    
}

-(void)tapToviewLargeImage{
    
    //goto new ViewController and set the image
    
    if (!isFullScreen) {
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
         
            _prewvImg.hidden=NO;
            _prewvImg.image=[UIImage imageWithContentsOfFile:filePath];
            _prewvImg.layer.cornerRadius = self.ProfileimgView.frame.size.width / 2;
            _prewvImg.clipsToBounds = YES;
            CATransition *transition = [CATransition animation];
            transition.duration = 0.50f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            
            [_prewvImg.layer addAnimation:transition forKey:nil];
            
            //[self.view.window addSubview:_ProfileimgView];
            
        }completion:^(BOOL finished){
            
            isFullScreen = TRUE;
            
        }];
        return;
    }
    else {
        [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
//            [_ProfileimgView setFrame:prevFrame];
            _prewvImg.hidden=YES;
            
        } completion:^(BOOL finished){
            isFullScreen = FALSE;
        }];
        return;
    }
}

- (IBAction)btnActionHome:(UIButton *)sender {
    HOMEScreen_VC *HomeScreen=[self.storyboard instantiateViewControllerWithIdentifier:@"HOMEScreen_VC"];
    [SVProgressHUD dismiss];
    [self.navigationController pushViewController:HomeScreen animated:NO];
    
}

- (IBAction)btnActionContactUs:(UIButton *)sender {
    contactUsProfile_VC *dvc=[self.storyboard instantiateViewControllerWithIdentifier:@"contactUsProfile_VC"];
    [SVProgressHUD dismiss];
    [self.navigationController pushViewController:dvc animated:YES];
}

- (IBAction)btnActionCall:(UIButton *)sender {
    [SVProgressHUD dismiss];
    [myAppDelegate directCall];
}
@end
