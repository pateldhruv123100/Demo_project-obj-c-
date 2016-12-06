//
//  MapViewByListView_vc.m
//  IM-HERE
//
//  Created by iMac-meridian on 6/21/16.
//  Copyright © 2016 dhruv patel. All rights reserved.
//

#import "MapViewByListView_vc.h"
@import GoogleMaps;
#import "AppDelegate.h"
#import "HOMEScreen_VC.h"
#import <SVProgressHUD.h>
#import "Alert_ListVC.h"
#import "Track_HistoryVC.h"
#import "List _ViewVC.h"

@interface MapViewByListView_vc ()<GMSMapViewDelegate>
@property (nonatomic, strong) NSTimer *timer;


@end

@implementation MapViewByListView_vc{
    
    AppDelegate *myAppDelegate;
    NSDictionary *arrVehicleDetails;
    NSMutableArray *arrnewLocation;
    NSMutableDictionary *dictlocation;
    GMSMarker *marker;
    GMSMapView *mapview_;
    GMSMutablePath *path;
    NSTimer *timer2;
    NSTimeInterval *timINt;
    NSDictionary *dictDetail;
    
    
}

bool isShown = true;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    myAppDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];


  
    
    [SVProgressHUD showWithStatus:@"Tracking vehicle"];
    //[self webserviceCall];
    
   
    NSLog(@"selected tracker id is :%@",_strTrackerID);
    path = [GMSMutablePath path];
    [self.view addSubview:_viewTitle];
    
    dictDetail=[[NSDictionary alloc]init];
    arrnewLocation=[[NSMutableArray alloc]init];
    dictlocation=[[NSMutableDictionary alloc]init];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:20.5937
                                                            longitude:78.9629
                                                                 zoom:10];
    mapview_ = [GMSMapView mapWithFrame:self.view.frame camera:camera];
    mapview_.myLocationEnabled = YES;
    mapview_.mapType=kGMSTypeNormal;
    //[_viewMap addSubview:mapview_];
    _viewMap=mapview_;
    [self.view addSubview:_viewMap];
    [self.view addSubview:_viewBottom];
   
    [self.view addSubview:_viewDetailUpDown];
    [self.view addSubview:_mapTypeSegment];
    [self.view addSubview:_popupScreen];
    [self.view addSubview:_viewDetail];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap)];
    [_popupScreen addGestureRecognizer:singleFingerTap];
    
    
    
    mapview_.delegate = self;
    
    timer2=[NSTimer scheduledTimerWithTimeInterval:08.0
                                            target:self
                                          selector:@selector(webServiceCallForVehicleDetail)
                                          userInfo:nil
                                           repeats:YES];
    [self webServiceCallForVehicleDetail];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.view.window == nil) //you should be sure what the view is removed from the window
    {
        self.view = nil;
        //remove other temporary objects
        [timer2 invalidate];
        
    }
}
-(void)handleSingleTap{
    if (!isShown) {
        NSLog(@"View show");
        //_viewDetail.hidden=NO;
        [UIView transitionWithView:_viewDetail
                          duration:0.20
                           options:UIViewAnimationOptionTransitionFlipFromBottom
                        animations:^{
                            _viewDetail.hidden = NO;
                        }
                        completion:NULL];
        
        
        [self.view addSubview:_viewDetail];
        isShown = true;
    }
    else{
        NSLog(@"View Hide....");
        [UIView animateWithDuration:0.25 animations:^{
            _popupScreen.frame =  CGRectMake(0,self.view.frame.size.height-74, self.view.frame.size.width,34);}];
        [UIView transitionWithView:_viewDetail
                          duration:0.35
                           options:UIViewAnimationOptionTransitionFlipFromTop
                        animations:^{
                            _viewDetail.hidden = YES;
                        }
                        completion:NULL];
        
        
        isShown = false;
    }
    
}

-(void)ShowAnnotation{
     marker.map  = nil;
    [SVProgressHUD showWithStatus:@"Placing Vehicle on Map"];
    //NSString *strLat=[NSString stringWithFormat:@"%@",dictDetail[@"dlat"]];
    
    if (![dictDetail[@"dlat"] isEqual: [NSNull null]] && ![dictDetail[@"dlong"] isEqual: [NSNull null]] )
    {
        ///////.///map
        double latnew=[dictDetail[@"dlat"]doubleValue];
        double lonnew=[dictDetail[@"dlong"]doubleValue];
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(latnew,lonnew);
        marker = [GMSMarker markerWithPosition:position];
        marker.appearAnimation = YES;
        marker.flat = YES;
        NSString *strIgnition=[NSString stringWithFormat:@"%@",dictDetail[@"ignition"]];
        
        NSString *strSpeed=[NSString stringWithFormat:@"%@",dictDetail[@"speed"]];
        if ([strIgnition isEqualToString:@"ON"] &&[strSpeed integerValue]==0 ) {
            marker.icon=[UIImage imageNamed:@"car_Blue"];
        }
        else if ([strIgnition isEqualToString:@"OFF"]){
            marker.icon=[UIImage imageNamed:@"car_Red"];
        }
        else if ([strIgnition isEqualToString:@"ON"]){
            marker.icon=[UIImage imageNamed:@"car_Green"];
        }
        
        
        marker.snippet = @"";
        
        marker.map = mapview_;
        [SVProgressHUD dismiss];
        
        
        for (int i=0; i<=arrnewLocation.count; i++)
        {
            [path addLatitude:latnew longitude:lonnew];
            
        }
        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
        polyline.strokeColor = [UIColor blackColor];
        polyline.strokeWidth = 3.f;
        polyline.map = mapview_;
        
        GMSCameraUpdate *centerCamera = [GMSCameraUpdate setTarget:position];
        [mapview_ animateWithCameraUpdate:centerCamera];
        
        //    GMSCameraUpdate *updatedCamera = [GMSCameraUpdate setTarget:position zoom:15];
        //    [mapview_ animateWithCameraUpdate:updatedCamera];
        
        ///////////Print Label
        
        if (isShown) {
            [SVProgressHUD showWithStatus:@"Placing Vehicle on Map"];
            _viewDetail.hidden=NO;
            _popupScreen.hidden=NO;
            
            
            //label
            _lblVehicleNumeber.text=dictDetail[@"vehiclenum"];
            _lblSpeed.text=[NSString stringWithFormat:@"%@",dictDetail[@"speed"]];
            if([dictDetail[@"speed"]intValue] >0){
                _lblRunnig_Stop.text=@"Running";
                _lblStop1.text=[NSString stringWithFormat:@"%@",dictDetail[@"ContinueRunning"]];
            }
            else{
                _lblRunnig_Stop.text=@"Stop";
                _lblStop1.text=[NSString stringWithFormat:@"%@",dictDetail[@"ContinueParked"]];
                
            }
            
            
            
            _lblAddress.text=[NSString stringWithFormat:@"%@",dictDetail[@"Address"]];
            _lblDistance.text=[NSString stringWithFormat:@"%@",dictDetail[@"DailyKms"]];
            
            _lblIgnition.text=[NSString stringWithFormat:@"%@",dictDetail[@"ignition"]];
            if ([dictDetail[@"ignition"] isEqualToString:@"OFF"]) {
                
                _lblIgnition.textColor=[UIColor redColor];
            }
            else{
                
                _lblIgnition.textColor=[UIColor greenColor];
                
            }
            //Image
            
            if ([dictDetail[@"battery"]  isEqualToString:@"Connected"]) {
                _imgBattry.image=[UIImage imageNamed:@"vehiclescreenbatterygreen4icon.png"];
            }else{
                _imgBattry.image=[UIImage imageNamed:@"vehiclescreenbatterywhite0icon.png"];
            }
            
            if ([dictDetail[@"bGPS"] isEqualToString:@"Fixed"]) {
                _imgSignal.image=[UIImage imageNamed:@"vehiclescreensignalgreen2icon.png"];
            }
            else{
                _imgSignal.image=[UIImage imageNamed:@"vehiclescreensignalwhite1icon.png"];
            }
            if ([dictDetail[@"ignition"] isEqualToString:@"ON"]) {
                _imgDoor.image=[UIImage imageNamed:@"cargreen.png"];
            }
            else{
                _imgDoor.image=[UIImage imageNamed:@"carwhitebig.png"];
            }
            
            if([dictDetail[@"myFuelVoltage"]intValue] ==0){
                _imgFuel.image=[UIImage imageNamed:@"vehiclescreenfuelwhiteicon.png"];
            }
            else{
                _imgFuel.image=[UIImage imageNamed:@"vehiclescreenfuelgreenicon.png"];
            }
            if ([dictDetail[@"ac"] isEqualToString:@"OFF"]) {
                _imgAc.image=[UIImage imageNamed:@"vehiclescreenacwhiteicon.png"];
            }
            else{
                _imgAc.image=[UIImage imageNamed:@"vehiclescreenacgreenicon.png"];
            }
            
            [SVProgressHUD dismiss];
        }
        
        
        
        _viewMap=mapview_;

        
        
        
    }
    else{
        NSLog(@"cant get latitute and longitute");
        
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"Data Not Found" message:@"Tracker Location Not Found" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        
        [alert show];
        
        if ([timer2 isValid])
        {
            [timer2 invalidate];
            timer2=NULL;
            NSLog(@"TIMER IS STOPED%@",timer2);
            //mapview_=nil;
            
        }
    }
   
    
}

-(void)displayData{
    
    
}


-(void)webServiceCallForVehicleDetail{
    // marker.map  = nil;
    //[SVProgressHUD showWithStatus:@"Waiting For New Location"];
    NSString  *strUserId=[USERDEFAULT valueForKey:@"userId"];
    NSMutableString *loginrequest=[[NSMutableString alloc] initWithString:myAppDelegate.request];
    [loginrequest appendString:@"LiveMapDetails/"];
    [loginrequest appendString:[NSString stringWithFormat:@"%@/",strUserId]];
    
//    NSString *str=[_strTrackerID objectAtIndex:0];
    [loginrequest appendString:[NSString stringWithFormat:@"%@",_strTrackerID]];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, NO), ^{
        
        NSURLSessionConfiguration* sessionConfiguration=[NSURLSessionConfiguration defaultSessionConfiguration];
        
        NSURLSession* session=[NSURLSession sessionWithConfiguration:sessionConfiguration];
        NSURL *requestURL=[NSURL URLWithString:loginrequest];
        
        NSURLSessionDataTask* sessionTask=[session dataTaskWithURL:requestURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if(data)
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        dictDetail=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                        NSLog(@"dic is :%@",dictDetail);
                         [self ShowAnnotation];
                        //[self displayData];
                        [SVProgressHUD dismiss];
                    });
                    
                }
                else{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        
                        NSLog(@"Error parsing JSON.");
                        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:NULL message:@"Server Error" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                        
                        [alert show];
                        [self performSelector:@selector(dismiss:) withObject:alert afterDelay:1.0];
                        //[SVProgressHUD dismiss];
                    });
                }
           
            
            
        }];
        [sessionTask resume];
    });
    
    
}
-(void)dismiss:(UIAlertView*)alert
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (IBAction)objSegment:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex==0) {
        mapview_.mapType=kGMSTypeNormal;
    }
    else if (sender.selectedSegmentIndex==1)
    {
        mapview_.mapType=kGMSTypeSatellite;
    }
    else if (sender.selectedSegmentIndex==2)
    {
        mapview_.mapType=kGMSTypeHybrid;
    }
    else if (sender.selectedSegmentIndex==3)
    {
        mapview_.mapType=kGMSTypeTerrain;
    }
}


- (IBAction)btnActionHome:(id)sender {
   // List__ViewVC *hvc=[self.storyboard instantiateViewControllerWithIdentifier:@"List__ViewVC"];
    if ([timer2 isValid])
    {
        [timer2 invalidate];
        timer2=NULL;
        NSLog(@"TIMER IS STOPED%@",timer2);
        mapview_=nil;
        [SVProgressHUD dismiss];
        
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    
}
- (IBAction)btnActionAlert:(UIButton *)sender {
    if ([timer2 isValid])
    {
        [timer2 invalidate];
        timer2=NULL;
        NSLog(@"TIMER IS STOPED%@",timer2);
        mapview_=nil;
    }
    Alert_ListVC *avc=[self.storyboard instantiateViewControllerWithIdentifier:@"Alert_ListVC"];
    mapview_=nil;
    [SVProgressHUD dismiss];
    [self.navigationController pushViewController:avc animated:YES];
}

- (IBAction)btnActionTrackHistory:(UIButton *)sender {
    if ([timer2 isValid])
    {
        [timer2 invalidate];
        timer2=NULL;
        NSLog(@"TIMER IS STOPED%@",timer2);
        mapview_=nil;
        
    }
    Track_HistoryVC *avc=[self.storyboard instantiateViewControllerWithIdentifier:@"Track_HistoryVC"];
    mapview_=nil;
    [SVProgressHUD dismiss];
    [self.navigationController pushViewController:avc animated:YES];
}
@end