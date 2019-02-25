//
//  MARequest.m
//  AFNetworking
//
//  Created by zidonj on 2019/2/14.
//

#import "MARequest.h"

@implementation MARequest

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeHTTP;
}

- (YTKResponseSerializerType)responseSerializerType {
    return YTKResponseSerializerTypeJSON;
}

- (id)requestArgument {
    return @{};
}

- (NSTimeInterval)requestTimeoutInterval {
    return 10.f;
}

- (NSDictionary *)reformParams:(NSDictionary *)params {
    return params;
}

- (void)start {
    [super start];
}

- (void)stop {
    [super stop];
}

@end
