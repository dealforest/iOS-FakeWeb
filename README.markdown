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

※ If you use other HTTP Libaray depends on __"NSURLConnection"__, this is to solve it by using this__"NSURLConnection+FakeWeb.h"__.

## Usage

simple case:

```objective-c
#import "ASIHTTPRequest+FakeWeb.h"
[FakeWeb registerUri:@"http://google.com" method:@"GET" body:@"hoge" staus:200];
ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]];
[request startSynchronous];
NSLog(@"%@", [request responseString]);
// => hoge
```
Other uses will see the test case:
__FakeWebTests/Spec/FakeWebAHIHTTPRequestSpec.m__ or __FakeWebTests/Spec/FakeWebNSURLConnectionSpec.m__

## License
MIT, the license agreement found in __License.txt__.


[1]: https://github.com/chrisk/fakeweb
