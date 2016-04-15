//
//  NetWork.h
//  GPS_Map
//
//  Created by NapoleonYoung on 15/10/28.
//  Copyright (c) 2015年 DoubleWood. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetWork : NSObject

@property (strong, nonatomic) NSString *socketHost;
@property (strong, nonatomic) NSString *socketPort;
@property (strong, nonatomic) NSString *sendingData;
@property (strong, nonatomic) NSString *receiveData;
@property (strong, nonatomic) NSData *receivedData;

/**
 *  网络是否在线标志位，1在线；0断开
 **/
@property (nonatomic) BOOL onLineFlag;

/**
 *当网络状态标志位onLineFlag值改变时发送通知即onLineFlagChanged
 *当收到数据后发送通知，即didReceiveData
 */
#define OnLineFlagChangedNotification @"onLineFlagChanged"
#define DidReceiveDataNotification @"didReceiveData"

/**
 *本地Host和Port
 */
#define LocalHost @"localHost"
#define LocalPort @"localPort"


//单例
+ (instancetype)sharedInstance;

/*
//连接网络
- (void)connectToHost;
 */

/**
 *  连接到指定的host和port上，如果出现错误，打印错误
 *
 *  @param host 将要连接的目标host
 *  @param port 将要连接的目标port
 */
- (void)connectToServerWithHost:(NSString *)host andPort:(uint16_t)port;

/**
 *  连接到指定的host和port上，如果出现错误，打印错误
 *
 *  @param host     host
 *  @param port     port
 *  @param interval 超时时间
 */
- (void)connectToHost:(NSString *)host Port:(uint16_t)port withTimeout:(NSTimeInterval)interval;

/**
 *  返回本地IP和Port
 *
 *  @return 字典形式的本地IP和Port，key1为LocalHost，key2为LocalPort
 */
- (NSDictionary *)localHostAndPort;

//发送数据
- (void)sendOutData:(NSString *)willBeSendedData withTag:(long)tag;

//断开连接
- (void)cutOffSocket;

@end
