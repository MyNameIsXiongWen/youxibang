//
//  AddSkillViewController.m
//  youxibang
//
//  Created by y on 2018/2/5.
//

#import "AddSkillViewController.h"
#import "AddGameSkillViewController.h"

@interface AddSkillViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,AVAudioRecorderDelegate,AddGameSkillViewControllerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic,strong)UIImage* img;//技能图片
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)AVAudioSession* session;
@property (nonatomic,strong)AVAudioRecorder* recorder;//录音
@property (nonatomic,copy) NSURL* recordFileUrl;

@property (nonatomic,copy)NSString* skillId;//游戏id
@end

@implementation AddSkillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 0-40);
    self.tableView.tableFooterView = [UIView new];
    self.title = @"添加技能";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//提交
- (IBAction)commitInfo:(id)sender {
    if (self.originSkill){//编辑技能接口与创建是不同的
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        UITextField* grade = [cell viewWithTag: 1];
        
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]];
        UITextField* price = [cell viewWithTag: 2];
        
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
        UITextView* des = [cell viewWithTag: 1];
        
        if ([EBUtility isBlankString:grade.text]){
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请填写段位" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            return;
        }
        if ([EBUtility isBlankString:price.text]){
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请填写每小时单价" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            return;
        }
        if ([EBUtility isBlankString:des.text]){
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请填写技能描述" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            return;
        }
        if (!self.recordFileUrl) {
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请录制语音" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            return;
        }
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD show];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        [dict setObject:UserModel.sharedUser.token forKey:@"token"];
        [dict setObject:self.skillId forKey:@"itemid"];
        [dict setObject:grade.text forKey:@"duanwei"];
        [dict setObject:des.text forKey:@"selfdesc"];
        [dict setObject:price.text forKey:@"price"];
        [dict setObject:[NSString stringWithFormat:@"%@",self.originSkill[@"source"]] forKey:@"source"];
        
        NSString* url = [self audioPCMtoMP3];
        [[NetWorkEngine shareNetWorkEngine] postFileFromServerWithUrlStr:[NSString stringWithFormat:@"%@Gamebaby/editskill.html",HttpURLString] Paremeters:dict Image:self.img File:url successOperation:^(id object) {
            [SVProgressHUD dismiss];
            [SVProgressHUD setDefaultMaskType:1];
            if (isKindOfNSDictionary(object)){
                NSInteger code = [object[@"errcode"] integerValue];
                NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
                NSLog(@"输出 %@--%@",object,msg);
                
                if (code == 1) {
                    [SVProgressHUD showSuccessWithStatus:msg];
                    [self.navigationController popViewControllerAnimated:1];
                }else{
                    [SVProgressHUD showErrorWithStatus:msg];
                }
            }
        } failoperation:^(NSError *error) {
            [SVProgressHUD dismiss];
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"网络信号差，请稍后再试" andDuration:2.0 PromptLocation:PromptBoxLocationCenter];
        }];
    }else{
        if ([EBUtility isBlankString:self.skillId]){
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请选择技能" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            return;
        }
        if (!self.img){
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请上传技能图片" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            return;
        }
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        UITextField* grade = [cell viewWithTag: 1];
        
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]];
        UITextField* price = [cell viewWithTag: 2];
        
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
        UITextView* des = [cell viewWithTag: 1];
        
        if ([EBUtility isBlankString:grade.text]){
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请填写段位" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            return;
        }
        if ([EBUtility isBlankString:price.text]){
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请填写每小时单价" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            return;
        }
        if ([EBUtility isBlankString:des.text]){
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请填写技能描述" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            return;
        }
        if (!self.recordFileUrl) {
            [[SYPromptBoxView sharedInstance] setPromptViewMessage:@"请录制语音" andDuration:2.0 PromptLocation:PromptBoxLocationBottom];
            return;
        }
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
        [SVProgressHUD show];
        NSString* url = [self audioPCMtoMP3];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        
        [dict setObject:UserModel.sharedUser.token forKey:@"token"];
        [dict setObject:self.skillId forKey:@"pid"];
        [dict setObject:[grade.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:@"duanwei"];
        [dict setObject:price.text forKey:@"price"];
        [dict setObject:des.text forKey:@"selfdesc"];
        
        [[NetWorkEngine shareNetWorkEngine] postFileFromServerWithUrlStr:[NSString stringWithFormat:@"%@Gamebaby/publishskill.html",HttpURLString] Paremeters:dict Image:self.img File:url successOperation:^(id object) {
            [SVProgressHUD dismiss];
            [SVProgressHUD setDefaultMaskType:1];
            if (isKindOfNSDictionary(object)){
                NSInteger code = [object[@"errcode"] integerValue];
                NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
                NSLog(@"输出 %@--%@",object,msg);
                UserModel *userModel = UserModel.sharedUser;
                userModel.isbaby = @"1";
                if (code == 1) {
                    [SVProgressHUD showSuccessWithStatus:msg];
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
    
}
//开始录音
- (IBAction)startRecord:(UIButton *)sender {
    [self.tableView endEditing:1];
    [sender setTitle:@"开始录音，松开手指结束录音" forState:0];
    
    AVAudioSession *session =[AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryRecord error:&sessionError];
    
    if (session == nil) {
        
        NSLog(@"Error creating session: %@",[sessionError description]);
        
    }else{
        [session setActive:YES error:nil];
        
    }
    
    self.session = session;
    
    //1.获取沙盒地址

    NSString *tmp = NSTemporaryDirectory();
    NSString *filePath = [tmp stringByAppendingString:@"RRecord.caf"];
    [self deleteOldRecordFileAtPath:filePath];
    //2.获取文件路径
    self.recordFileUrl = [NSURL fileURLWithPath:filePath];

    NSDictionary *setting = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:AVAudioQualityHigh],
                             AVEncoderAudioQualityKey,
                             [NSNumber numberWithInt:16],
                             AVEncoderBitRateKey,
                             [NSNumber numberWithInt:2],
                             AVNumberOfChannelsKey,
                             [NSNumber numberWithFloat:11025.0],
                             AVSampleRateKey,
                             nil];

    _recorder = [[AVAudioRecorder alloc] initWithURL:self.recordFileUrl settings:setting error:nil];
    _recorder.delegate = self;
    if (_recorder) {
        
        _recorder.meteringEnabled = YES;

        [_recorder record];
        
    }else{
        NSLog(@"音频格式和文件存储格式不匹配,无法初始化Recorder");
        
    }
    
}
//如果重新录音则删除原录音
-(void)deleteOldRecordFileAtPath:(NSString *)pathStr{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:pathStr];
    if (!blHave) {
        NSLog(@"不存在");
        return ;
    }else {
        NSLog(@"存在");
        BOOL blDele= [fileManager removeItemAtPath:pathStr error:nil];
        if (blDele) {
            NSLog(@"删除成功");
        }else {
            NSLog(@"删除失败");
        }
    }
}
//停止录音
- (IBAction)stopRecord:(UIButton*)sender {
    
    if ([self.recorder isRecording]) {
        //获取录制时间，短于2s不上传
        AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:self.recordFileUrl options:nil];
        
        CMTime audioDuration = audioAsset.duration;
        
        float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
        if (audioDurationSeconds > 3){
            [self.recorder stop];
            [sender setTitle:@"已录音，可重复按下覆盖录音" forState:0];
        }else{
            [self.recorder stop];
            [sender setTitle:@"录音时长不能小于3秒，请再次录音" forState:0];
            self.recordFileUrl = nil;
            
        }
        
    }
    
    NSString *tmp = NSTemporaryDirectory();
    NSString *filePath = [tmp stringByAppendingString:@"RRecord.caf"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        
        NSLog(@"%@",[NSString stringWithFormat:@"文件大小为 %.2fKb",[[manager attributesOfItemAtPath:filePath error:nil] fileSize]/1024.0]);
    }else{
        NSLog(@"储存失败");

    }
    
}
//caf转MP3格式
- (NSString *)audioPCMtoMP3{
    NSString *tmp = NSTemporaryDirectory();
    NSString *cafFilePath = [tmp stringByAppendingString:@"RRecord.caf"];
    
    NSString *mp3FilePath = [tmp stringByAppendingPathComponent:@"Record.mp3"];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        
        return mp3FilePath;
    }

}


#pragma mark - tableViewDelegate/DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 5) {
        return 130;
    }
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (indexPath.section == 5) {
        return 130;
    }
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"celllll"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"celllll"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"技能";
            cell.textLabel.textColor = [UIColor colorFromHexString:@"333333"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.font = [UIFont systemFontOfSize:15];
        }
        if (self.originSkill) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.originSkill[@"title"]];
            self.skillId = [NSString stringWithFormat:@"%@",self.originSkill[@"id"]];
        }
        return cell;
    }else if (indexPath.section == 5) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellll"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellll"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        UILabel *lab = [EBUtility labfrome:CGRectMake(15, 5, 100, 25) andText:@"技能封面照" andColor:[UIColor colorFromHexString:@"333333"] andView:cell.contentView];
        lab.textAlignment = 0;
        
        UIImageView *imgView = [EBUtility imgfrome:CGRectMake(10, 30, 90, 90) andImg:[UIImage imageNamed:@"ico_add1"] andView:cell.contentView];
        if (self.originSkill) {
            [imgView sd_setImageWithURL:[NSURL URLWithString:self.originSkill[@"bgimg"]] placeholderImage:[UIImage imageNamed:@"ico_add1"]];
        }
        imgView.tag = 111;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.layer.masksToBounds = YES;
        imgView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(amendHeadImg)];
        [imgView addGestureRecognizer:tap];

        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"cell%ld",indexPath.section]];
    if (self.originSkill) {
        if (indexPath.section == 1) {
            UILabel* la = [cell viewWithTag: 0];
            la.textColor = [UIColor colorFromHexString:@"333333"];
            UITextField* tf = [cell viewWithTag: 1];
            tf.text = [NSString stringWithFormat:@"%@",self.originSkill[@"duanwei"]];
        }else if (indexPath.section == 2) {
            UITextView* tf = [cell viewWithTag: 1];
            tf.text = [NSString stringWithFormat:@"%@",self.originSkill[@"selfdesc"]];
        }else if (indexPath.section == 4) {
            UITextView* tf = [cell viewWithTag: 2];
            tf.text = [NSString stringWithFormat:@"%@",self.originSkill[@"price"]];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView endEditing:1];
    if (indexPath.section == 0){
        [self.tableView endEditing:1];
        if (self.originSkill){
            return;
        }
        AddGameSkillViewController* vc = [[AddGameSkillViewController alloc]init];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:1];
    }
}

#pragma mark - otherDelegate/DataSource
//选择游戏回调
- (void)selectSomeThing:(NSString *)name AndId:(NSString *)pid{
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.detailTextLabel.text = name;
    self.skillId = pid;
}

- (void)amendHeadImg {
    UIAlertController *alertController = [[UIAlertController alloc]init];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击相册");
        if([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypePhotoLibrary)]) {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.navigationBar.tintColor = self.view.window.tintColor;
            [picker setSourceType:(UIImagePickerControllerSourceTypePhotoLibrary)]; //资源类型为图片库
            [picker setAllowsEditing:YES]; //设置选择后的图片可被编辑
            [picker setDelegate:self];
            [self presentViewController:picker animated:YES completion:^{ }];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击拍照");
        if ([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypeCamera)]) { //判断是否有摄像头
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            [picker setSourceType:(UIImagePickerControllerSourceTypeCamera)]; //资源类型为照相机
            [picker setAllowsEditing:YES]; //设置拍照后的图片可被编辑
            [picker setDelegate:self];
            [self presentViewController:picker animated:YES completion:^{ }];
        }
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [navigationController.navigationBar setBarStyle:(UIBarStyleBlackTranslucent)];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [picker dismissViewControllerAnimated:YES completion:^{ }]; //关闭摄像头或用户相册
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5]];
    UIImageView *imgView = [cell viewWithTag:111];
    imgView.image = newImage;
    self.img = newImage;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
//当用户按下return去键盘
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]){
        [textView  resignFirstResponder];
        return NO;
    }
    return YES;
    
}
- (BOOL)textFieldShouldBeginEditing:(UITextView *)textField {

    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextView *)textField {
    return YES;
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
