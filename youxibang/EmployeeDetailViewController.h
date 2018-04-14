//
//  EmployeeDetailViewController.h
//  youxibang
//
//  Created by y on 2018/1/19.
//

#import "BaseTableViewController.h"

@interface EmployeeDetailViewController : BaseTableViewController

@property(nonatomic,assign)NSInteger type; // 0 查看宝贝/个人资料   1 查看雇主资料
@property(nonatomic,copy)NSString* employeeId;
@end
