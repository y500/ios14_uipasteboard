随着iOS 14的发布，剪切板的滥用也被大家所知晓。只要是APP读取剪切板内容，系统都会在顶部弹出提醒，而且这个提醒不能够关闭。这样，大家在使用APP的过程中就能够看到哪些APP使用了剪切板。

正好我们自己的应用也使用了剪切板，升级了iOS 14之后弹的着实让人心烦。就想着怎么处理一下，翻了一下`UIPasteboard`的文档，发现相关的内容并不多。
读取`UIPasteboard`的`string`、`strings`、`URL`、`URLs`、`image`、`images`、`color`、`colors`的时候会触发系统提示。
使用`hasStrings`、`hasURLs`、`hasImages`、`hasColors`等方法的时候不会触发系统提示。
那么思路就是尽可能少的去调用会触发系统提示的方法，根据其他方法去判断确实需要读取的时候再去调用那些方法。
根据我们自己的情况，只有判断`hasStrings`为`YES`就去读取，又不能清剪切板，其实还是有点不尽人意，然后又看到这个属性：
```
@property(readonly, nonatomic) NSInteger changeCount;
```
```
The number of times the pasteboard’s contents have changed.

Whenever the contents of a pasteboard changes—specifically, when pasteboard items are added, modified, or removed—UIPasteboard increments the value of this property. After it increments the change count, UIPasteboard posts the notifications named UIPasteboardChangedNotification (for additions and modifications) and UIPasteboardRemovedNotification (for removals). These notifications include (in the userInfo dictionary) the types of the pasteboard items added or removed. Because UIPasteboard waits until the end of the current event loop before incrementing the change count, notifications can be batched. The class also updates the change count when an app reactivates and another app has changed the pasteboard contents. When users restart a device, the change count is reset to zero.
```
然后就又加了一个条件，记录一下真正读取剪切板时的`changeCount`，如果下次读取的时候没有发生变化则不读取。
这样一来效果就好多了，应用运行生命周期内，基本上只会弹出一次提示。

但是，后来看到淘宝更牛逼，命中了真正分享出来的内容才会弹，其他则不会弹。然后就研究了一下淘宝的分享内容和新的API文档，大概得到了答案。
先看下淘宝的分享内容：
```
9👈幅治内容 Http:/T$AJg8c4IfW3q$打開👉绹..寶👈【贵州茅台酒 茅台 飞天53度酱香型白酒收藏 500ml*1单瓶装送礼高度】
```
组成部分：数字+文字+链接的形势，再结合iOS 14提供的新API：

```
detectPatternsForPatterns:completionHandler:
detectPatternsForPatterns:inItemSet:completionHandler:                                
```

而`UIPasteboardDetectionPattern`系统只提供了三种：

1. 数字 `UIPasteboardDetectionPatternNumber`
2. 链接 `UIPasteboardDetectionPatternProbableWebURL`
3. 搜索`UIPasteboardDetectionPatternProbableWebSearch`

大胆猜测，淘宝应该是通过判断是否符合数字和链接的规则来判断是否命中分享内容。

然后就写了一个demo来验证，核心代码如下：
```
UIPasteboard *board = [UIPasteboard generalPasteboard];
    
[board detectPatternsForPatterns:[NSSet setWithObjects:UIPasteboardDetectionPatternProbableWebURL, UIPasteboardDetectionPatternNumber, UIPasteboardDetectionPatternProbableWebSearch, nil]
                   completionHandler:^(NSSet<UIPasteboardDetectionPattern> * _Nullable set, NSError * _Nullable error) {
        
        BOOL hasNumber = NO, hasURL = NO;
        for (NSString *type in set) {
            if ([type isEqualToString:UIPasteboardDetectionPatternProbableWebURL]) {
                hasURL = YES;
            } else if ([type isEqualToString:UIPasteboardDetectionPatternNumber]) {
                hasNumber = YES;
            }
        }
        
        if (hasNumber && hasURL) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:[NSString stringWithFormat:@"%@\n%@", [board string], @"符合淘宝的读取标准"] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancelAction];
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
    }];
```

然后构造了一个看起来符合条件`1 http:/123abc`的串去反向验证了一下发现demo和淘宝的结果的表现是一致的，都弹了系统提示。

详见 https://y500.me/2020/09/27/ios14_taobao_uipasteboard/
            });
