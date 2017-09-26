//
//  ViewController.m
//  RACDemo
//
//  Created by silence on 2017/9/26.
//  Copyright © 2017年 silence. All rights reserved.
//

#import "ViewController.h"
#import "NextViewController.h"

@interface ViewController ()

@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self racsignal_demo_01];
//    [self racsubject_demo_01];
    [self racreplaysubject_demo_01];
}

// RACSignal 信号 RACDisposable
- (void)racsignal_demo_01 {
    // racsignal 内部会有生成一个消息的订阅者，而且这个订阅者是直接拿不到的。
    // 所以发送信号也只能在create 信号的时候去做
    // 信号创建==>>内部订阅者发送信号==>>信号
    
    // 创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // block 调用时刻：每当有订阅者订阅信号，就会调用blcok
        // 即：只有signal subscribeNext调用才会调用该block
        NSLog(@"11111111");
        
        // 发送信号
        [subscriber sendNext:@"xxx"];
        
        // 如果不在发送数据，最好发送信号完成，内部会调用[RACDisposable dispose]取消订阅信号
//        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
           // block 调用时刻：当信号发送完成或者发送错误，会自动执行这个block，取消订阅信号
            NSLog(@"取消订阅信号");
        }];
    }];
    
    // 订阅信号
    [signal subscribeNext:^(id x) {
        NSLog(@"222222222");
        NSLog(@"222222222 x is what %@", x);
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"333333333");
        NSLog(@"333333333 x is what %@", x);
    }];
  /*
log:
    11111111
    222222222
    222222222 x is what xxx
    11111111
    333333333
    333333333 x is what xxx
   */
}

// RACSubject 信号，既可以发送信号，也可以订阅信号
- (void)racsubject_demo_01 {
    // RACSubject:底层实现和RACSignal不一样。
    // 1.调用subscribeNext订阅信号，只是把订阅者保存起来，并且订阅者的nextBlock已经赋值了。
    // 2.调用sendNext发送信号，遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    
    // 创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 订阅信号
    [subject subscribeNext:^(id x) {
       NSLog(@"订阅信号 111111 %@", x);
    }];
    
    [subject subscribeNext:^(id x) {
       NSLog(@"订阅信号 222222 %@", x);
    }];
    
    // 发送信号
    [subject sendNext:@"信号东东"];
    
    /*
log:
    订阅信号 111111 信号东东
    订阅信号 222222 信号东东
     */
}

// ARCReplaySubject 不管调用的顺序只管结果。。一点一览无余
- (void)racreplaysubject_demo_01 {
    // RACReplaySubject:底层实现和RACSubject不一样。
    // 1.调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    // 2.调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock
    
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"订阅信号 333333 %@", x);
    }];
    // 发送信号
    [replaySubject sendNext:@"信号111"];
    [replaySubject sendNext:@"信号222"];
    
    // 订阅信号
    [replaySubject subscribeNext:^(id x) { // 这个订阅先调用两次
       NSLog(@"订阅信号 111111 %@", x);
    }];
    
    [replaySubject subscribeNext:^(id x) { // 这个订阅再调用两次
        NSLog(@"订阅信号 222222 %@", x);
    }];
    /*
log:
     订阅信号 333333 信号111
     订阅信号 333333 信号222
     订阅信号 111111 信号111
     订阅信号 111111 信号222
     订阅信号 222222 信号111
     订阅信号 222222 信号222
     */
}


- (void)sss {
    
}

- (IBAction)didClickBtn:(id)sender {
    NextViewController *next = [[NextViewController alloc] init];
    next.signalSubject = [RACSubject subject];
    [next.signalSubject subscribeNext:^(id x) {
        [self.button setTitle:x forState:UIControlStateNormal];
    }];
    [self.navigationController pushViewController:next animated:YES];
}
@end
