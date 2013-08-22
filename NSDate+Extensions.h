//
//  NSDate+Extensions.h
//

#import <Foundation/Foundation.h>

@interface NSDate (Extensions)

- (NSDate *)getLocalDate;
- (NSString *)getFormattedDateString;
- (NSString *)getNiceFormattedDateString;

+ (NSDate *)getDateFromIso:(NSString *)isoDateString;
+ (NSDate *)getDateFromJSON:(NSString *)dateString;
+ (int)getUtcOffset;
+ (NSDate *)mfDateFromDotNetJSONString:(NSString *)string;

@end
