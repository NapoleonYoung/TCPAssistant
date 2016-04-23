//
//  ViewController.m
//  TCPAssistant
//
//  Created by NapoleonYoung on 15/12/10.
//  Copyright © 2015年 DoubleWood. All rights reserved.
//

#import "ViewController.h"
#import "NetWork.h"
#import "Header.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *connectedHostTextField;//目标host
@property (weak, nonatomic) IBOutlet UITextField *connectedPortTextField;//目标port

@property (weak, nonatomic) IBOutlet UIButton *connectOrDisconnectButton;//连接／断开按钮

@property (weak, nonatomic) IBOutlet UITextField *sendingMessageTextField1;//消息发送框
@property (weak, nonatomic) IBOutlet UITextField *sendingMessageTextField2;
@property (weak, nonatomic) IBOutlet UITextField *sendingMessageTextField3;
@property (weak, nonatomic) IBOutlet UITextField *sendingMessageTextField4;

@property (weak, nonatomic) IBOutlet UIButton *sendButton1;//消息发送按钮
@property (weak, nonatomic) IBOutlet UIButton *sendButton2;
@property (weak, nonatomic) IBOutlet UIButton *sendButton3;
@property (weak, nonatomic) IBOutlet UIButton *sendButton4;

@property (weak, nonatomic) IBOutlet UITextView *receivedMessageTextView;

@property (weak, nonatomic) IBOutlet UIButton *clearLogButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatior;

/**
 *  用于显示目前的状态，如果未连接，显示：Please Connect First
 *  如果连接上，显示：Host：和Port：
 *  如果Host或者Port未填写，显示：Host Or Port Can't be empty
 */
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;

@property (strong, nonatomic) NSTimer *sendingTimer;
@property (weak, nonatomic) IBOutlet UISwitch *switchPeriodSending;//定时发送开关

/**
 *  当前被按下的发送按钮
 */
@property (strong, nonatomic) UIButton *buttonPressed;

/**
 *  前次被按下的按钮
 */
@property (strong, nonatomic) UIButton *buttonLastPressed;

/**
 *  定时发送时间设定
 */
@property (weak, nonatomic) IBOutlet UITextField *timeSettingTextField;

@property (weak, nonatomic) IBOutlet UILabel *sendPeriodLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIColor *bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"金属核心纹理.jpg"]];
    
    self.view.backgroundColor = bgColor;
    
    self.connectedHostTextField.delegate = self;
    self.connectedPortTextField.delegate = self;
    self.sendingMessageTextField1.delegate = self;
    self.sendingMessageTextField2.delegate = self;
    self.sendingMessageTextField3.delegate = self;
    self.sendingMessageTextField4.delegate = self;
    
    self.connectedHostTextField.text = @"219.218.126.166";
    self.connectedPortTextField.text = @"20002";
    self.receivedMessageTextView.text = @"";
    
    
    [self setSendButtonBorder];
    
    [self getCurrentTime];
    
}

- (void)setSendButtonBorder
{
    self.connectOrDisconnectButton.layer.cornerRadius = 6;
    self.sendButton1.layer.cornerRadius = 6;
    self.sendButton2.layer.cornerRadius = 6;
    self.sendButton3.layer.cornerRadius = 6;
    self.sendButton4.layer.cornerRadius = 6;
    
    self.clearLogButton.layer.cornerRadius = 6;
    self.receivedMessageTextView.layer.cornerRadius = 6;
}

- (void)startTimer
{
    if (SOCKET.onLineFlag) {//已连接服务器
        if (self.timeSettingTextField.text.length) {
            
            //首先设置buttontitle
            [self setButtonTitle:self.buttonPressed];
            
            NSTimeInterval timeInterval = [self.timeSettingTextField.text doubleValue];
            NSLog(@"timeInterval:%f", timeInterval);
            
            self.sendingTimer = [NSTimer timerWithTimeInterval:timeInterval
                                                        target:self
                                                      selector:@selector(timeFireMethod:)
                                                      userInfo:nil
                                                       repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.sendingTimer forMode:NSDefaultRunLoopMode];
        }
    } else {//未连接服务器
        [self.activityIndicatior startAnimating];
        self.notificationLabel.text = NSLocalizedString(@"Connecting...Waiting Please", nil);//前面两个空格是为了给activity indicator腾出空间
        
        self.sendingTimer = [NSTimer timerWithTimeInterval:CONNECTTIMEOUT
                                                    target:self
                                                  selector:@selector(timeFireMethod:)
                                                  userInfo:nil
                                                   repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.sendingTimer forMode:NSDefaultRunLoopMode];
        
    }
    
    
}


- (void)stopTimer
{
    [self.sendingTimer invalidate];
    [self.activityIndicatior stopAnimating];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//视图出现的时候监听通知
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setConnectOrCutoffButtonTitle];//当视图disAppear后，网络在线状态标志位onLineFlag改变了，然后视图appear，那么这个notification不会被监听到，因此需要在这里加上这行代码，视图出现，先检测onLineFlag，设置按钮标签
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLineFlagChanged:) name:OnLineFlagChangedNotification object:SOCKET];//网络状态标志位发生变化,添加通知和移除通知必须成对出现
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveData:) name:DidReceiveDataNotification object:SOCKET];//接收到来自服务器的数据,添加通知和移除通知必须成对出现
}

//视图消失前移除监听
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OnLineFlagChangedNotification object:nil];//移除网络状态标志位监听者，移除通知和添加通知必须成对出现
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DidReceiveDataNotification object:nil];//移除接收数据监听者，移除通知和添加通知必须成对出现
}

//监听到通知后执行的方法
- (void)onLineFlagChanged:(NSNotification *)notification
{
    if (SOCKET.onLineFlag) {
        [self.activityIndicatior stopAnimating];
    }
    [self setConnectOrCutoffButtonTitle];
}

//接收数据后调用次函数
- (void)didReceiveData:(NSNotification *)notification
{
    NSString *receivedString = [[NSString alloc] initWithData:SOCKET.receivedData encoding:NSUTF8StringEncoding];
    NSString *mediumString = [NSString stringWithFormat:@"-[%@]:\n%@\n", [self getCurrentTime], receivedString];
    NSString *stringOfBefore = [NSString stringWithFormat:@"%@",self.receivedMessageTextView.text];
    stringOfBefore = [mediumString stringByAppendingString:stringOfBefore];
    self.receivedMessageTextView.text = stringOfBefore;
}

/**
 *  获取当前时间，格式：时：分：秒：毫秒
 *
 *  @return 当前时间
 */
- (NSString *)getCurrentTime
{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"hh:mm:ss:SSS"];
    NSString *currentTime = [timeFormatter stringFromDate:[NSDate date]];
    NSLog(@"当前时间：%@", currentTime);
    return currentTime;
    
}

//设置按钮标签
- (void)setConnectOrCutoffButtonTitle
{
    
    if (SOCKET.onLineFlag) {// 如果此时网络连接状态，将按钮标签设为“断开”
        [self.connectOrDisconnectButton setTitle:NSLocalizedString(@"DisConnect", nil) forState:UIControlStateNormal];
        //通知标签显示本地IP和Port
        self.notificationLabel.text = [NSString stringWithFormat:@"Local IP:%@ Port:%@", [[SOCKET localHostAndPort] valueForKey:LocalHost], [[SOCKET localHostAndPort] valueForKey:LocalPort]];
    } else {// 如果此时网络断开状态，将按钮标签设为“连接”
        
        NSLog(@"已断网");
        
        //[self.connectOrDisconnectButton setTitle:@"Connect" forState:UIControlStateNormal];
        [self.connectOrDisconnectButton setTitle:NSLocalizedString(@"Connect", nil) forState:UIControlStateNormal];
        //如果此时手机未联网，按下connect button后会立刻收到网络断开标志，此时activity indicator在转动，定时器在工作，因此首先需要停止
        [self stopTimer];
        self.notificationLabel.text = NSLocalizedString(@"Please Connect First", nil);
    }
}

#pragma mark - view生命周期相关函数调用方法

- (void)timeFireMethod:(NSTimer *)timer
{
    if (SOCKET.onLineFlag) {
        [self sendMessage:self.buttonPressed];
    } else {
        [self.activityIndicatior stopAnimating];
        self.notificationLabel.text = NSLocalizedString(@"Please Connect First", nil);
    }
}

#pragma mark - Action

- (IBAction)connectOfDisconnectWithServer:(UIButton *)sender
{
    if (SOCKET.onLineFlag) {//网络连接状态
        [self disconnectFormServer];
        
    } else {//网络断开状态
        [self connectToServer];
        
        //开启定时器
        [self startTimer];
    }
}
- (IBAction)switchOfPeriodSend:(UISwitch *)sender
{
    if (sender.on) {
        self.sendPeriodLabel.hidden = NO;
        self.timeSettingTextField.hidden = NO;
    } else {
        self.sendPeriodLabel.hidden = YES;
        self.timeSettingTextField.hidden = YES;
        
        //首先将button的title改回send
        //[self setButtonTitle:self.buttonPressed];
        
    }
}

/**
 *  发送button按钮左边textField中内容，如果自动发送
 *
 *  @param sender 相应的按钮
 */
- (IBAction)sendMessageWithTextFieldText:(UIButton *)sender
{
    [self.view endEditing:YES];
   // [self sendMessage:sender];

    if (SOCKET.onLineFlag) {
        if (self.switchPeriodSending.on) {//自动发送已经开启
            //首先设置发送button状态
           // [self setButtonTitle:sender];
            
            if ([sender.currentTitle isEqualToString:NSLocalizedString(@"send", nil)]) {
                if (self.timeSettingTextField.text.length) {
                    self.buttonPressed = sender;
                    
                    [self startTimer];
                    NSLog(@"定时器开启");
                    [self setButtonStateToAuto:sender];
                } else {
                    [self alertViewWithTitle:nil
                                     message:NSLocalizedString(@"time is null", nil)
                           cancelButtonTitle:NSLocalizedString(@"YES", nil)
                           otherButtonTitles:nil];

                }
            } else if ([sender.currentTitle isEqualToString:NSLocalizedString(@"stop", nil)]) {
                [self stopTimer];
                [self setButtonStateToStopAuto];
                NSLog(@"定时器关闭");
            }
        }   else {//自动发送已关闭
            [self stopTimer];
            [self sendMessage:sender];
        }
    }
}

/**
 *  设置button自动发送状态
 *
 *  @param button button
 */
- (void)setButtonStateToAuto:(UIButton *)button
{
    int buttonTag = (int)button.tag;
    switch (buttonTag) {
        case 1:{//sendButton1
            [self.sendButton1 setTitle:NSLocalizedString(@"stop", nil) forState:UIControlStateNormal];
            self.sendButton2.enabled = NO;
            self.sendButton2.backgroundColor = [UIColor darkGrayColor];
            self.sendButton3.enabled = NO;
            self.sendButton3.backgroundColor = [UIColor darkGrayColor];
            self.sendButton4.enabled = NO;
            self.sendButton4.backgroundColor = [UIColor darkGrayColor];

            break;
        }
        case 2:{//sendButton2
            [self.sendButton2 setTitle:NSLocalizedString(@"stop", nil) forState:UIControlStateNormal];
            self.sendButton1.enabled = NO;
            self.sendButton1.backgroundColor = [UIColor darkGrayColor];

            self.sendButton3.enabled = NO;
            self.sendButton3.backgroundColor = [UIColor darkGrayColor];

            self.sendButton4.enabled = NO;
            self.sendButton4.backgroundColor = [UIColor darkGrayColor];
            
            break;
        }
        case 3:{//sendButton3
            [self.sendButton3 setTitle:NSLocalizedString(@"stop", nil) forState:UIControlStateNormal];
            self.sendButton2.enabled = NO;
            self.sendButton2.backgroundColor = [UIColor darkGrayColor];

            self.sendButton1.enabled = NO;
            self.sendButton1.backgroundColor = [UIColor darkGrayColor];

            self.sendButton4.enabled = NO;
            self.sendButton4.backgroundColor = [UIColor darkGrayColor];
            
            break;
        }
        case 4:{//sendButton4
            [self.sendButton4 setTitle:NSLocalizedString(@"stop", nil) forState:UIControlStateNormal];
            self.sendButton2.enabled = NO;
            self.sendButton2.backgroundColor = [UIColor darkGrayColor];

            self.sendButton3.enabled = NO;
            self.sendButton3.backgroundColor = [UIColor darkGrayColor];

            self.sendButton1.enabled = NO;
            self.sendButton1.backgroundColor = [UIColor darkGrayColor];

            break;
        }

        default:{
            [self.sendButton1 setTitle:NSLocalizedString(@"stop", nil) forState:UIControlStateNormal];
            self.sendButton2.enabled = NO;
            self.sendButton2.backgroundColor = [UIColor darkGrayColor];

            self.sendButton3.enabled = NO;
            self.sendButton3.backgroundColor = [UIColor darkGrayColor];

            self.sendButton4.enabled = NO;
            self.sendButton4.backgroundColor = [UIColor darkGrayColor];

            break;
        }

    }
}

/**
 *  button停止自动发送模式
 */
- (void)setButtonStateToStopAuto
{
    [self.sendButton1 setTitle:NSLocalizedString(@"send", nil) forState:UIControlStateNormal];
    self.sendButton1.enabled = YES;
    self.sendButton1.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.sendButton2 setTitle:NSLocalizedString(@"send", nil) forState:UIControlStateNormal];
    self.sendButton2.enabled = YES;
    self.sendButton2.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.sendButton3 setTitle:NSLocalizedString(@"send", nil) forState:UIControlStateNormal];
    self.sendButton3.enabled = YES;
    self.sendButton3.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [self.sendButton4 setTitle:NSLocalizedString(@"send", nil) forState:UIControlStateNormal];
    self.sendButton4.enabled = YES;
    self.sendButton4.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
}

/**
 *  设置button的title
 *
 *  @param button 待更改标题的按钮
 */
- (void)setButtonTitle:(UIButton *)button
{
    if ([button.currentTitle isEqualToString:NSLocalizedString(@"send", nil)]) {
        [button setTitle:NSLocalizedString(@"stop", nil) forState:UIControlStateNormal];
    } else if ([button.currentTitle isEqualToString:NSLocalizedString(@"stop", nil)]) {
        [button setTitle:NSLocalizedString(@"send", nil) forState:UIControlStateNormal];
    }
}

- (void)sendMessage:(UIButton *) sender
{
    if (sender == self.sendButton1) {
#warning 此处是否需要验证textField中文本是否为空
        [SOCKET sendOutData:self.sendingMessageTextField1.text withTag:0];
    } else if (sender == self.sendButton2) {
        [SOCKET sendOutData:self.sendingMessageTextField2.text withTag:0];
    } else if (sender == self.sendButton3) {
        [SOCKET sendOutData:self.sendingMessageTextField3.text withTag:0];
    } else if (sender == self.sendButton4) {
        [SOCKET sendOutData:self.sendingMessageTextField4.text withTag:0];
    }
}

- (void)atuoSendingMessage:(UIButton *)sender
{
    if (self.switchPeriodSending.state) {
        [self startTimer];
    }
}

//消掉键盘
- (IBAction)backgroundTap:(id)sender
{/*
    [self.connectedHostTextField resignFirstResponder];
    [self.connectedPortTextField resignFirstResponder];
    [self.sendingMessageTextField1 resignFirstResponder];
    [self.sendingMessageTextField2 resignFirstResponder];
    [self.sendingMessageTextField3 resignFirstResponder];
    [self.sendingMessageTextField4 resignFirstResponder];*/

    [self.view endEditing:YES];
}

- (IBAction)clearTextView:(UIButton *)sender
{
    self.receivedMessageTextView.text = @"";
}

#pragma mark - Connect

/**
 *  连接服务器
 */
- (void)connectToServer
{
    if ((self.connectedHostTextField.text.length > 0) && (self.connectedPortTextField.text.length > 0)) {
        [SOCKET connectToHost:self.connectedHostTextField.text Port:[self.connectedPortTextField.text intValue] withTimeout:CONNECTTIMEOUT];
    } else {
        self.notificationLabel.text = @"Host Or Port Can't be empty";
    }
}

#pragma mark - Disconnect

/**
 *  断开与服务器的连接
 */
- (void)disconnectFormServer
{
    [SOCKET cutOffSocket];
}

#pragma mark - 全体函数调用方法

/**
 *  alertView展示，已集成了自动显示功能
 *
 *  @param title             title
 *  @param message           message
 *  @param cancelbuttonTitle cancelbuttonTitle
 *  @param otherButtonTitles otherButtontitles
 */
- (void)alertViewWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelbuttonTitle otherButtonTitles:(NSString *)otherButtonTitles
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:cancelbuttonTitle
                                               otherButtonTitles:otherButtonTitles, nil];
    [alertView show];
}

@end
