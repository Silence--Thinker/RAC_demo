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
//    [self racreplaysubject_demo_01];
//    [self rac_define_demo_01];
//    [self find_question];
    [self raccommandBtn_demo];
//    [self racMap_demo];
}

// RACSignal 信号 RACDisposable
// 调用遵循：创建信号==>>订阅信号==>>订阅回调中发送信号 规则 创建信号时便保存了订阅信号的回调 拿到中间订阅者
// 不可在其他地方拿到订阅者发送信号 顺序不可逆
// 订阅信号时，会调用整个didSubscribe Block(订阅block) 回调
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
        [subscriber sendCompleted];
        
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
   取消订阅信号
   11111111
   333333333
   333333333 x is what xxx
   取消订阅信号
   */
}

// RACSubject 信号，既可以发送信号，也可以订阅信号
// 创建信号==>>订阅信号==>>发送信号  顺序不可逆
- (void)racsubject_demo_01 {
    // RACSubject:底层实现和RACSignal不一样。
    // 1.调用subscribeNext订阅信号，只是把订阅者保存起来，并且订阅者的nextBlock已经赋值了。
    // 2.调用sendNext发送信号，遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    
    // 创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 发送信号
    [subject sendNext:@"发送信号 8989"];
    
    // 订阅信号
    [subject subscribeNext:^(id x) {
       NSLog(@"订阅信号 111111 %@", x);
    }];
    
    [subject subscribeNext:^(id x) {
       NSLog(@"订阅信号 222222 %@", x);
    }];
    
    // 发送信号
    [subject sendNext:@"发送信号 1010"];
    [subject sendNext:@"发送信号 6767"];
    
    /*
log:
     订阅信号 111111 发送信号 1010
     订阅信号 222222 发送信号 1010
     订阅信号 111111 发送信号 6767
     订阅信号 222222 发送信号 6767
     */
}

// ARCReplaySubject 不管调用的顺序只管结果。。一点一览无余
// ARCReplaySubject 会将订阅信号的回调，发送的信号都储存起来，调用顺序可逆
// 一旦有订阅新的信号，会去寻找当前已经发送的信号，有信号，然后调用订阅的信号回调，没有就算了
// 一旦有发送新的信号，会去寻找当前已经订阅的订阅回调，有订阅回调，调用订阅回调
- (void)racreplaysubject_demo_01 {
    // RACReplaySubject:底层实现和RACSubject不一样。
    // 1.调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    // 2.调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock
    
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"订阅信号 333333 %@", x);
    }];
    // 发送信号
    [replaySubject sendNext:@"##信号111"];
//    [replaySubject sendNext:@"##信号222"];
    
    // 订阅信号
    [replaySubject subscribeNext:^(id x) {
       NSLog(@"订阅信号 111111 %@", x);
    }];
    
    [replaySubject subscribeNext:^(id x) {
        NSLog(@"订阅信号 222222 %@", x);
    }];
    
    [replaySubject sendNext:@"##信号333"];
    /*
log:
     订阅信号 333333 ##信号111
     订阅信号 333333 ##信号222
     订阅信号 111111 ##信号111
     订阅信号 111111 ##信号222
     订阅信号 222222 ##信号111
     订阅信号 222222 ##信号222
     订阅信号 333333 ##信号333
     订阅信号 111111 ##信号333
     订阅信号 222222 ##信号333
     */
}

// RACSubject 替代代理
- (IBAction)didClickBtn:(id)sender {
    NextViewController *next = [[NextViewController alloc] init];
    next.signalSubject = [RACSubject subject];
    [next.signalSubject subscribeNext:^(id x) {
        [self.button setTitle:x forState:UIControlStateNormal];
    }];
    [self.navigationController pushViewController:next animated:YES];
}

- (void)rac_doNext
{
    RACSubject *subject = [RACSubject subject];
    RACSignal *signal = [subject doNext:^(id x) {
       NSLog(@"log do next block");
    }];
    [signal subscribeNext:^(id x) {
       NSLog(@"log subscribe next block");
    }];
    
//    [subject sendNext:@"xxxx"];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"xxxxx"];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signal3 = [signal2 doNext:^(id x) {
        NSLog(@"signal2 log do next block");
    }];
    [signal3 subscribeNext:^(id x) {
        NSLog(@"signal3 log subscribe next block");
    }];
}

- (void)rac_define_demo_01 {
    int a = 4, b = 0;
    int c = ((void)(b = b > 0 ? b : a), b); // (a, b) 只会取后面的值，当时会先进行前者的运算
    NSLog(@"%zd", b);
    NSLog(@"%zd", c);
}

- (void)find_question {
    RACSubject *subject = [RACSubject subject];
    
    [subject sendNext:@"YYYY"];
    
    [subject.rac_deallocDisposable addDisposable:[RACDisposable disposableWithBlock:^{
        NSLog(@"完成");
        [subject sendCompleted];
    }]];
    
    NSLog(@"订阅信号");
    [subject subscribeNext:^(id x) {
       NSLog(@"执行信号回调%@", x);
    }];
    
    [subject sendNext:@"xxxxx"];
}

// 网络请求类似的返回信号
- (RACSignal *)signal:(NSObject *)object
{
    RACSignal *s = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        void (^block)(NSArray *array, NSError *error) = ^(NSArray *array, NSError *error) {
            
        };
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            block(nil, nil);
            [subscriber sendNext:@"12313123"];
            
            [subscriber sendCompleted];
        });
        
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }];
    return s;
}

// RACCommand 牛逼
- (void)raccommandBtn_demo {
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@" command 01 ");
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@" signal 01 ");
            [subscriber sendNext:@"xxxxxx"];
            NSLog(@"subscriber %@", NSStringFromClass([subscriber class]));
            [subscriber sendCompleted];
            
            RACDisposable *disposable = [RACDisposable disposableWithBlock:^{
            }];
            return disposable;
        }];
        NSLog(@"input class %@", NSStringFromClass([input class]));
        return signal;
    }];
    self.racCommandBtn.rac_command  = command;
    
//    RACCommand *command2 = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
//        NSLog(@" command 02 ");
//        return [RACSignal empty];
//    }];
//    self.racCommandBtn.rac_command = command2;
}

- (void)demo_001 {
    int a = 0, b = 0;
    a = 1;
    b = 2;
    int c = ((void)a, b);
    NSLog(@"%zd", c);
//    strchr(# PATH, '.') + 1))
    NSLog(@"%@", @keypath(self.view));            // view
    NSLog(@"%s", strchr("123.456.789", '1') + 2); // 3.456.789
    
    
    RACSubject *subject = [RACSubject subject];
    
    [[subject skip:1] subscribeNext:^(id x) {
        NSLog(@"订阅信号 111111 %@", x);
    }];
    
    [subject subscribeNext:^(id x) {
        NSLog(@"订阅信号 222222 %@", x);
    }];
    
    [subject sendNext:@"发送信号 1010"];
    [subject sendNext:@"发送信号 1010"];
    
}

- (void)rac_command_signal_executing {
    // 监听事件有没有完成
    
//    1.创建命令 initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
//    2.在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
//    3.执行命令 - (RACSignal *)execute:(id)input
    
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"command 执行 %@", input);
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"执行产生的数据"];
            [subscriber sendCompleted];
            
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"内部信号执行完毕");
            }];
        }];
    }];
    
    [command.executing subscribeNext:^(id x) {
        if ([x boolValue]) {
            NSLog(@"当前command正在执行");
        } else {
            NSLog(@"当前command没有/完成执行");
        }
    }];
    [command execute:@"111111"];
}

- (void)rac_command_siganal_demo_01 {
    // 监听按钮点击，网络请求 方式一 普通做法
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"command 执行 %@", input);
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"执行产生的数据"];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"内部信号执行完毕");
            }];
        }];
    }];
    
    RACSignal *signal = [command execute:@"1111111"];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"command 执行的 信号 %@", x);
    }];
//    command 执行 1111111
//    command 执行的 信号 执行产生的数据
//    内部信号执行完毕
}
- (void)rac_command_siganal_demo_02 {
    // 监听按钮点击，网络请求 方式二 一般做法
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"command 执行 %@", input);
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"执行产生的数据"];
            [subscriber sendCompleted];
            
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"内部信号执行完毕");
            }];
        }];
    }];
    // executionSignals 是执行信号。。订阅传的值x就是上面创建的signal
    // executionSignals 信号是一个ARCReplaySubject信号。。因为先subscribeNext 才执行的execute发送信号
    [[command executionSignals] subscribeNext:^(id x) { // x 是一个信号
        [x subscribeNext:^(id x) {
            NSLog(@"能用到==%@", x);
        }];
        NSLog(@"command的执行信号 %@", x);
    }];
    
    [command execute:@"1111111"];
//    command 执行 1111111
//    command的执行信号 <RACDynamicSignal: 0x60c000227fc0> name:
//    能用到==执行产生的数据
//    内部信号执行完毕
}
- (void)rac_command_siganal_demo_03 {
    // 监听按钮点击，网络请求 方式三 高级做法
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        NSLog(@"command 执行 %@", input);
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"执行产生的数据"];
            [subscriber sendCompleted];
            
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"内部信号执行完毕");
            }];
        }];
    }];
    
    // switchToLatest获取最新发送的信号，只能用于信号中信号。
    // 将demo_02中信号的中转订阅忽略了。。。果然高级
    [command.executionSignals.switchToLatest subscribeNext:^(id x) {
        NSLog(@"能用到==%@", x);
    }];
    
    [command execute:@"1111111"];
}

// switchToLatest 获取信号中信号发送的最新信号
- (void)rac_signal_switchToLatest_demo {
    RACSubject *signalofSignal = [RACSubject subject];
    RACSubject *signalA = [RACSubject subject];
    
    [signalofSignal subscribeNext:^(RACSignal *x) {
        [x subscribeNext:^(id x) {
            NSLog(@"等效果？？？%@", x);// 跟switchToLatest是同样效果
        }];
    }];
    
    [signalofSignal.switchToLatest subscribeNext:^(id x) {
       NSLog(@"发送的最新信号 %@", x);
    }];
    
    [signalofSignal sendNext:signalA];
    [signalA sendNext:@"1111111"];
}

// RAC map
- (void)racMap_demo {
    NSArray *array = @[@1, @2, @3, @5, @6];
    array = [[array.rac_sequence map:^id(id value) {
        NSLog(@"%@", value);
        if ([value integerValue] == 1) {
            return @99;
        }
        return @12;
    }] array];
    NSLog(@"%@", array);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self racMap_demo];
//    [self demo_001];
//    [self rac_doNext];
    
//    [self rac_command_signal_executing];
//    [self rac_command_siganal_demo_01];
//    [self rac_command_siganal_demo_02];
//    [self rac_command_siganal_demo_03];
    
    [self rac_signal_switchToLatest_demo];
}

@end
