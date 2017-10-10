OSSAskAndAnswerModule

RAC(self,merchant) = NVWBObserve(self, merchant);

那个RAC这样写是没有问题的
原因如下：
关于两次调用接口的修改的解释：
刚进入页面没有数据 调用逻辑

通过协议进入这个POI页面时。走的是initWithMerchant:默认初始化了merchant 并将协议的携带的poi_id、stid、ct_poi 赋值到了merchant中，
所以VC一初始化merchant就有了值

最重要的问题在这一句
RAC(self, merchant) = NVWBObserve(self, merchant);
看下NVWBObserve的定义

<pre><code>
#define NVWBObserve(TARGET, KEYPATH) \
[self.whiteBoard signalForKey:@keypath(TARGET, KEYPATH)]
</code></pre>

这句话是将self的merchant的值和self.whiteBoard的merchant值做对应，即：self.whiteBoard的merchant值改变那么self的merchant的值就等于它。并且携带初始值(具体的宏定义有点复杂，我看了结果，有空解开看下吧)。
OverseaShopInfoViewController.m ==>>merchant初始化==>>modules==>>子控件的setupModule==>>请求数据
完全不会在请求数据是有空的merchant。。
=============
大家可以放心给我A了

<pre><code>
initWithMerchant:(OverseaMerchant *)merchant
p_requestExtraData

self.whiteBoard[@keypath(self, merchant)] = merchant;

NVWhiteBoard *whiteBoard
NSMutableDictionary *subjects;
NVWhiteBoardSubject *subject = [self subjectForKey:key];
NVWhiteBoardSubject : RACSubject
- (RACDisposable *)subscribe:(id<RACSubscriber>)subscriber
    if (self.currentValue) {
            @synchronized (self) {
                [subscriber sendNext:self.currentValue];
            }
    }
- (void)sendNext:(id)value {
    @synchronized (self) {
        self.currentValue = value;
        [super sendNext:value];
    }
}

(void)setValue:(id)value forKey:(NSString *)key
[[self subjectForKey:key] sendNext:value];
(void)setObject:(nullable id)object forKeyedSubscript:(nonnull NSString *)key

</code></pre>

 //keypath(...)
//    metamacro_if_eq(1, metamacro_argcount(__VA_ARGS__))(keypath1(__VA_ARGS__))(keypath2(__VA_ARGS__))
//    keypath2(OBJ, PATH)
//    (((void)(NO && ((void)self.merchant, NO)), "merchant"))


<pre><code>
metamacro_argcount(a, b, c);
    
#define metamacro_argcount(...) \
    metamacro_at(20, __VA_ARGS__, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1)
    metamacro_at(20, a, b ,c , 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1);
    
#define metamacro_at(N, ...) \
    metamacro_concat(metamacro_at, N)(__VA_ARGS__)
    metamacro_concat(metamacro_at, 20)(a, b, c, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1);
    
#define metamacro_concat(A, B) \
    metamacro_concat_(A, B)
#define metamacro_concat_(A, B) A ## B
    metamacro_at20(a, b, c, 20, 19, 18, 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1);
    
#define metamacro_at20(_0, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12, _13, _14, _15, _16, _17, _18, _19, ...) metamacro_head(__VA_ARGS__)
    metamacro_head(3, 2, 1);
    
#define metamacro_head(...) \
    metamacro_head_(__VA_ARGS__, 0)
    metamacro_head_(3, 2, 1, 0);
    
#define metamacro_head_(FIRST, ...) FIRST
    int x = metamacro_head_(3, 2, 1, 0); // x = 3


RACSubscriptingAssignmentTrampoline
// 非正式协议 下标设置值
- (void)setObject:(RACSignal *)signal forKeyedSubscript:(NSString *)keyPath;

</code></pre>

### keypath(...) 宏解析

### RAC() RAC_ 宏解析
