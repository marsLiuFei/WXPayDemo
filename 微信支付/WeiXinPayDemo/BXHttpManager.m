//
//  BXHttpManager.m
//  mp4
//
//  Created by mars on 16/12/3.
//  Copyright © 2016年 mars. All rights reserved.
//

#import "BXHttpManager.h"

@implementation BXHttpManager

static BXHttpManager * instance = nil;

+ (instancetype)manager{
    
    static dispatch_once_t onceTocken;
    dispatch_once(&onceTocken, ^{
        instance = [[BXHttpManager alloc] init];
    });
    return instance;
}

- (void)GET:(NSString *)URLString parameters:(id)parameters Success :(Success)success andFailure:(Failure)failure
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //1 构造URL网络地址
        NSURL *url = [NSURL URLWithString:URLString];
        //2 构造网络请求对象  NSURLRequest
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        //设置请求方式 GET
        request.HTTPMethod = @"GET";
        //设置请求的超时时间
        request.timeoutInterval = 60;
        //请求头
        //[request setValue:<#(nullable NSString *)#> forHTTPHeaderField:<#(nonnull NSString *)#>];
        //请求体
        //request.HTTPBody
        //3 通过配置对象构造网络会话 NSURLSession
        //使用系统默认的会话对象
        NSURLSession *session = [NSURLSession sharedSession];
        //4 创建网络任务 NSURLSessionTask
        //通过网络会话 来创建数据任务
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    failure(error);
                }
                else{
                    success(data);
                }
            });   
        }];
        //5 发起网络任务
        [dataTask resume];
    });
}

/** POST请求 */
- (void)POSTS:(NSString *)URLString parameters:(id)parameters Success :(Success)success andFailure:(Failure)failure{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //主线程
        // 1.创建一个网络路径
        NSURL *url = [NSURL URLWithString:URLString];
        // 2.创建一个网络请求，分别设置请求方法、请求参数
        NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        //设置请求的超时时间
        request.timeoutInterval = 15;
//        request.HTTPBody = [parameters dataUsingEncoding:NSUTF8StringEncoding];
        request.HTTPBody = parameters;
        
        // 3.获得会话对象
        NSURLSession *session = [NSURLSession sharedSession];
        // 4.根据会话对象，创建一个Task任务
        NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    failure(error);
                }
                else{
                    success(data);
                }
            });
            
        }];
        //5.最后一步，执行任务，(resume也是继续执行)。
        [sessionDataTask resume];
    });
} 


/**  
 * ********************      向服务器上传图片       ********************
 *  urlStr  请求的网址
 *  params  发送请求的参数
 *  imageArray  需要上传图片的数组
 *  file  接收上传文件的key
 *  imageName  上传图片取什么名字（自己取的）
 *
 */
-(void)PostImagesToServer:(NSString *) strUrl dicPostParams:(NSMutableDictionary *)params imageArray:(NSArray *) imageArray file:(NSArray *)fileArray imageName:(NSArray *)imageNameArray Success :(Success)success andFailure:(Failure)failure{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    //分界线的标识符
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    //要上传的图片
    UIImage *image;
    
    //将要上传的图片压缩 并赋值与上传的Data数组
    NSMutableArray *imageDataArray = [NSMutableArray array];
    for (int i = 0; i<imageArray.count; i++) {
        //要上传的图片
        image= imageArray[i];
        /**************  将图片压缩成我们需要的数据包大小 *******************/
        NSData * data = UIImageJPEGRepresentation(image, 1.0);
        CGFloat dataKBytes = data.length/1000.0;
        CGFloat maxQuality = 0.9f;
        CGFloat lastData = dataKBytes;
        while (dataKBytes > 1024 && maxQuality > 0.01f) {
            //将图片压缩成1M
            maxQuality = maxQuality - 0.01f;
            data = UIImageJPEGRepresentation(image, maxQuality);
            dataKBytes = data.length / 1000.0;
            if (lastData == dataKBytes) {
                break;
            }else{
                lastData = dataKBytes;
            }
        }
        /**************  将图片压缩成我们需要的数据包大小 *******************/
        [imageDataArray addObject:data];
    }

    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    //参数的集合的所有key的集合
    NSArray *keys= [params allKeys];
    
    //遍历keys
    for(int i=0;i<[keys count];i++) {
        //得到当前key
        NSString *key=[keys objectAtIndex:i];

        //添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        //添加字段名称，换2行
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];

        //添加字段的值
        [body appendFormat:@"%@\r\n",[params objectForKey:key]];

    }

    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    //循环加入上传图片
    for(int i = 0; i< [imageDataArray count] ; i++){
        //要上传的图片
        //得到图片的data
        NSData* data =  imageDataArray[i];
        NSMutableString *imgbody = [[NSMutableString alloc] init];
        //此处循环添加图片文件
        //添加图片信息字段
        ////添加分界线，换行
        [imgbody appendFormat:@"%@\r\n",MPboundary];
        [imgbody appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@.jpg\"\r\n", fileArray[i],imageNameArray[i]];
        //声明上传文件的格式
        [imgbody appendFormat:@"Content-Type: application/octet-stream; charset=utf-8\r\n\r\n"];

        //将body字符串转化为UTF8格式的二进制
        [myRequestData appendData:[imgbody dataUsingEncoding:NSUTF8StringEncoding]];
        //将image的data加入
        [myRequestData appendData:data];
        [myRequestData appendData:[ @"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"%@\r\n",endMPboundary];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    
    // 3.获得会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    // 4.根据会话对象，创建一个Task任务
    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                failure(error);
            }
            else{
                success(data);
            }
        });
        
    }];
    //5.最后一步，执行任务，(resume也是继续执行)。
    [sessionDataTask resume];
    });
}



@end
