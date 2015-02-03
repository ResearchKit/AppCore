// 
//  APCHomeLocationViewController.m 
//  AppCore 
// 
//  Copyright (c) 2014 Apple Inc. All rights reserved. 
// 
 
#import "APCHomeLocationViewController.h"
#import "UIColor+APCAppearance.h"
#import "UIFont+APCAppearance.h"
#import "APCAppDelegate.h"
#import "APCLocationInfoViewController.h"
#import "NSBundle+Helper.h"
#import "APCUser.h"
#import "APCStepProgressBar.h"
#import "APCUserInfoConstants.h"
#import "UIView+Helper.h"
#import "APCAppCore.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

static CGFloat const kTableFooterHeight = 80.0f;

@interface APCHomeLocationViewController ()

@property (nonatomic, strong) NSArray *placemarks;

@property (nonatomic, strong) CLGeocoder *geocoder;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) MKPlacemark *marker;

@property (weak, nonatomic) IBOutlet UIImageView *searchImageView;

@end

@implementation APCHomeLocationViewController

@synthesize stepProgressBar;
@synthesize user = _user;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNavAppearance];
    [self setupProgressBar];
    [self setupAppearance];
    [self prepareContent];
    
    self.geocoder = [[CLGeocoder alloc] init];
    if (self.user.homeLocationAddress) {
        [self geocodeForAddress:self.user.homeLocationAddress];
        self.searchTextField.text = self.user.homeLocationAddress;
    }
    
    [self.searchTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

 -(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.stepProgressBar setCompletedSteps:([self onboarding].onboardingTask.currentStepNumber - 1) animation:YES];
    
    [self.searchTextField becomeFirstResponder];
  APCLogViewControllerAppeared();
}

#pragma mark - Setup

- (void)prepareContent
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"LocationInfo" ofType:@"json"];
    NSString *JSONString = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSError *parseError;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&parseError];
    
    NSString *prefix = @"";
    NSString *moreInfo = @"";
    
    if (!parseError) {
        prefix = jsonDictionary[@"info"];
        moreInfo = jsonDictionary[@"link"];
    }    
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", prefix, moreInfo]];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor appSecondaryColor3] range:NSMakeRange(0, prefix.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor appPrimaryColor] range:NSMakeRange(prefix.length + 1, moreInfo.length)];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont appLightFontWithSize:16.0f] range:NSMakeRange(0, prefix.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont appRegularFontWithSize:16.0f] range:NSMakeRange(prefix.length+1, moreInfo.length)];
    
    [self.moreInfoButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    self.moreInfoButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
}

- (void)setupAppearance
{
    self.searchTextField.tintColor = [UIColor appPrimaryColor];
    [self.searchTextField setFont:[UIFont appRegularFontWithSize:17.0f]];
    
    [self.searchImageView setImage:[UIImage imageNamed: @"search_icon"]];
}

- (void)setupNavAppearance
{
    UIBarButtonItem  *backster = [APCCustomBackButton customBackBarButtonItemWithTarget:self action:@selector(back) tintColor:[UIColor appPrimaryColor]];
    [self.navigationItem setLeftBarButtonItem:backster];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.title = NSLocalizedString(@"Home Address", nil);
}

- (void) setupProgressBar {
    
    CGFloat stepProgressByYPosition = self.topLayoutGuide.length;
    
    self.stepProgressBar = [[APCStepProgressBar alloc] initWithFrame:CGRectMake(0, stepProgressByYPosition, self.view.width, kAPCSignUpProgressBarHeight)
                                                               style:APCStepProgressBarStyleDefault];
    self.stepProgressBar.numberOfSteps = [self onboarding].onboardingTask.numberOfSteps;
    [self.view addSubview:self.stepProgressBar];
    
    [self.stepProgressBar setCompletedSteps:([self onboarding].onboardingTask.currentStepNumber - 2) animation:NO];
}

- (APCOnboarding *)onboarding
{
    return ((APCAppDelegate *)[UIApplication sharedApplication].delegate).onboarding;
}

- (APCUser *) user {
    if (!_user) {
        _user = ((APCAppDelegate*) [UIApplication sharedApplication].delegate).dataSubstrate.currentUser;
    }
    
    return _user;
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.tableView setContentOffset:CGPointZero animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        self.mapView.alpha = 0;
    }];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    [self geocodeForAddress:textField.text];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL  answer = NO;
    
    NSString  *text = [textField text];
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([text length] > 0) {
        answer = YES;
        [textField resignFirstResponder];
    }
    return  answer;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ((self.placemarks != nil) && ([self.placemarks count] > 0)) {
        [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
}


#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    
    if (self.placemarks) {
        count = self.placemarks.count;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLPlacemark *placemark = self.placemarks[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kAPCAddressTableViewCellIdentifier forIndexPath:indexPath];
    
    NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
    NSString *addressString = [lines componentsJoinedByString:@" "];
    
    cell.textLabel.text = addressString;
    
    return cell;
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchTextField resignFirstResponder];
    
    // Animation Stuff
    [tableView setContentOffset:CGPointMake(0, tableView.contentSize.height - kTableFooterHeight) animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        self.mapView.alpha = 1;
    }];
    tableView.scrollEnabled = NO;
    
    CLPlacemark *placemark = self.placemarks[indexPath.row];

    [self.mapView setRegion:MKCoordinateRegionMake(placemark.location.coordinate, MKCoordinateSpanMake(0.02, 0.02)) animated:NO];
    
    [self.mapView removeAnnotation:self.marker];
    self.marker = [[MKPlacemark alloc] initWithCoordinate:placemark.location.coordinate addressDictionary:nil];
    [self.mapView addAnnotation:self.marker];
    
    NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
    NSString *addressString = [lines componentsJoinedByString:@" "];
    self.searchTextField.text = addressString;
    
    [self loadLocationInModelForPlace:placemark];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.mapView removeAnnotation:self.marker];
    self.marker = nil;
}

#pragma mark - MKMapViewDelegate methods

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id ) annotation
{
    MKPinAnnotationView *pinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotation"];
    pinAnnotation.pinColor = MKPinAnnotationColorGreen;
    pinAnnotation.animatesDrop = NO;
    pinAnnotation.canShowCallout = NO;
    pinAnnotation.image = [UIImage imageNamed:@"annotation_pin"];
    [pinAnnotation setSelected:YES animated:YES];
    
    return pinAnnotation;
}

#pragma mark - Custom methods

- (void)geocodeForAddress:(NSString *)address
{
    __weak typeof(self) weakSelf = self;
    
    [self.geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        
        self.placemarks = placemarks;
        self.tableView.scrollEnabled = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            if ([weakSelf.tableView numberOfRowsInSection:0]>0) {
                [weakSelf.tableView scrollsToTop];
                [UIView animateWithDuration:0.2 animations:^{
                    self.messageLabel.alpha = 0;
                }];
            } else {
                [weakSelf.tableView setContentOffset:CGPointMake(0, weakSelf.tableView.contentSize.height - kTableFooterHeight) animated:YES];
                [UIView animateWithDuration:0.2 animations:^{
                    self.messageLabel.alpha = 1;
                }];
            }
            
        });
    }];
}

- (void)loadLocationInModelForPlace:(CLPlacemark *)placemark
{
    NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
    NSString *addressString = [lines componentsJoinedByString:@" "];
    
    self.user.homeLocationAddress = addressString;
    self.user.homeLocationLat = @(placemark.location.coordinate.latitude);
    self.user.homeLocationLong = @(placemark.location.coordinate.longitude);
}

#pragma mark - IBActions/Selectors

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
    [[self onboarding] popScene];
}

- (IBAction)moreInfo:(id)sender
{
    APCLocationInfoViewController *locationInfoViewController = [[UIStoryboard storyboardWithName:@"APCHomeLocation" bundle:[NSBundle appleCoreBundle]] instantiateViewControllerWithIdentifier:@"APCLocationInfoViewController"];
    [self.navigationController presentViewController:locationInfoViewController animated:YES completion:nil];
}

- (IBAction)next:(id)sender
{
    UIViewController *viewController = [[self onboarding] nextScene];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
