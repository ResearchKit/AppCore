//
//  APCParametersCellTableViewCell.m
//  ParametersDashboard
//
//  Created by Justin Warmkessel on 9/19/14.
//  Copyright (c) 2014 Justin Warmkessel. All rights reserved.
//

#import "APCParametersCell.h"

static CGFloat cellHeight = 114.0;

@interface APCParametersCell () 

@property (nonatomic, strong) UIView *inputAccView;
@property (nonatomic, strong) UIButton *btnDone;
@property (nonatomic, strong) UITextField *currentKeyboard;

@end

@implementation APCParametersCell

- (void)awakeFromNib {
    // Initialization code
    [self.parameterTextInput setDelegate:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


/*********************************************************************************/
#pragma mark - UITextFieldDelegate
/*********************************************************************************/

- (void) textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(inputCellValueChanged:)]) {
        [self.delegate inputCellValueChanged:self];
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    // Call the createInputAccessoryView method we created earlier.
    // By doing that we will prepare the inputAccView.
    [self createInputAccessoryView];
    
    // Now add the view as an input accessory view to the selected textfield.
    [textField setInputAccessoryView:self.inputAccView];
    
    self.currentKeyboard = textField;
    
}

/*********************************************************************************/
#pragma mark - Private Methods
/*********************************************************************************/


//Input accessory for keyboard
-(void)createInputAccessoryView{
    
    self.inputAccView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 310.0, 40.0)];
    
    // Set the view’s background color. We’ ll set it here to gray. Use any color you want.
    [self.inputAccView setBackgroundColor:[UIColor lightGrayColor]];
    
    // We can play a little with transparency as well using the Alpha property. Normally
    // you can leave it unchanged.
    [self.inputAccView setAlpha: 0.8];
    
    
    
    
    self.btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnDone setFrame:CGRectMake(240.0, 0.0f, 80.0f, 40.0f)];
    [self.btnDone setTitle:@"Done" forState:UIControlStateNormal];
    [self.btnDone setBackgroundColor:[UIColor greenColor]];
    [self.btnDone setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnDone addTarget:self action:@selector(doneTyping) forControlEvents:UIControlEventTouchUpInside];
    
    // Now that our buttons are ready we just have to add them to our view.
    [self.inputAccView addSubview:self.btnDone];
}

- (void)doneTyping {
    NSLog(@"Done typing");
    [self.currentKeyboard resignFirstResponder];
}



/*********************************************************************************/
#pragma mark - Class Methods
/*********************************************************************************/

+ (float)heightOfCell {
    
    return cellHeight;
}

@end
