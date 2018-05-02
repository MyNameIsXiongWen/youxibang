//
//  NewsDetailViewController.m
//  youxibang
//
//  Created by jiazhuo1 on 2018/4/26.
//

#import "NewsDetailViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "LoginViewController.h"
#import "NewsReviewTableViewCell.h"
#import "NewsReviewModel.h"

static NSString *const REVIEW_TABLEVIEW_ID = @"review_tableview_id";
@interface NewsDetailViewController () <UIWebViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
}
@property (assign, nonatomic) int currentPage;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *reviewTextField;
- (IBAction)clickReviewBtn:(id)sender;
- (IBAction)clickLaudBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *laudButton;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (strong, nonatomic) NSMutableArray *reviewArray;

@end

@implementation NewsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.laudButton.layer.borderColor = [UIColor colorFromHexString:@"b2b2b2"].CGColor;
    self.laudButton.layer.borderWidth = 0.5;
    self.laudButton.layer.cornerRadius = 16;
    self.laudButton.layer.masksToBounds = YES;
    self.reviewTextField.layer.borderColor = [UIColor colorFromHexString:@"b2b2b2"].CGColor;
    self.reviewTextField.layer.borderWidth = 0.5;
    self.reviewTextField.layer.cornerRadius = 16;
    self.reviewTextField.layer.masksToBounds = YES;
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 8, 40, 16)];
    leftView.backgroundColor = UIColor.clearColor;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news_pencil"]];
    imageView.frame = CGRectMake(12, 0, 19, 16);
    [leftView addSubview:imageView];
    self.reviewTextField.leftView = leftView;
    self.reviewTextField.leftViewMode = UITextFieldViewModeAlways;
    self.currentPage = 1;
    
    [self.webView sizeToFit];
    [self.webView scalesPageToFit];
    self.tableview.tableHeaderView = self.webView;
    [self.tableview registerNib:[UINib nibWithNibName:@"NewsReviewTableViewCell" bundle:nil] forCellReuseIdentifier:REVIEW_TABLEVIEW_ID];
    [self getNewsDetailRequest];
    self.tableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHead)];
    self.tableview.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshFooter)];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self getNewsDetailReviewListRequest];
    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    CGSize actualSize = [webView sizeThatFits:CGSizeZero];
    CGRect newFrame = webView.frame;
    newFrame.size.height = actualSize.height;
    webView.frame = newFrame;
    self.tableview.tableHeaderView = self.webView;
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [SVProgressHUD dismiss];
    [SVProgressHUD setDefaultMaskType:1];
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    context[@"getUserId"] = ^(){
        
    };
    //    NSString *urlString =[[request URL] absoluteString];
    return YES;
}

#pragma mark - tableview refresh
//头部刷新方法
- (void)refreshHead {
    self.currentPage = 1;
    [self getNewsDetailReviewListRequest];
    [self.tableview.mj_header endRefreshing];
}
//尾部刷新方法
- (void)refreshFooter {
    self.currentPage ++;
    [self getNewsDetailReviewListRequest];
    [self.tableview.mj_footer endRefreshing];
}

//获取资讯详情
- (void)getNewsDetailRequest {
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSMutableDictionary *dic = @{@"article_id":self.newsModel.article_id}.mutableCopy;
    if (DataStore.sharedDataStore.token) {
        [dic setObject:[DataStore sharedDataStore].token forKey:@"token"];
    }
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@article/get_details",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                self.newsModel = [NewsModel mj_objectWithKeyValues:object[@"data"]];
                [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.newsModel.content]]];
                
                [self.laudButton setTitle:self.newsModel.laud_count forState:0];
                if ([self.newsModel.is_laud integerValue] == 0) {
                    [self.laudButton setImage:[UIImage imageNamed:@"news_like"] forState:0];
                    self.laudButton.selected = NO;
                }
                else {
                    [self.laudButton setImage:[UIImage imageNamed:@"news_liked"] forState:0];
                    self.laudButton.selected = YES;
                }
            }else {
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}

- (void)getNewsDetailReviewListRequest {
    NSMutableDictionary *dic = @{@"article_id":self.newsModel.article_id,
                                 @"page":[NSString stringWithFormat:@"%d",self.currentPage]}.mutableCopy;
    if (DataStore.sharedDataStore.token) {
        [dic setObject:DataStore.sharedDataStore.token forKey:@"token"];
    }
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@article/comment_list",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                if (self.currentPage == 1) {
                    self.reviewArray = [NewsReviewModel mj_objectArrayWithKeyValuesArray:object[@"data"]];
                }
                else {
                    [self.reviewArray addObjectsFromArray:[NewsReviewModel mj_objectArrayWithKeyValuesArray:object[@"data"]]];
                }
                [self.tableview reloadData];
            }
            else {
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any  that can be recreated.
}

//实现UITextField代理方法
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self reviewArticleRequestWithContent:textField.text];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.reviewTextField resignFirstResponder];
}

- (void)reviewArticleRequestWithContent:(NSString *)content {
    if (!DataStore.sharedDataStore.token) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSDictionary *dic = @{@"article_id":self.newsModel.article_id,
                          @"token":[DataStore sharedDataStore].token,
                          @"details":content};
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:[NSString stringWithFormat:@"%@article/publish_comment",HttpURLString] Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                NewsReviewModel *model = [NewsReviewModel new];
                model.comment_id = object[@"data"];
                model.article_id = self.newsModel.article_id;
                model.head_pic = UserModel.sharedUser.photo;
                model.nickname = UserModel.sharedUser.nickname;
                model.user_id = DataStore.sharedDataStore.userid;
                model.is_laud = @"0";
                model.laud_count = @"0";
                model.time = @"刚刚";
                model.details = content;
                [self.reviewArray insertObject:model atIndex:0];
                [self.tableview insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                self.reviewTextField.text = @"";
                [self.reviewTextField resignFirstResponder];
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)clickReviewBtn:(id)sender {
    [self.tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction)clickLaudBtn:(id)sender {
    [self likeRequest:(UIButton *)sender];
}

//点赞/取消点赞
- (void)likeRequest:(UIButton *)sender {
    [self likerequest:sender TargetId:self.newsModel.article_id Type:@"1" CompletionHandle:^(BOOL islaud) {
        if (islaud) {
            self.newsModel.laud_count = [NSString stringWithFormat:@"%d",self.newsModel.laud_count.intValue+1];
            [sender setImage:[UIImage imageNamed:@"news_liked"] forState:UIControlStateNormal];
        }
        else {
            self.newsModel.laud_count = [NSString stringWithFormat:@"%d",self.newsModel.laud_count.intValue-1];
            [sender setImage:[UIImage imageNamed:@"news_like"] forState:UIControlStateNormal];
        }
        [sender setTitle:self.newsModel.laud_count forState:0];
    }];
}

#pragma mark - tableview delegate/datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.reviewArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsReviewModel *model = self.reviewArray[indexPath.row];
    NewsReviewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:REVIEW_TABLEVIEW_ID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.imgview sd_setImageWithURL:[NSURL URLWithString:model.head_pic] placeholderImage:[UIImage imageNamed:@"ico_tx_s"]];
    cell.nameLabel.text = model.nickname;
    cell.contentLabel.text = model.details;
    cell.timeLabel.text = model.time;
    if (model.is_laud.integerValue == 0) {
        [cell.likeButton setImage:[UIImage imageNamed:@"news_review_like"] forState:0];
        [cell.likeButton setTitleColor:[UIColor colorFromHexString:@"a2a2ae"] forState:0];
        cell.likeButton.selected = NO;
    }
    else {
        [cell.likeButton setImage:[UIImage imageNamed:@"news_liked"] forState:0];
        [cell.likeButton setTitleColor:[UIColor colorFromHexString:@"457fea"] forState:0];
        cell.likeButton.selected = YES;
    }
    [cell.likeButton setTitle:model.laud_count forState:0];
    cell.likeButton.tag = indexPath.row;
    [cell.likeButton addTarget:self action:@selector(likeButtonSelector:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsReviewModel *model = self.reviewArray[indexPath.row];
    if ([model.user_id isEqualToString:DataStore.sharedDataStore.userid]) {
        return YES;
    }
    else {
        return NO;
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
}
-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    WEAKSELF
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NewsReviewModel *model = weakSelf.reviewArray[indexPath.row];
        [weakSelf deleteReviewRequest:model.comment_id CompleteHandle:^{
            [weakSelf.reviewArray removeObject:model];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }];
    return @[deleteRoWAction];
}

- (void)likeButtonSelector:(UIButton *)sender {
    NewsReviewModel *model = self.reviewArray[sender.tag];
    [self likerequest:sender TargetId:model.comment_id Type:@"2" CompletionHandle:^(BOOL islaud) {
        if (islaud) {
            model.laud_count = [NSString stringWithFormat:@"%d",model.laud_count.intValue+1];
            [sender setImage:[UIImage imageNamed:@"news_liked"] forState:UIControlStateNormal];
            [sender setTitleColor:[UIColor colorFromHexString:@"457fea"] forState:0];
        }
        else {
            model.laud_count = [NSString stringWithFormat:@"%d",model.laud_count.intValue-1];
            [sender setImage:[UIImage imageNamed:@"news_review_like"] forState:UIControlStateNormal];
            [sender setTitleColor:[UIColor colorFromHexString:@"a2a2ae"] forState:0];
        }
        [sender setTitle:model.laud_count forState:0];
    }];
}

- (void)likerequest:(UIButton *)sender TargetId:(NSString *)targetid Type:(NSString *)type CompletionHandle:(void(^)(BOOL islaud))handle {
    if (!DataStore.sharedDataStore.token) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSDictionary *dic = @{@"token":DataStore.sharedDataStore.token,
                          @"type":type,
                          @"target_id":targetid};
    NSString *requestUrl = [NSString stringWithFormat:@"%@article/laud",HttpURLString];
    if (sender.selected) {
        requestUrl = [NSString stringWithFormat:@"%@article/cancel_laud",HttpURLString];
    }
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:requestUrl Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                sender.selected = !sender.selected;
                handle(sender.selected);
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}

- (void)deleteReviewRequest:(NSString *)commentId CompleteHandle:(void(^)(void))complete {
    if (!DataStore.sharedDataStore.token) {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController* vc = [sb instantiateViewControllerWithIdentifier:@"loginPWD"];
        [self.navigationController pushViewController:vc animated:1];
        return;
    }
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD show];
    NSDictionary *dic = @{@"token":DataStore.sharedDataStore.token,
                          @"comment_id":commentId,
                          @"article_id":self.newsModel.article_id};
    NSString *requestUrl = [NSString stringWithFormat:@"%@article/del_comment",HttpURLString];
    [[NetWorkEngine shareNetWorkEngine] postInfoFromServerWithUrlStr:requestUrl Paremeters:dic successOperation:^(id object) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        if (isKindOfNSDictionary(object)){
            NSInteger code = [object[@"errcode"] integerValue];
            NSString *msg = [NSString stringWithFormat:@"%@",[object objectForKey:@"message"]] ;
            NSLog(@"输出 %@--%@",object,msg);
            if (code == 1) {
                complete();
            }else{
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
    } failoperation:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD setDefaultMaskType:1];
        [SVProgressHUD showErrorWithStatus:@"网络信号差，请稍后再试"];
    }];
}

@end
