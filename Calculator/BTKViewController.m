//
//  BTKViewController.m
//  Calculator
//
//  Created by Brandon Krieger on 9/25/12.
//  Copyright (c) 2012 Brandon Krieger. All rights reserved.
//

#import "BTKViewController.h"

@interface BTKViewController ()

@end

@implementation BTKViewController

@synthesize formula_bar = _formula_bar;
@synthesize result_bar = _result_bar;
@synthesize formula_array = _formula_array;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
 
- (void)viewDidUnload
{
    [self setFormula_bar:nil];
    [self setResult_bar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)initializeFormula {
    if(_formula_array == nil) {
        _formula_array = [NSMutableArray new];
    }
}

- (void)updateFormulaBar {
    NSString *text = [_formula_array componentsJoinedByString:@""];
    _formula_bar.text = text;
}

- (void)updateResultBar {
    NSString *text = _result;
    _result_bar.text = text;
}

- (void)clearResultBar {
    _result = @"";
    [self updateResultBar];
}

//Resets the result and formula array
- (IBAction)clear:(id)sender {
    _formula_array = [NSMutableArray new];
    _result = @"";
    [self updateFormulaBar];
    [self updateResultBar];
}

//Removes the last value from the formula array
- (IBAction)backSpace:(id)sender {
    [self clearResultBar];
    NSUInteger length = [_formula_array count];
    if(length>0) {
        [_formula_array removeObjectsInRange:NSMakeRange(length-1, 1) ];
        [self updateFormulaBar];
    }
}

//Adds number to formula bar
- (IBAction)addNumber:(UIButton *)sender {
    if(_result != @"") {
        [self clearResultBar];
        _formula_array = nil;
    }
    NSInteger value = [sender tag];
    [self initializeFormula];
    [_formula_array addObject:[[NSNumber numberWithInt:value] stringValue]];
    [self updateFormulaBar];
}

//Adds operator to formula bar
- (IBAction)addOperator:(UIButton *)sender {
    NSInteger value = [sender tag];
    [self initializeFormula];
    
    switch (value) {
        case 1: [_formula_array addObject:@"+"];
            break;
        case 2: [_formula_array addObject:@"－"];
            break;
        case 3: [_formula_array addObject:@"*"];
            break;
        case 4: [_formula_array addObject:@"/"];
            break;
            /*case 5: [_formula_array addObject:@"^"];
             break;*/
        case 8:
            if(_result != @"") {
                _formula_array = [NSMutableArray new];
            }
            [_formula_array addObject:@"."];
            break;
        case 9:
            if(_result != @"") {
                _formula_array = [NSMutableArray new];
            }
            [_formula_array addObject:@"-"];
            break;
        default:
            break;
    }
    [self clearResultBar];
    [self updateFormulaBar];
}

//Checks if a String is not an operator
- (BOOL)isNumChar:(NSString *)s {
    if ([s isEqual: @"+"]) {
        return false;
    } else if ([s isEqual: @"－"]) {
        return false;
    } else if ([s isEqual: @"*"]) {
        return false;
    } else if ([s isEqual: @"/"]) {
        return false;
    } /*else if ([s isEqual: @"^"]) {
        return false;
    }*/ else {
        return true;
    }
}

//tag=0 means add
//tag=1 means subtract
//tag=2 means multiply
//tag=3 means divide
//tag=4 means exponent
- (BOOL) operate:(int) tag {
    NSUInteger operator_index;
    
    //Find operator
    switch (tag) {
        case 0:operator_index = [_formula_array indexOfObject:@"+"];
            break;
        case 1:operator_index = [_formula_array indexOfObject:@"－"];
            break;
        case 2:operator_index = [_formula_array indexOfObject:@"*"];
            break;
        case 3:operator_index = [_formula_array indexOfObject:@"/"];
            break;
        /*case 4:operator_index = [_formula_array indexOfObject:@"^"];
            break;*/
        default:break;
    }
    
    
    //If the operator is there, operate on the value before and after it
    if(operator_index != NSNotFound) {
        NSDecimalNumber *first = [_formula_array objectAtIndex:operator_index-1];
        NSDecimalNumber *second = [_formula_array objectAtIndex:operator_index+1];
        
        if(tag==3) {
            if([second isEqualToNumber:[NSNumber numberWithInt:0]]) {
                return false;
            }
        }
        NSDecimalNumber *result;
        
        switch (tag) {
            case 0:result = [first decimalNumberByAdding:second];
                break;
            case 1:result = [first decimalNumberBySubtracting:second];
                break;
            case 2:result = [first decimalNumberByMultiplyingBy:second];
                break;
            case 3:result = [first decimalNumberByDividingBy:second];
                break;
            /*case 4:result = power
                break;*/
            default:break;
        }

        [_formula_array replaceObjectAtIndex:operator_index-1 withObject:result];
        [_formula_array removeObjectAtIndex:operator_index];
        [_formula_array removeObjectAtIndex:operator_index];

        //Call operate for the same value (e.g. multiplication) again
        [self operate:tag];
    }
    return true;
}

//checks if formula contains (..) or (.-) or (- followed by an operator) or (- preceded by a number) or (. followed by anthing except a number) or (formula ends with an operator) or (formula ends with -) or (formula ends with .)
- (BOOL)containsSyntaxErrors {
    for (int i=0; i<_formula_array.count-1; i++) {

        if([[_formula_array objectAtIndex:i] isEqualToString:@"." ]) {
            if([[_formula_array objectAtIndex:i+1] isEqualToString:@"."]) {
                return true;
            }
            if([[_formula_array objectAtIndex:i+1] isEqualToString:@"-"]) {
                return true;
            }
            if(![self isNumChar:[_formula_array objectAtIndex:i+1]] ) {
                return true;
            }
            for(int j=i+1; j<_formula_array.count; j++) {
                if(![self isNumChar: [_formula_array objectAtIndex:j]]) {
                    break;
                }
                if([[_formula_array objectAtIndex:j] isEqualToString:@"." ]) {
                    return true;
                }
            }
        }
        if([[_formula_array objectAtIndex:i] isEqualToString:@"-"]) {
            if(![self isNumChar: [_formula_array objectAtIndex:i+1]]) {
                return true;
            }
            if(i!=0 && [self isNumChar:[_formula_array objectAtIndex:i-1]] ) {
                return true;
            }
        }
    }

    int last_index = _formula_array.count-1;
    if (![self isNumChar:[_formula_array objectAtIndex:last_index]]) {
        return true;
    }
    if ([[_formula_array objectAtIndex:last_index] isEqualToString:@"-"]) {
        return true;
    }
    if ([[_formula_array objectAtIndex:last_index] isEqualToString:@"."]) {
        if(![self isNumChar:[_formula_array objectAtIndex:last_index-1]]) {
            return true;
        }
    }
    return false;
}

//Convert the formula to a usable array
- (BOOL)makeFormulaArrayConcise {
    if([self containsSyntaxErrors]) {
        return false;
    }
    
    NSMutableArray *newArray = [NSMutableArray new];
    NSUInteger start = 0;
    NSUInteger end = 0;
    
    while (end<_formula_array.count) {
        if ([self isNumChar:[_formula_array objectAtIndex:start]]) {
            end++;
        } else {
            return false;
        }
        
        while (end<_formula_array.count) {
            if([self isNumChar:[_formula_array objectAtIndex:end]]) {
                end++;
            } else {
                break;
            }
        }
        
        NSString *value = [[_formula_array subarrayWithRange:NSMakeRange(start, end-start)] componentsJoinedByString:@""];
        NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:value];
        [newArray addObject:number];
        if (end<_formula_array.count) {
            [newArray addObject: [_formula_array objectAtIndex:end]];
            end++;
            start = end;
        }
    }
    _formula_array = newArray;
    return true;
}

//Computes the result of the typed formula
- (IBAction)compute:(id)sender {
    //if no formula has been entered, stop
    if (_formula_array.count==0 || _formula_array==nil) {
        return;
    }
    //Make the array concise, and continue if it had no syntax errors
    if([self makeFormulaArrayConcise]) {
        /*[self operate:4];*/
        
        //Do division, multiplication, subtraction, and addition
        //If division returns false, we had divide by zero, so result is Nan
        if([self operate:3]) {
            [self operate:2];
            [self operate:1];
            [self operate:0];
            
            //If the operations worked (they should always work), set the result value
            if(_formula_array.count==1) {
                NSString *answer = [[_formula_array objectAtIndex:0] stringValue];
                //If the answer is too long before the decimal point, Overflow Error
                //If the answer is too long after the decimal point, truncuate with ... automatically
                if(answer.length>22 && ([answer rangeOfString:@"."].location==NSNotFound)) {
                    _result = @"Overflow Error";
                } else {
                    _result = answer;
                }
                //reformat the formula_array so each character is individual again
                //this makes it so you can backspace individual characters after hitting enter
                NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:[answer length]];
                for (int i=0; i < [answer length]; i++) {
                    NSString *ichar  = [NSString stringWithFormat:@"%c", [answer characterAtIndex:i]];
                    [characters addObject:ichar];
                }
                _formula_array = characters;
            } else {
                _result = @"Unknown Error";
            }
        } else {
            _result = @"NaN";
        }
    } else {
        _result = @"NaN";
    }
    [self updateResultBar];
}

@end
