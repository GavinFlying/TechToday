//
//  RNCachingURLProtocol.m
//
//  Created by Robert Napier on 1/10/12.
//  Copyright (c) 2012 Rob Napier.
//
//  This code is licensed under the MIT License:
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#import "RNCachingURLProtocol.h"
#import "CLFReachability.h"
#import <CommonCrypto/CommonDigest.h>
#import "MBProgressHUD+MJ.h"

#define WORKAROUND_MUTABLE_COPY_LEAK 1

#if WORKAROUND_MUTABLE_COPY_LEAK
// required to workaround http://openradar.appspot.com/11596316
@interface NSURLRequest(MutableCopyWorkaround)

- (id) mutableCopyWorkaround;

@end
#endif

@interface RNCachedData : NSObject <NSCoding>
@property (nonatomic, readwrite, strong) NSData *data;
@property (nonatomic, readwrite, strong) NSURLResponse *response;
@property (nonatomic, readwrite, strong) NSURLRequest *redirectRequest;
@end

static NSString *RNCachingURLHeader = @"X-RNCache";

@interface RNCachingURLProtocol () // <NSURLConnectionDelegate, NSURLConnectionDataDelegate> iOS5-only
@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSURLResponse *response;
- (void)appendData:(NSData *)newData;
@end

static NSObject *RNCachingSupportedSchemesMonitor;
static NSSet *RNCachingSupportedSchemes;

@implementation RNCachingURLProtocol

@synthesize connection = connection_;
@synthesize data = data_;
@synthesize response = response_;

+ (void)initialize {
  if (self == [RNCachingURLProtocol class]) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      RNCachingSupportedSchemesMonitor = [NSObject new];
    });
        
    [self setSupportedSchemes:[NSSet setWithObject:@"http"]];
  }
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
  // only handle http requests we haven't marked with our header.
  if ([[self supportedSchemes] containsObject:[[request URL] scheme]] &&
      ([request valueForHTTPHeaderField:RNCachingURLHeader] == nil)) {
    return YES;
  }
  return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
  return request;
}

- (NSString *)cachePathForRequest:(NSURLRequest *)aRequest {
  // This stores in the Caches directory, which can be deleted when space is low, but we only use it for offline access
  NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//  NSString *fileName = [[[aRequest URL] absoluteString] sha1];
    
    NSString *fullCachesPath = [cachesPath stringByAppendingPathComponent:@"WebCaches"];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    [fileMgr createDirectoryAtPath:fullCachesPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    const char *str = [[[aRequest URL] absoluteString] UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *fileName = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
  return [fullCachesPath stringByAppendingPathComponent:fileName];
}

// customized by Gavin Cai
- (void)startLoading {
    // 不处理以下三种 request
    BOOL getArticleRequest = [self.request.URL.absoluteString containsString:@"getArticle"];
    BOOL getMoreArticleRequest = [self.request.URL.absoluteString containsString:@"getMoreArticle"];
    BOOL shareSDKRequest = [self.request.URL.absoluteString containsString:@"mob.com"];
    BOOL shareSDKRequest2 = [self.request.URL.absoluteString containsString:@"sharesdk.cn"];
    RNCachedData *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cachePathForRequest:[self request]]];
    if (!cache || getArticleRequest || getMoreArticleRequest || shareSDKRequest || shareSDKRequest2) {
        NSMutableURLRequest *connectionRequest =
#if WORKAROUND_MUTABLE_COPY_LEAK
        [[self request] mutableCopyWorkaround];
#else
        [[self request] mutableCopy];
#endif
    // we need to mark this request with our header so we know not to handle it in +[NSURLProtocol canInitWithRequest:].
        [connectionRequest setValue:@"" forHTTPHeaderField:RNCachingURLHeader];

        NSURLConnection *connection = [NSURLConnection connectionWithRequest:connectionRequest
                                                                delegate:self];
        [self setConnection:connection];
    } else {
        NSData *data = [cache data];
        NSURLResponse *response = [cache response];
        NSURLRequest *redirectRequest = [cache redirectRequest];
      if (redirectRequest) {
          [[self client] URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
      } else {
          [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed]; // we handle caching ourselves.
          [[self client] URLProtocol:self didLoadData:data];
          [[self client] URLProtocolDidFinishLoading:self];
      }
    }
}

- (void)stopLoading {
  [[self connection] cancel];
}

// NSURLConnection delegates (generally we pass these on to our client)

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
// Thanks to Nick Dowell https://gist.github.com/1885821
  if (response != nil) {
      NSMutableURLRequest *redirectableRequest =
#if WORKAROUND_MUTABLE_COPY_LEAK
      [request mutableCopyWorkaround];
#else
      [request mutableCopy];
#endif
    // We need to remove our header so we know to handle this request and cache it.
    // There are 3 requests in flight: the outside request, which we handled, the internal request,
    // which we marked with our header, and the redirectableRequest, which we're modifying here.
    // The redirectable request will cause a new outside request from the NSURLProtocolClient, which 
    // must not be marked with our header.
    
    [redirectableRequest setValue:nil forHTTPHeaderField:RNCachingURLHeader];
    NSString *cachePath = [self cachePathForRequest:[self request]];
    RNCachedData *cache = [RNCachedData new];
    [cache setResponse:response];
    [cache setData:[self data]];
    [cache setRedirectRequest:redirectableRequest];
    if (cache != nil) [NSKeyedArchiver archiveRootObject:cache toFile:cachePath];
    [[self client] URLProtocol:self wasRedirectedToRequest:redirectableRequest redirectResponse:response];
    return redirectableRequest;
  } else {
    return request;
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [[self client] URLProtocol:self didLoadData:data];
  [self appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  [[self client] URLProtocol:self didFailWithError:error];
  [self setConnection:nil];
  [self setData:nil];
  [self setResponse:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  [self setResponse:response];
  [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];  // We cache ourselves.
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  [[self client] URLProtocolDidFinishLoading:self];

  NSString *cachePath = [self cachePathForRequest:[self request]];
  RNCachedData *cache = [RNCachedData new];
  [cache setResponse:[self response]];
  [cache setData:[self data]];
  [NSKeyedArchiver archiveRootObject:cache toFile:cachePath];

  [self setConnection:nil];
  [self setData:nil];
  [self setResponse:nil];
}

//- (BOOL) useCache {
////    BOOL reachable = (BOOL) [[Reachability reachabilityWithHostName:[[[self request] URL] host]] currentReachabilityStatus] != NotReachable;
//    
//    // add by Gavin Cai
////    RNCachedData *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cachePathForRequest:[self request]]];
////    if (cache) {
////        return YES;
////    } else {
////        return NO;
////    }
//    
////    return !reachable;
//}

- (void)appendData:(NSData *)newData {
  if ([self data] == nil) {
    [self setData:[newData mutableCopy]];
  }
  else {
    [[self data] appendData:newData];
  }
}

+ (NSSet *)supportedSchemes {
  NSSet *supportedSchemes;
  @synchronized(RNCachingSupportedSchemesMonitor) {
    supportedSchemes = RNCachingSupportedSchemes;
  }
  return supportedSchemes;
}

+ (void)setSupportedSchemes:(NSSet *)supportedSchemes {
  @synchronized(RNCachingSupportedSchemesMonitor)
  {
    RNCachingSupportedSchemes = supportedSchemes;
  }
}

@end

static NSString *const kDataKey = @"data";
static NSString *const kResponseKey = @"response";
static NSString *const kRedirectRequestKey = @"redirectRequest";

@implementation RNCachedData
@synthesize data = data_;
@synthesize response = response_;
@synthesize redirectRequest = redirectRequest_;

- (void)encodeWithCoder:(NSCoder *)aCoder {
  [aCoder encodeObject:[self data] forKey:kDataKey];
  [aCoder encodeObject:[self response] forKey:kResponseKey];
  [aCoder encodeObject:[self redirectRequest] forKey:kRedirectRequestKey];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super init];
  if (self != nil) {
    [self setData:[aDecoder decodeObjectForKey:kDataKey]];
    [self setResponse:[aDecoder decodeObjectForKey:kResponseKey]];
    [self setRedirectRequest:[aDecoder decodeObjectForKey:kRedirectRequestKey]];
  }

  return self;
}

@end

#if WORKAROUND_MUTABLE_COPY_LEAK
@implementation NSURLRequest(MutableCopyWorkaround)

- (id) mutableCopyWorkaround {
    NSMutableURLRequest *mutableURLRequest = [[NSMutableURLRequest alloc] initWithURL:[self URL]
                                                                          cachePolicy:[self cachePolicy]
                                                                      timeoutInterval:20.0f];
    [mutableURLRequest setAllHTTPHeaderFields:[self allHTTPHeaderFields]];
    if ([self HTTPBodyStream]) {
        [mutableURLRequest setHTTPBodyStream:[self HTTPBodyStream]];
    } else {
        [mutableURLRequest setHTTPBody:[self HTTPBody]];
    }
    [mutableURLRequest setHTTPMethod:[self HTTPMethod]];
    
    return mutableURLRequest;
}

@end
#endif
