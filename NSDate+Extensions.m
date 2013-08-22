//
//  NSDate+Extensions.m
//

#import "NSDate+Extensions.h"

@implementation NSDate (Extensions)

#pragma mark -
#pragma mark Instance Methods

- (NSDate *)getLocalDate
{
	NSTimeInterval timezoneOffset;
    
    timezoneOffset = [[NSTimeZone localTimeZone] secondsFromGMT];
	return [self dateByAddingTimeInterval:timezoneOffset];
}

- (NSString *)getFormattedDateString
{
	NSDateFormatter *dateFormatter;
	NSString *dateString;

    dateFormatter = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	
	dateString = [dateFormatter stringFromDate:self];
    
	return dateString;
}

- (NSString *)getNiceFormattedDateString
{
    NSDateFormatter *dateFormatter;
    NSString *dateString;
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, MMM d 'at' h:mm a")];
    
	dateString = [dateFormatter stringFromDate:self];
    
	return dateString;
}

#pragma mark -
#pragma mark Class Methods

+ (NSDate *)getDateFromIso:(NSString *)isoDateString
{
    NSDateFormatter *formatter;
    NSDate *date;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    date = [formatter dateFromString:isoDateString];
    
    return date;
}

+ (NSDate *)getDateFromJSON:(NSString *)dateString
{
    // Expect date in this format "/Date(1268123281843)/"
    //
    int startPos = [dateString rangeOfString:@"("].location+1;
    int endPos = [dateString rangeOfString:@")"].location;
    
    NSRange range = NSMakeRange(startPos, endPos - startPos);
    unsigned long long milliseconds = [[dateString substringWithRange:range] longLongValue];
    
    NSTimeInterval interval = milliseconds / 1000;
    
    return [NSDate dateWithTimeIntervalSince1970:interval];
}

+ (int)getUtcOffset
{
    int utcOffset;
    
    utcOffset = [[NSTimeZone localTimeZone] secondsFromGMT] / 60;
    
    return utcOffset;
}

+ (NSDate *)mfDateFromDotNetJSONString:(NSString *)string
{
    static NSRegularExpression *dateRegEx = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(
                  &onceToken,
                  ^{
                      dateRegEx = [[NSRegularExpression alloc] initWithPattern:@"^\\/date\\((-?\\d++)(?:([+-])(\\d{2})(\\d{2}))?\\)\\/$" options:NSRegularExpressionCaseInsensitive error:nil];
                  });
    
    NSTextCheckingResult *regexResult = [dateRegEx firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    
    if (regexResult)
    {
        // milliseconds
        NSTimeInterval seconds = [[string substringWithRange:[regexResult rangeAtIndex:1]] doubleValue] / 1000.0;
        
        // timezone offset
        if ([regexResult rangeAtIndex:2].location != NSNotFound)
        {
            NSString *sign = [string substringWithRange:[regexResult rangeAtIndex:2]];
            // hours
            seconds += [[NSString stringWithFormat:@"%@%@", sign, [string substringWithRange:[regexResult rangeAtIndex:3]]] doubleValue] * 60.0 * 60.0;
            // minutes
            seconds += [[NSString stringWithFormat:@"%@%@", sign, [string substringWithRange:[regexResult rangeAtIndex:4]]] doubleValue] * 60.0;
        }
        
        return [NSDate dateWithTimeIntervalSince1970:seconds];
    }
    
    return nil;
}

@end
