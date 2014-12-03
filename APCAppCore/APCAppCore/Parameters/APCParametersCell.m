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
    
    //This is an accessory view that I'm adding to the top of the keyboard.
    CGRect deviceRect = [[UIScreen mainScreen] bounds];
    float xValue = 10.0f;
    float yValue = 0.0f;
    float width = deviceRect.size.width;
    float height = 40.0;
    self.inputAccView = [[UIView alloc] initWithFrame:CGRectMake(xValue, yValue, width, height)];
    
    // Set the view’s background color.
    [self.inputAccView setBackgroundColor:[UIColor lightGrayColor]];
    
    //This is an custom done button that I'm adding to the top of the accessory view.
    float btnDoneWidth = 80.0f;
    float btnDoneHeight = 40.0f;
    float btnDoneXValue = deviceRect.size.width - btnDoneWidth;
    float btnDoneYValue = 0.0f;
    
    self.btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnDone setFrame:CGRectMake(btnDoneXValue, btnDoneYValue, btnDoneWidth, btnDoneHeight)];
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
