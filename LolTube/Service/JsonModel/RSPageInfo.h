#import <Foundation/Foundation.h>

#import <JSONModel/JSONModel.h>

@interface RSPageInfo : JSONModel

@property(nonatomic, copy) NSString *totalResults;
@property(nonatomic, copy) NSString *resultsPerPage;

@end
