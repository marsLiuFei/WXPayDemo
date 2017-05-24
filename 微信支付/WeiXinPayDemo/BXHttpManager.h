//
//  BXHttpManager.h
//  mp4
//
//  Created by mars on 16/12/3.
//  Copyright © 2016年 mars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


// 请求成功回调block
typedef void(^Success)(id responseObject);
// 请求失败回调block
typedef void(^Failure)(NSError * error);

@interface BXHttpManager : NSObject
/** 创建网络请求管理类 */
+(instancetype)manager;
/** GET请求 */
- (void)GET:(NSString *)URLString parameters:(id)parameters Success :(Success)success andFailure:(Failure)failure;

/** POST请求 */
- (void)POSTS:(NSString *)URLString parameters:(id)parameters Success :(Success)success andFailure:(Failure)failure;

/**
 * ********************      向服务器上传图片       ********************
 *  urlStr  请求的网址
 *  params  发送请求的参数的字典
 *  imageArray  需要上传图片的数组
 *  file  接收上传文件的key的数组
 *  imageName  上传图片取什么名字的数组（自己取的）
 *
 */
-(void)PostImagesToServer:(NSString *) strUrl dicPostParams:(NSMutableDictionary *)params imageArray:(NSArray *) imageArray file:(NSArray *)fileArray imageName:(NSArray *)imageNameArray Success :(Success)success andFailure:(Failure)failure;
@end
