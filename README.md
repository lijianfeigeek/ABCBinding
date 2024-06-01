# ABCBinding

> experiment 实验性功能
>
> [ABCBinding--简化Cocos和Native交互利器（iOS篇） | lijianfei.com](https://lijianfei.com/post/abcbinding-ios/)

## 概述：

**ABCBinding**  是一套基于Cocos在TS中绑定Native方法的框架，旨在抹平不同平台的调用差异。相比较原有提供的跨平台调用具有如下优点

* 抹平平台差异
* 支持异步返回数据
* 调用可配置超时时间
* 提供便捷的处理进度回调接口
* 支持动态拓展接口参数
* 避免冗长包名和参数名人工配置（极易出错）
* 当不存在Native实现，有异常回调处理
* 不需要管理线程切换

#### Feature

1. **Cocos层抹平平台差异**

   Cocos获取设备信息，由于Android iOS平台差异性，需要有不同形式的调用，比如Android需要传入包名，而iOS不需要。对于参数类型返回值定义也不统一。因此当需要一个Native能力时，需要在JS代码中编写兼容代码。

    ```java
   //原生
   if (cc.sys.isNative && cc.sys.os === cc.sys.OS_IOS) {
       let isLowDevice = jsb.reflection.callStaticMethod("ABCCommon", "isLowDevice");
       return isLowDevice;
   } else if (cc.sys.isNative && cc.sys.os === cc.sys.OS_ANDROID) {
       let isLowDevice = jsb.reflection.callStaticMethod("com/tencent/abcmouse/cocosbridge/CommonBridge", "isLowMachine", "()Z");
       return isLowDevice;
   } else if (cc.sys.isBrowser) {
       return false;
   }
    ```

    通过ABCBinding 抹平差异，一行代码搞定，只需要在Native实现该方法。

    ```typescript
   //ABCBinding 
   Binding.callNativeMethod('isLowDevice').then(({isLowDevice}) => {
        //todo
     console.log(isLowDevice);
   })
    ```

2. **异步数据返回**：

   原生调用并不支持异步数据返回，对于需要异步操作的接口数据返回实现比较繁琐，ABCBinding可通过Promise 的then函数接收异步数据的返回。

   ```typescript
   //ABCBinding 
   Binding.callNativeMethod('downloadFile', {url: 'https://xxx.jpeg'}).then((result) => {
       this.label.string = `下载成功:path=${result.path}`;
   }).catch((error) => {
       this.label.string =error.msg;
   });
   ```

3. **可配置调用超时时间,可配置中间进度回调处理**

   ```typescript
   Binding.withOptions({
               timeout: 120,
               onProgress: (progress) => {
                   cc.log(`${JSON.stringify(progress)}`); //从progress中获取进度信息
               }
           }).callNativeMethod('downloadFile').then((result) => {
     				//todo
   				})
   ```

4. **抛弃固定参数名称，支持动态参数**

   原生的调用的不便之处在于我们必须在Cocos端定义固定的参数，包名，返回类型，当任意参数变更就会导致调用异常或者闪退。ABCBinding 通过传入JS Object对象作为参数，可拓展参数。避免冗长包名和参数名人工配置（极易出错)。

   ```typescript
   //原生
   jsb.reflection.callStaticMethod("com/tencent/abcmouse/report/DcReportTime", "reportLoading", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V",
                   batchReport, startApp, os, timecost , modelType, resourceType , activityType);
   ```

   ```typescript
   //ABCBinding 
   Binding.callNativeMethod('reportLoading', {batchReport: batchReport,startApp:startApp,os:os,timecost: timecost,modelType:modelType,resourceType:resourceType,activityType+''}).then(() => {
       this.label.string = `上报成功:path=${result.path}`;
   }) 
   ```

5. **不需要管理线程切换**

   Android调用Cocos方法是需要手动切换到Cocos的线程执行。ABCBinding 可自动维护调用线程。

   ```java
       @ABCBinding("getHardwareInfo")
       public static void getHardwareInfo(Transfer transfer) {
           TransferData data = new TransferData();
           data.put("brand", Build.BRAND);
           data.put("model", Build.MODEL);
           data.put("OsVersion", Build.VERSION.RELEASE);
           data.put("SdkVersion", Build.VERSION.SDK);
           transfer.onSuccess(data);
       }
   ```

   

## 使用样例

#### Android 引入

1. 添加gradle依赖

```groovy
    implementation 'com.tencent.abckit.binding:ABCBindingProcessor:0.0.5'
    implementation 'com.tencent.abckit.binding:ABCBinding:0.0.5-SNAPSHOT'
```

2. 配置打包选项

```groovy
    android{
      ....
        javaCompileOptions {
            annotationProcessorOptions {
                includeCompileClasspath true
            }
        }
        packagingOptions {
            exclude 'META-INF/proguard/androidx-annotations.pro'
        }
    }
```

#### iOS引入

1. 添加到工程；

```ruby
source 'http://git.code.oa.com/abcmouse/client/cocoapods/ABCCocoapodsRepos.git'
pod 'ABCBinding'
```

2. 实现代理协议`ABCBindingCocosEvalStringProtocol`,具体实现参加`ABCBindingCocosEvalStringProtocol.h`

#### 引入JS到Cocos工程

```typescript
import { Binding } from '../ABCKit-lib/abc';
```

### 编写第一个ABCBinding 的接口

例如，我们定义一个获取手机信息接口 我们约定名称 `getHardwareInfo` 无传入参数，返回手机型号，OS版本。在Java端实现该接口

1. 在Android 任意类中编写实现，只需要添加注解@ABCBinding

   ```java
   @ABCBinding("getHardwareInfo")
   public static void getHardWareInfo(Transfer transfer) {
       TransferData data = new TransferData();
       data.put("brand", Build.BRAND);
       data.put("model", Build.MODEL);
       data.put("OsVersion", Build.VERSION.RELEASE);
       transfer.onSuccess(data);
   }
   ```

2. 在 iOS 任意.m文件中编写实现，只需要实现`@ABCBinding(FUNCTION)和@end`即可，函数名称编译器会帮助实现；

   ![ABCBinding_iOS_Code](https://raw.githubusercontent.com/lijianfeigeek/PictureBed/main/uPic/ABCBinding_iOS_Code.gif)

   ```objc
   @ABCBinding(getHardwareInfo)
   + (void)getHardwareInfo:(NSDictionary *)JSParam Callback:(ABCBindingCallBack *)callback {
       callback.onSuccess({
         @"brand":@"brand",
         @"model":@"model",
         @"OsVersion":@"OsVersion"
       });
   }
   @end
   ```

3. 在TS中调用

   ```typescript
   import { Binding } from '../ABCKit-lib/abc';
   Binding.callNativeMethod('getHardwareInfo').then((hardwareInfo) => {
     //get hardwareInfo 
        console.log(hardwareInfo.brand);
        console.log(hardwareInfo.model);
        console.log(hardwareInfo.OsVersion);
   })
   ```

这样就能够获取到Native的数据了。

**异常处理**

若Native方法发生异常，或者调用发生超时（默认60s），则事件应当被捕获，并做相应逻辑处理

```typescript
Binding.callNativeMethod('getHardwareInfo',{timeout:10}).then((hardwareInfo) => {
  //todo
}).catch(error){
  //error.code
  //error.msg
}
```

error.code > 0 为业务侧错误码，内置error.code<0对应错误码为如下

| error.code | 描述                                           |
| ---------- | ---------------------------------------------- |
| -1         | 调用的方法没有找到。即native平台没有找到该实现 |
| -2         | 传入参数不能被解析                             |
| -3         | native回调超时                                 |

 ### 编写一个异步回调的接口

例如，我们要通过Native下载一个文件，并在Cocos展示层下载进度，那该如何实现呢？加入方法名downloadFile

1. Native中实现downloadFile

   ```java
   @ABCBinding("downloadFile")
   public static void downloadFile(final Transfer transfer) {
       String url = transfer.get("url", "");
       String name = System.currentTimeMillis() + ".dat";
       String filePath = getContext().getCacheDir().getPath() + File.separator + name;
       PRDownloader.download(url, filePath, name).build()//以PRDownloader下载为例，实际可以换成自身的下载类
               .setOnProgressListener(new OnProgressListener() {
                   @Override
                   public void onProgress(Progress progress) {
                       transfer.onProgress(new TransferData("current", (progress.currentBytes*100 / progress.totalBytes)+"%"));
                   }
               }).start(new OnDownloadListener() {
           @Override
           public void onDownloadComplete() {
               TransferData data = new TransferData();
               data.put("path", filePath);
               transfer.onSuccess(data);
           }
   
           @Override
           public void onError(Error error) {
               boolean isConnectionErr=error.isConnectionError();
               if(error.isConnectionError()){
                   transfer.onFailure("网络链接异常，请打开网络");
                   return;
               }
               if(error.isServerError()){
                   transfer.onFailure("服务器故障");
                   return;
               }
               transfer.onFailure("返回异常，错误码:" + error.getResponseCode());
           }
       });
   }
   ```

   ```objc
   @ABCBinding(downloadFile)
   + (void)downloadFile:(NSDictionary *)JSParam Callback:(ABCBindingCallBack *)callback {
       NSLog(@"downloadFile: %@",JSParam);
       
       NSString *url = JSParam[@"url"];
       
       ABCCoreDownloadReceipt *receipt = [[ABCCoreDownloader sharedDownloader] downloadReceiptForURLString:url];
       
       NSString *temp = NSTemporaryDirectory();
       NSString *tempFolderPath = [temp stringByAppendingPathComponent:@"ABCKitTemp"];
       NSString *path = [tempFolderPath stringByAppendingPathComponent:url.lastPathComponent];
       
       receipt.customFilePathBlock = ^NSString *_Nullable(ABCCoreDownloadReceipt *_Nullable receipt) {
           return path;
       };
       
       __weak typeof(receipt) weakReceipt = receipt;
       [[ABCCoreDownloader sharedDownloader] downloadDataWithURL:[NSURL URLWithString:url] queuePriority:NSOperationQueuePriorityHigh progress:^(NSInteger receivedSize, NSInteger expectedSize, NSInteger speed, NSURL * _Nullable targetURL) {
           __strong typeof(weakReceipt) strongReceipt = weakReceipt;
           NSString* bytes = [NSString stringWithFormat:@"%0.1fmb/%0.1fmb", receivedSize/1024.0/1024,expectedSize/1024.0/1024];
           CGFloat progress = (receivedSize/1024.0/1024) / (expectedSize/1024.0/1024);
           NSString * nspeed = [NSString stringWithFormat:@"%@/s", strongReceipt.speed ?: @"0"];
           NSLog(@" bytes = %@",bytes);
           NSLog(@" progress = %@",@(progress));
           NSLog(@" speed = %@",nspeed);
           callback.onProgress(@{@"current":@(progress)});
       } completed:^(ABCCoreDownloadReceipt * _Nullable receipt, NSError * _Nullable error, BOOL finished) {
           if(finished){
               callback.onSuccess(@{@"path":receipt.filePath});
           }else{
               if(error){
                   callback.onFailure(error.code,[ABCBindingUtil jsonStringWithDict:error.userInfo]);
               }
           }
       }];
   }
   @end
   ```

2. TS中设置进度监控监听

   ```typescript
   Binding.withOptions({
       timeout: 120,
       onProgress: (progress) => {
       		let current=progress.current;
           this.label.string = `progress:${current}`;
       }
   }).callNativeMethod('downloadFile', {url: 'https://xxxx.jpg'}).then((result) => {
       this.label.string = `下载成功:path=${result.path}`;
   }).catch((error) => {
       if (error) {
           this.label.string = error.msg;
       }
   });
   ```

这样，cocos层就能获取到相应的数据啦。

