//
//  List _ViewVC.m
//  IM-HERE
//
//  Created by dhruv patel on 16/06/16.
//  Copyright © 2016 dhruv patel. All rights reserved.
//

#import "List _ViewVC.h"
#import "AppDelegate.h"
#import "HOMEScreen_VC.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "MapViewByListView_vc.h"
#import "vhicle_search.h"
#import "Vhicle_searchTBCell.h"

@interface List__ViewVC ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchResultsUpdating>

@property (nonatomic, strong) NSArray *arrData;


@end

@implementation List__ViewVC
{
    AppDelegate *myAppDelegate;
    NSMutableArray *recipes;
    NSArray *searchResults;
    BOOL isSearchOn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view endEditing:YES];
    isSearchOn=false;
     [[self navigationController] setNavigationBarHidden:YES animated:YES];
    recipes=[[NSMutableArray alloc]init];
    
    
    myAppDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    _tblvw.estimatedRowHeight=500.0;
    _tblvw.rowHeight=UITableViewAutomaticDimension;
    _arrData=[[NSArray alloc]init];
    
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    self.searchController.searchBar.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    self.tblvw.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
    
    
    NSString  *strUserId=[USERDEFAULT valueForKey:@"userId"];
    [myAppDelegate webserviceCallFor2:myAppDelegate.request appendUrl1:@"VehicleDetails/" appendUrl2:[NSString stringWithFormat:@"%@",strUserId] AndPerformCompletion:^(NSData *responseData) {
        _arrData=[NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
        NSLog(@"dic is :%@",_arrData);
        [self separateData];
        [SVProgressHUD dismiss];
        

        
    }];

    [SVProgressHUD showWithStatus:@"Loading Data..."];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



# pragma mark - UITableViewControllerDelegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active)
    {
        return [searchResults count];
    }
    else
    {
        return [recipes count];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    Vhicle_searchTBCell *cell = (Vhicle_searchTBCell *)[self.tblvw dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        
        cell = [[Vhicle_searchTBCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Display recipe in the table cell
    vhicle_search *recipe = nil;
    if (self.searchController.active)
    {
        recipe = [searchResults objectAtIndex:indexPath.row];
    }
    else
    {
        recipe = [recipes objectAtIndex:indexPath.row];
    }
    cell.VNumber.text = recipe.VehicleNumber;
    
    cell.date.text = recipe.mydatetime;
    cell.Address.text = recipe.Address;
    
    NSString *intStatus=recipe.intStatus;
    NSString *intIgnition=recipe.intIgnition;
    if ([intStatus intValue] == 1) {
                cell.imgsatus.image=[UIImage imageNamed:@"listallscreengpsgreenicon.png"];
        
            }
            else if ([intStatus intValue] == 0)
            {
                cell.imgsatus.image=[UIImage imageNamed:@"listallscreengpsgreyicon.png"];
            }
        
        
            if ([intIgnition intValue]==1) {
                cell.imgCar.image=[UIImage imageNamed:@"cargreen.png"];
            }
            else if([intIgnition intValue]==0)
            {
                
                cell.imgCar.image=[UIImage imageNamed:@"cargrey.png"];
                
            }

    
    return cell;
}


-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchString = self.searchController.searchBar.text;
    if ([searchString isEqualToString:@""]) {
        searchResults=recipes;
        isSearchOn=false;
        [self.tblvw reloadData];
    }
    else{
        NSPredicate *resultPredicate;
        resultPredicate = [NSPredicate predicateWithFormat:@"VehicleNumber contains[c] %@",searchString];
        
        searchResults = [recipes filteredArrayUsingPredicate:resultPredicate];
        isSearchOn=true;
        [self.tblvw reloadData];
    }
    
}
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
    [self updateSearchResultsForSearchController:self.searchController];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (isSearchOn) {
        
        MapViewByListView_vc *mvc=[self.storyboard instantiateViewControllerWithIdentifier:@"MapViewByListView_vc"];
        mvc.strTrackerID=[[searchResults valueForKey:@"trackerName"] objectAtIndex:indexPath.row];
        NSLog(@"Search Research :%@",[[searchResults valueForKey:@"trackerName"] objectAtIndex:indexPath.row]);
        [self.navigationController pushViewController:mvc animated:YES];
    }
    else{
        MapViewByListView_vc *mvc=[self.storyboard instantiateViewControllerWithIdentifier:@"MapViewByListView_vc"];
        mvc.strTrackerID=[[recipes valueForKey:@"trackerName"] objectAtIndex:indexPath.row];
        NSLog(@"Search Research :%@",[[recipes valueForKey:@"trackerName"] objectAtIndex:indexPath.row]);
        [self.navigationController pushViewController:mvc animated:YES];
        
    }
    
    
}


- (IBAction)btnActionHome:(UIButton *)sender {
    HOMEScreen_VC *HomeScreen=[self.storyboard instantiateViewControllerWithIdentifier:@"HOMEScreen_VC"];
    [SVProgressHUD dismiss];
    [self.navigationController pushViewController:HomeScreen animated:NO];
}



-(void)separateData{
    vhicle_search *VC;
    for (int i=0; i<=_arrData.count-1; i++) {
        VC = [vhicle_search new];
        VC.VehicleNumber = [NSString stringWithFormat:@"%@",_arrData[i][@"vnumber"]];
        VC.Address = [NSString stringWithFormat:@"%@",_arrData[i][@"Address"]];
        VC.mydatetime =[NSString stringWithFormat:@"%@",_arrData[i][@"mydatetime"]];
        VC.intStatus=[NSString stringWithFormat:@"%@",_arrData[i][@"Status"]];
        VC.intIgnition=[NSString stringWithFormat:@"%@",_arrData[i][@"ignition"]];
        VC.trackerName=[NSString stringWithFormat:@"%@",_arrData[i][@"trackername"]];
        [recipes addObject:VC];
    }
    
    [self.tblvw reloadData];
}

- (IBAction)btnActionCall:(UIButton *)sender {
    [myAppDelegate directCall];
    [SVProgressHUD dismiss];
}
- (IBAction)btnActionContactUs:(UIButton *)sender {
    contactUsProfile_VC *dvc=[self.storyboard instantiateViewControllerWithIdentifier:@"contactUsProfile_VC"];
    [SVProgressHUD dismiss];
    [self.navigationController pushViewController:dvc animated:YES];
}

@end

