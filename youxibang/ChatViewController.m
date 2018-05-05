//
//  ChatViewController.m
//  youxibang
//
//  Created by y on 2018/1/22.
//

#import "ChatViewController.h"
#import "CustomAlertView.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor colorFromHexString:@"333333"] forKey:NSForegroundColorAttributeName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//继承云信的信息点击方法，增加点击图片与视频
- (BOOL)onTapCell:(NIMKitEvent *)event{
    BOOL handle = [super onTapCell:event];
    if (event.messageModel.message.attachmentDownloadState == NIMMessageAttachmentDownloadStateDownloaded){
        if (event.messageModel.message.messageType == 1){
            NIMImageObject* img = event.messageModel.message.messageObject;
            CustomAlertView* alert = [[CustomAlertView alloc] initWithImages:@[img.url] Index:0];
            [alert showAlertView];
        }else if (event.messageModel.message.messageType == 3){
            NIMVideoObject* video = event.messageModel.message.messageObject;
            CustomAlertView* alert = [[CustomAlertView alloc] initWithVedio:[NSURL URLWithString:video.url]];
            [alert showAlertView];
        }
    }
    
    return handle;
}

- (BOOL)recordFileCanBeSend:(NSString *)filepath{
    NSURL *URL = [NSURL fileURLWithPath:filepath];
    AVURLAsset *urlAsset = [[AVURLAsset alloc]initWithURL:URL options:nil];
    CMTime time = urlAsset.duration;
    CGFloat mediaLength = CMTimeGetSeconds(time);
    return mediaLength >= 1;
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
