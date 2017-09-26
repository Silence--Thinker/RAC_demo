//
//  ViewController.m
//  RACDemo
//
//  Created by silence on 2017/9/26.
//  Copyright © 2017年 silence. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self racsignal_demo_01];
}


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

@end
