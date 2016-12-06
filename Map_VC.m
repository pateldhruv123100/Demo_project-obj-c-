//
//  Map_VC.m
//  IM-HERE
//
//  Created by dhruv patel on 16/06/16.
//  Copyright © 2016 dhruv patel. All rights reserved.
//

#import "Map_VC.h"
#import "HOMEScreen_VC.h"
@import GoogleMaps;
#import "popOver_MapVCViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "contactUsProfile_VC.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface Map_VC ()<GMSMapViewDelegate,UIPopoverControllerDelegate,UIPopoverPresentationControllerDelegate,customerDetailsProtocol>
@property (strong, nonatomic) IBOutlet UILabel *lblMapView;
@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;
@property (weak, nonatomic) IBOutlet UIButton *btnHome;

@end

@implementation Map_VC{
    GMSMapView *mapView_;
    AppDelegate *myAppDelegate;
    NSString *strUserId;
    NSArray *arrVehicleDetails;
    NSMutableArray *arrLat;
    NSMutableArray *arrlong;
    NSMutableDictionary *muDictOfInfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [SVProgressHUD show];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    myAppDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    arrLat=[[NSMutableArray alloc]init];
    arrlong=[[NSMutableArray alloc]init];
    arrVehicleDetails=[[NSMutableArray alloc]init];
    muDictOfInfo=[[NSMutableDictionary alloc]init];
    strUserId=[USERDEFAULT valueForKey:@"userId"];
    
    [self.view addSubview:_view_Title];
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:19.770053
                                                            longitude:79.832880
                                                                 zoom:4];
    mapView_ = [GMSMapView mapWithFrame:self.view.frame camera:camera];
    
    mapView_.myLocationEnabled = YES;
    
    mapView_.mapType=kGMSTypeNormal;
    
    mapView_.delegate = self;
    [_uiMapView addSubview:mapView_];
    
    [self.view addSubview:_mapTypeSegment];
    [self.view addSubview:_uiMapView];
    [self.view addSubview:_bottomView];
    
    
    [myAppDelegate webserviceCallFor2:myAppDelegate.request appendUrl1:@"VehicleDetails/" appendUrl2:[NSString stringWithFormat:@"%@",strUserId] AndPerformCompletion:^(NSData *responseData) {
       
        arrVehicleDetails=[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSLog(@"arra is :%@",arrVehicleDetails);
        
        [self ShowAnnotation];
        
    }];
    // [self zoomToFitMapAnnotations:mapView_];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)ShowAnnotation{
    int i;
    for (i = 0; i < [arrVehicleDetails count]; i++) {
        
        double latdouble = [[[arrVehicleDetails objectAtIndex:i] valueForKey:@"latitude"] doubleValue];
        double londouble = [[[arrVehicleDetails objectAtIndex:i] valueForKey:@"longitude"] doubleValue];
        
        [arrLat addObject:[NSNumber numberWithDouble:latdouble]];
        [arrlong addObject:[NSNumber numberWithDouble:londouble]];
        
        
    }
    
    
    
    for(int i = 0; i < [arrVehicleDetails count]; i++)
    {
        
        double lat = [(NSString *)[arrLat objectAtIndex:i] doubleValue];
        double lon = [(NSString *)[arrlong objectAtIndex:i] doubleValue];
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake(lat,lon);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.title = [NSString stringWithFormat:@"%@...->", arrVehicleDetails[i][@"vnumber"]];
        marker.appearAnimation = YES;
        marker.flat = YES;
        
        NSString *intIgnition=[NSString stringWithFormat:@"%@",arrVehicleDetails[i][@"ignition"]];
        
        NSString *intSpeed=[NSString stringWithFormat:@"%@",arrVehicleDetails[i][@"speed"]];
        if ([intIgnition integerValue]==1 && [intSpeed integerValue]==0) {
            marker.icon=[UIImage imageNamed:@"car_Blue"];
            
        }
        else if ([intIgnition integerValue]==0) {
            marker.icon=[UIImage imageNamed:@"car_Red"];
        }
        
        else if ([intIgnition integerValue]==1){
            marker.icon=[UIImage imageNamed:@"car_Green"];
            
        }
        
        
        
        
        marker.snippet = @"";
        muDictOfInfo=[NSMutableDictionary dictionaryWithObjectsAndKeys:arrVehicleDetails[i][@"Address"],@"location",arrVehicleDetails[i][@"DriverName"],@"drivername",arrVehicleDetails[i][@"ignition"],@"ignition",@"Null",@"Door",arrVehicleDetails[i][@"speed"],@"Speed",arrVehicleDetails[i][@"btrOnOf"],@"car Battry",arrVehicleDetails[i][@"Status"],@"Status",arrVehicleDetails[i][@"LastMsgTime"],@"last updated",arrVehicleDetails[i][@"vnumber"],@"Vehicale Number", nil];
        marker.userData=muDictOfInfo;
        
        
        marker.map = mapView_;
        
    }
    [SVProgressHUD dismiss];
    [self.uiMapView addSubview:mapView_];
    
    
}


- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    mapView.selectedMarker = nil;
    popOver_MapVCViewController *cVC =[self.storyboard instantiateViewControllerWithIdentifier:@"popOver_MapVCViewController"];
    
    cVC.preferredContentSize = CGSizeMake(320,600);
    
    cVC.mudictData=marker.userData;
    cVC.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *popController = [cVC popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    popController.delegate = self;
    
    popController.sourceView = self.view;
    popController.sourceRect =CGRectMake(200,350,0,0);
    
    
    [self presentViewController:cVC animated:YES completion:nil];
    
}


- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    
    return UIModalPresentationNone;
    
    
}



- (IBAction)btnActionHome:(UIButton *)sender {
    HOMEScreen_VC *HomeScreen=[self.storyboard instantiateViewControllerWithIdentifier:@"HOMEScreen_VC"];
    mapView_=nil;
    [SVProgressHUD dismiss];
    [self.navigationController pushViewController:HomeScreen animated:NO];
}


- (IBAction)btnActionContactUs:(UIButton *)sender {
    mapView_=nil;
    [SVProgressHUD dismiss];
    [myAppDelegate directCall];
}

- (IBAction)btnActionCall:(UIButton *)sender {
    contactUsProfile_VC *dvc=[self.storyboard instantiateViewControllerWithIdentifier:@"contactUsProfile_VC"];
    mapView_=nil;
    [SVProgressHUD dismiss];
    [self.navigationController pushViewController:dvc animated:YES];
}


- (IBAction)objSegment:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex==0) {
        mapView_.mapType=kGMSTypeNormal;
    }
    else if (sender.selectedSegmentIndex==1)
    {
        mapView_.mapType=kGMSTypeSatellite;
    }
    else if (sender.selectedSegmentIndex==2)
    {
        mapView_.mapType=kGMSTypeHybrid;
    }
    else if (sender.selectedSegmentIndex==3)
    {
        mapView_.mapType=kGMSTypeTerrain;
    }
}

@end
