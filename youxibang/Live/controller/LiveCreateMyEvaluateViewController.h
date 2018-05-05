//
//  LiveCreateMyEvaluateViewController.h
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/26.
//

#import <UIKit/UIKit.h>

typedef void(^EditEvaluateBlock)(NSString *evaluate);

@interface LiveCreateMyEvaluateViewController : UIViewController

@property (copy, nonatomic) NSString *evaluateString;

@property (copy, nonatomic) EditEvaluateBlock editEvaluateBlock;

@end
