import 'package:flutter_test/flutter_test.dart';
import 'package:gaya/model/reaction_model.dart';

///
/// Test cases for checking the reaction count and check if reaction are mixed or not
///

void main() {
  // Test Case 1
  PostReactionDataModel model1 = PostReactionDataModel(like: 1, inLove: 0, sad: 0, angry: 0, surprized: 0, funny: 0);
  // Test Case 2
  PostReactionDataModel model2 = PostReactionDataModel(like: 0, inLove: 2, sad: 0, angry: 0, surprized: 0, funny: 1);
  // Test Case 3
  PostReactionDataModel model3 = PostReactionDataModel(like: 0, inLove: 0, sad: 3, angry: 0, surprized: 0, funny: 0);
  // Test Case 4
  PostReactionDataModel model4 = PostReactionDataModel(like: 0, inLove: 1, sad: 2, angry: 4, surprized: 0, funny: 3);
  // Test Case 5
  PostReactionDataModel model5 = PostReactionDataModel(like: 0, inLove: 0, sad: 0, angry: 0, surprized: 0, funny: 0);
  // Test Case 6
  PostReactionDataModel model6 = PostReactionDataModel(like: 5, inLove: 0, sad: 0, angry: 0, surprized: 2, funny: 0);
  // Test Case 7
  PostReactionDataModel model7 = PostReactionDataModel(like: 0, inLove: 1, sad: 0, angry: 0, surprized: 1, funny: 1);
  // Test Case 8
  PostReactionDataModel model8 = PostReactionDataModel(like: 0, inLove: 0, sad: 0, angry: 3, surprized: 0, funny: 0);
  // Test Case 9
  PostReactionDataModel model9 = PostReactionDataModel(like: 1, inLove: 1, sad: 1, angry: 1, surprized: 1, funny: 1);
  // Test Case 10
  PostReactionDataModel model10 = PostReactionDataModel(like: 0, inLove: 0, sad: 0, angry: 0, surprized: 0, funny: 5);

  test('Test 1', () => expect(model1.hasMixedReactions, false));

  test('Test 2', () => expect(model2.hasMixedReactions, true));

  test('Test 3', () => expect(model3.hasMixedReactions, false));

  test('Test 4', () => expect(model4.hasMixedReactions, true));

  test('Test 5', () => expect(model5.hasMixedReactions, false));

  test('Test 6', () => expect(model6.hasMixedReactions, true));

  test('Test 7', () => expect(model7.hasMixedReactions, true));

  test('Test 8', () => expect(model8.hasMixedReactions, false));

  test('Test 9', () => expect(model9.hasMixedReactions, true));

  test('Test 10', () => expect(model10.hasMixedReactions, false));
}
