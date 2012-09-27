//
//  BTKViewController.h
//  Calculator
//
//  Created by Brandon Krieger on 9/25/12.
//  Copyright (c) 2012 Brandon Krieger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTKViewController : UIViewController
- (IBAction)addNumber:(UIButton *)sender;
- (IBAction)compute:(id)sender;
- (IBAction)addOperator:(UIButton *)sender;
- (IBAction)clear:(id)sender;
- (IBAction)backSpace:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *formula_bar;
@property (weak, nonatomic) IBOutlet UILabel *result_bar;

@property (copy, nonatomic) NSMutableArray *formula_array;
@property (copy, nonatomic) NSString *result;

@end
