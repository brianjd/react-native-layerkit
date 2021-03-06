//
//  LayerQuery.m
//  layerPod
//
//  Created by Joseph Johnson on 7/29/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "LayerQuery.h"

@implementation LayerQuery
-(NSOrderedSet*)fetchConvosForClient:(LYRClient*)client limit:(int)limit offset:(int)offset error:(NSError*)err
{
  // Fetches all LYRConversation objects
  LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
  if(limit>0)
    query.limit=limit;
  query.offset=offset;
  
  NSError *error = nil;
  NSOrderedSet *conversations = [client executeQuery:query error:&error];
  if (conversations) {
    NSLog(@"%tu conversations", conversations.count);
    return conversations;
  } else {
    NSLog(@"Query failed with error %@", error);
    err = error;
    return nil;
  }
}

-(NSInteger*)fetchMessagesCount:(NSString*)userID client:(LYRClient*)client error:(NSError*)err
{
  // Fetches all unread messages
  LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
  query.predicate = [LYRPredicate predicateWithProperty:@"isUnread" predicateOperator:LYRPredicateOperatorIsEqualTo value:@(YES)];
  //LYRPredicate *userPredicate = [LYRPredicate predicateWithProperty:@"sender.userID" operator:LYRPredicateOperatorIsNotEqualTo value:self.client.authenticatedUserID];
  //query.predicate = [LYRCompoundPredicate compoundPredicateWithType:LYRCompoundPredicateTypeAnd subpredicates:@[conversationPredicate, unreadPredicate, userPredicate]];
  //query.predicate = [LYRPredicate predicateWithProperty:@"sender.userID" operator:LYRPredicateOperatorIsNotEqualTo value:userID];
  NSError *error = nil;
  NSInteger *count = [client countForQuery:query error:&error];
  if (!error) {
    NSLog(@"%tu unread messages in conversation", count);
    return count;
  } else {
      NSLog(@"Query failed with error %@", error);
      err = error;
      return nil;
  }
}

-(LYRConversation*)fetchConvoWithId:(NSString*)convoID client:(LYRClient*)client error:(NSError*)error
{
  // Fetches conversation with a specific identifier
  LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRConversation class]];
  query.predicate = [LYRPredicate predicateWithProperty:@"identifier" predicateOperator:LYRPredicateOperatorIsEqualTo value:convoID];
  LYRConversation *conversation = [[client executeQuery:query error:&error] firstObject];
  
  return conversation;
}

-(NSOrderedSet*)fetchMessagesForConvoId:(NSString*)convoID client:(LYRClient*)client limit:(int)limit offset:(int)offset error:(NSError*)error
{
  LYRConversation *thisConvo = [self fetchConvoWithId:convoID client:client error:error];
  
  if(error){
    return nil;
  }
  
  // Fetches all messages for a given conversation
  LYRQuery *query = [LYRQuery queryWithQueryableClass:[LYRMessage class]];
  query.predicate = [LYRPredicate predicateWithProperty:@"conversation" predicateOperator:LYRPredicateOperatorIsEqualTo value:thisConvo];
  query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
  if(limit>0)
    query.limit=limit;
  query.offset=offset;
  
  NSOrderedSet *messages = [client executeQuery:query error:&error];
  if (messages) {
    NSLog(@"%tu messages in conversation", messages.count);
    return messages;
  } else {
    NSLog(@"Query failed with error %@", error);
    return nil;
  }
}
@end
