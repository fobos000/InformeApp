//
//  NSManagedObject+JSONMapping.m
//  ViewQ
//
//  Created by Ostap Horbach on 2/15/13.
//  Copyright (c) 2013 Ostap Horbach. All rights reserved.
//

#import "NSManagedObject+JSONMapping.h"
#import "NPDateParser.h"

// 2014-04-01T17:34:00.000+03:00
NSString *const NPDateFormat = @"yyyy-MM-dd'T'HH:mm:ss'.'SSSZZZZZ";

@implementation NSManagedObject (JSONMapping)

- (void)setAttributesWithDictionary:(NSDictionary *)keyedValues
{
    NSDictionary *attributes = [[self entity] attributesByName];
    for (NSString *attribute in attributes) {
        NSString *attributeKeypath = [[self class] keyForAttributeName:attribute];
        if (nil == attributeKeypath) {
            attributeKeypath = attribute;
        }
        id value = [keyedValues valueForKeyPath:attributeKeypath];
        if (value == nil || [value isKindOfClass:[NSNull class]]) {
            continue;
        }
        NSAttributeType attributeType = [[attributes objectForKey:attribute] attributeType];
        if ((attributeType == NSStringAttributeType) && ([value isKindOfClass:[NSNumber class]])) {
            value = [value stringValue];
        } else if (((attributeType == NSInteger16AttributeType) || (attributeType == NSInteger32AttributeType) || (attributeType == NSInteger64AttributeType)) && ([value isKindOfClass:[NSString class]])) {
            value = [NSNumber numberWithInteger:[value integerValue]];
        } else if ((attributeType == NSBooleanAttributeType) && ([value isKindOfClass:[NSString class]])) {
            value = [NSNumber numberWithBool:[value boolValue]];
        } else if ((attributeType == NSFloatAttributeType) &&  ([value isKindOfClass:[NSString class]])) {
            value = [NSNumber numberWithDouble:[value doubleValue]];
        } else if ((attributeType == NSDateAttributeType) && ([value isKindOfClass:[NSString class]])) {
            value = [NPDateParser dateFromString:value withFormat:NPDateFormat];
        }
        [self setValue:value forKey:attribute];
    }
}

+ (NSString *)keyForAttributeName:(NSString *)attributeName
{
    return nil;
}

@end
