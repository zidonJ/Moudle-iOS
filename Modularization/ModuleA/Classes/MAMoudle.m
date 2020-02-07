//
//  MAMoudle.m
//  AFNetworking
//
//  Created by zidonj on 2019/2/22.
//

#import "MAMoudle.h"
#import "BeeHive.h"

@BeeHiveMod(MAMoudle)

@interface MAMoudle() <BHModuleProtocol>

@end

@implementation MAMoudle

- (id)init {
    if (self = [super init]) {
        NSLog(@"MAMoudle init");
    }
    return self;
}

- (NSUInteger)moduleLevel {
    return 0;
}

- (void)modSetUp:(BHContext *)context {
    NSLog(@"MAMoudle setup");
}

- (void)modOpenURL:(BHContext *)context {
    NSLog(@"opneURL:%@",context);
}

@end
