/**
 @author Sergey Mamontov
 @since 4.0
 @copyright © 2009-2016 PubNub, Inc.
 */
#import "PNSubscribeStatus.h"


NS_ASSUME_NONNULL_BEGIN

#pragma mark Private interface declaration

@interface PNSubscriberData ()


#pragma mark - Properties

/**
 @brief Stores reference on \b PubNub server region identifier (which generated \c timetoken value).
 
 @since 4.3.0
 */
@property (nonatomic, readonly) NSNumber *region;

#pragma mark -


@end


#pragma mark Private interface declaration

@interface PNSubscribeStatus ()

@property (nonatomic, strong) PNSubscriberData *data;

#pragma mark -


@end

NS_ASSUME_NONNULL_END
