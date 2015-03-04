//
//  APCProfileViewController.h 
//  APCAppCore
//
//  Copyright (c) 2015 Apple, Inc. All rights reserved.
//
 
#import <UIKit/UIKit.h>
#import "APCUserInfoViewController.h"


@protocol APCProfileViewControllerDelegate;

@interface APCProfileViewController : APCUserInfoViewController <APCPickerTableViewCellDelegate, APCTextFieldTableViewCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate, APCSwitchTableViewCellDelegate>

@property (nonatomic, strong) APCUser *user;

@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UILabel *emailTextField;

@property (weak, nonatomic) IBOutlet UILabel *editLabel;

@property (weak, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet UILabel *footerTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *diseaseLabel;

@property (weak, nonatomic) IBOutlet UIButton *signOutButton;

@property (weak, nonatomic) IBOutlet UIButton *leaveStudyButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;

@property (assign) id <APCProfileViewControllerDelegate> delegate;

@property (nonatomic, strong) UIImage *profileImage;


- (IBAction)leaveStudy:(id)sender;

- (IBAction)changeProfileImage:(id)sender;

- (IBAction)editFields:(id)sender;

- (void)loadProfileValuesInModel;

- (void)setupDataFromJSONFile:(NSString *)jsonFileName;

- (NSArray *)prepareContent;

@end


@protocol APCProfileViewControllerDelegate <NSObject>
@optional

- (UITableViewCell *)cellForRowAtAdjustedIndexPath:(NSIndexPath *)indexPath;

- (BOOL)willDisplayCell:(NSIndexPath *)indexPath;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInAdjustedSection:(NSInteger)section;

- (NSArray *)preparedContent:(NSArray *)array;

- (void)navigationController:(UINavigationController *)navigationController didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtAdjustedIndexPath:(NSIndexPath *)indexPath;

- (void)hasStartedEditing;

- (void)hasFinishedEditing;
@end
