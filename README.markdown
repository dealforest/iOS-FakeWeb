# FakeWeb
Simple HTTP request mocking/interception for testing module.

Inspired by [chrisk's fakeweb][1].

## Requirements

* Xcode 4.x
* LLVM compiler recommended.
* only ARC

## installation

* get iOS-FakeWeb project.
* some include and implemantation file into your project.

Required files on to use this library

       FakeWeb.h
       FakeWeb.m
       FakeWebResponder.h
       FakeWebResponder.m
       FakeWeb+Private.h

If you use  HTTP Library __"ASIHTTPRequest"__, add this file.

       ASIHTTPRequest+FakeWeb.h
       ASIHTTPRequest+FakeWeb.m

If you use  HTTP Library __"NSURLConnection"__, add this file.

       NSURLConnection+FakeWeb.h
       NSURLConnection+FakeWeb.m

※ If you use other HTTP Libaray depends on __"NSURLConnection"__, this is to solve it by using this __"NSURLConnection+FakeWeb.h"__.

### Using CocoaPods

Write to Podfile as follows. default is NSURLConnection.
```
pod 'iOS-FakeWeb'
```

If you want to use ASIHTTPRequest, write to Podfile as follows.
```
pod 'iOS-FakeWeb/ASIHTTPRequest'
```

## Usage

simple case:

```objective-c
#import "FakeWeb.h"

NSString *urlString = @"http://google.com";
[FakeWeb registerUri:urlString method:@"GET" body:@"hoge" staus:200];
ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
[request startSynchronous];
NSLog(@"%@", [request responseString]);
// => hoge
```
Other uses will see the test case:
__FakeWebTests/Spec/FakeWebAHIHTTPRequestSpec.m__ or __FakeWebTests/Spec/FakeWebNSURLConnectionSpec.m__

## Contact

### Creators

[Toshihiro Morimoto](https://github.com/dealforest)
[@dealforest](https://twitter.com/dealforest)

## Changes
The details are described in [__CHANGES__](https://github.com/dealforest/iOS-FakeWeb/blob/master/CHANGES).

## License
MIT, the license agreement found in __License.txt__.

[1]: https://github.com/chrisk/fakeweb
