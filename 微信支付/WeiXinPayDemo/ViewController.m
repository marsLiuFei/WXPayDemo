//
//  ViewController.m
//  WeiXinPayDemo
//
//  Created by apple on 2017/4/14.
//  Copyright © 2017年 baixinxueche. All rights reserved.
//

#import "ViewController.h"


#define WXApiPayURL @"http://www.baixinxueche.com/index.php/Home/wxapppay/pay"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [self listenNotifications];
}

- (IBAction)wxpay:(UIButton *)sender {
    [self doWXApiPay];
}


- (void )doWXApiPay{
    BXHttpManager *manager = [BXHttpManager manager];
    //    NSString *params = [NSString stringWithFormat:@"%@",@""];
    [manager POSTS:@"http://www.baixinxueche.com/index.php/Home/wxapppay/pay" parameters:nil Success:^(id responseObject) {
        
        MYLog(@"responseObject --------- %@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        
        NSDictionary *dic11 = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                NSDictionary *dic22 = dic11[@"responseData"];
        NSDictionary *dic33 = dic22[@"app_response"];
        if ( dic11 != nil) {
            NSMutableDictionary *dict = NULL;
            dict = [dic33 mutableCopy];
            if(dict != nil){
                NSMutableString *retcode = [dict objectForKey:@"retcode"];
                if (retcode.intValue == 0){
                    NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
                    //调起微信支付
                    PayReq* req             = [[PayReq alloc] init];
                    req.partnerId           = [dict objectForKey:@"partnerid"];
                    req.prepayId            = [dict objectForKey:@"prepayid"];
                    req.nonceStr            = [dict objectForKey:@"noncestr"];
                    req.timeStamp           = stamp.intValue;
                    req.package             = [dict objectForKey:@"package"];
                    req.sign                = [dict objectForKey:@"sign"];
                    [WXApi sendReq:req];
                    NSLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",[dict objectForKey:@"appid"],req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
                }else{
                    [SVProgressHUD showErrorWithStatus:[dict objectForKey:@"retmsg"]];
                }
            }else{
                [SVProgressHUD showErrorWithStatus:@"服务器返回错误，未获取到json对象"];
            }
        }
        
    } andFailure:^(NSError *error) {
        MYLog(@"网络错误!!!");
        [SVProgressHUD showErrorWithStatus:@"网络错误!"];
    }];
    
}

#pragma mark -- 监听通知相关的方法
- (void)listenNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenAlipayResults:) name:@"listenWXpayResults" object:nil];
}

#pragma mark -- 监听到场地信息变化的消息后做的事情
- (void)listenAlipayResults:(NSNotification *)notification
{
    BaseResp *resp =  notification.userInfo[@"resultDic"];
    //支付返回结果，实际支付结果需要去微信服务器端查询
    NSString *strMsg;
    switch (resp.errCode) {
        case WXSuccess:
            strMsg = @"支付结果：成功！";
            [SVProgressHUD showInfoWithStatus:strMsg];
            MYLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
            break;
            
        default:
            strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
            [SVProgressHUD showInfoWithStatus:strMsg];
            MYLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
            break;
    }
    
}







- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
