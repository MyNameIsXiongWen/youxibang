//
//  UpDataProgressViewController.m
//  youxibang
//
//  Created by y on 2018/1/31.
//

#import "UpDataProgressViewController.h"

@interface UpDataProgressViewController ()<LPDQuoteImagesViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *photo1;
@property (weak, nonatomic) IBOutlet UIImageView *photo2;
@property (weak, nonatomic) IBOutlet UILabel *photo1NumLab;
@property (weak, nonatomic) IBOutlet UILabel *photo2NumLab;
@property (nonatomic,strong)LPDQuoteImagesView *quoteImagesView;
@property (nonatomic,assign)NSInteger selectTag;
@property (nonatomic,strong)UIImage* img1;
@property (nonatomic,strong)UIImage* img2;
@end

@implementation UpDataProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"上传进度";
    //选择图片的实例
    self.quoteImagesView = [[LPDQuoteImagesView alloc] initWithFrame:CGRectMake(100, 490, 140, 140) withCountPerRowInView:3 cellMargin:3];
    self.quoteImagesView.backgroundColor = [UIColor redColor];
    //初始化view的frame, view里每行cell个数， cell间距（上方的图片1 即为quoteImagesView）
    self.quoteImagesView.userInteractionEnabled = NO;
    self.quoteImagesView.maxSelectedCount = 1;
    //最大可选照片数
    
    self.quoteImagesView.collectionView.scrollEnabled = NO;
    //view可否滑动
    
    self.quoteImagesView.navcDelegate = self;    //self 至少是一个控制器。
    //委托（委托controller弹出picker，且不用实现委托方法）
    
    //右上角按键
    UIView* rv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 55, 25)];
    UIButton* btn = [EBUtility greenBtnfrome:CGRectMake(-20, 0, 85, 25) andText:@"确认上传" andColor:[UIColor colorFromHexString:@"333333"] andimg:nil andView:rv];
    
    btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [btn addTarget:self action:@selector(upData:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rv];
    
    //进入此页面即选择上传还是跳过，如果选择跳过则发送一次接口并返回上一页面
    if ([self.type isEqualToString:@"1"]){
        CustomAlertView* alert = [[CustomAlertView alloc]initWithTitle:@"温馨提示" Text:@"上传上号截图后开始打单" AndType:1];
        alert.resultRemove = ^(NSString *str) {
            [self blockImg];
        };
        [alert showAlertView];
    }else if ([self.type isEqualToString:@"2"]){
        CustomAlertView* alert = [[CustomAlertView alloc]initWithTitle:@"温馨提示" Text:@"上传下号截图后结束打单" AndType:1];
        alert.resultRemove = ^(NSString *str) {
            [self blockImg];
        };
        [alert showAlertView];
    }
}
//发送一次不带图片的接口
- (void)blockImg{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:UserModel.sharedUser.token forKey:@"token"];
    [dict setObject:self.orderSn forKey:@"order_sn"];
    [dict setObject:self.type forKey:@"type"];
    
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Gamebaby/udnoimg.html",HttpURLString] Paremeters:dict successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                if (self.uploadSuccessBlock) {
                    self.uploadSuccessBlock(self.type);
                }
                [self.navigationController popViewControllerAnimated:1];
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}
//上传截图
- (void)upData:(UIButton*)sender{
    if (!self.img1 && !self.img2){
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请上传截图" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
        return;
    }
    NSMutableArray* imgAry = [NSMutableArray array];
    NSMutableArray* nameAry = [NSMutableArray array];
    if (self.img2){
        [imgAry addObject:self.img2];
        [nameAry addObject:@"endimg"];
    }
    if (self.img1){
        [imgAry addObject:self.img1];
        [nameAry addObject:@"startimg"];
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:UserModel.sharedUser.token forKey:@"token"];
    [dict setObject:self.orderSn forKey:@"order_sn"];
    [dict setObject:self.type forKey:@"type"];
    [[NetWorkEngine shareNetWorkEngine] postImageAryInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@Gamebaby/udnoimg.html",HttpURLString] Paremeters:dict Image:imgAry ImageName:nameAry successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            
            if (code == 1) {
                [SVProgressHUD showSuccessWithStatus:msg];
                if (self.uploadSuccessBlock) {
                    self.uploadSuccessBlock(self.type);
                }
                [self.navigationController popViewControllerAnimated:1];
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//选择图片，根据状态禁止选择非当前状态的截图按键
- (IBAction)addProgressPhoto:(UIButton *)sender {
    if ([self.type isEqualToString:@"1"]){
        if (sender.tag == 1){
            return;
        }
    }else if ([self.type isEqualToString:@"2"]){
        if (sender.tag == 0){
            return;
        }
    }
    
    [self.quoteImagesView.selectedPhotos removeAllObjects];
    [self.quoteImagesView.selectedAssets removeAllObjects];
    [self.quoteImagesView pushImagePickerController];
    self.selectTag = sender.tag;
}
#pragma mark - OtherDelegate
//选择完成回调
- (void)chooseFinish{
    UIImageView* i = [self.view viewWithTag:self.selectTag + 2];
    i.image = self.quoteImagesView.selectedPhotos[0];
    if (self.quoteImagesView.selectedPhotos.count > 0){
        if (self.selectTag == 0){
            self.photo1NumLab.text = [NSString stringWithFormat:@"共%ld张",self.quoteImagesView.selectedPhotos.count];
            self.img1 = self.quoteImagesView.selectedPhotos[0];
        }else{
            self.photo2NumLab.text = [NSString stringWithFormat:@"共%ld张",self.quoteImagesView.selectedPhotos.count];
            self.img2 = self.quoteImagesView.selectedPhotos[0];
        }

    }
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
