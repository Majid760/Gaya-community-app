import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/create.post.controller.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/postType.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/create_post/models/post_poll_model.dart';
import 'package:gaya/view/create_post/widgets/post_poll_widgets/flutter_poll.dart';
import 'package:gaya/view/feed/controller/base/base_feed_impl.dart';
import 'package:provider/provider.dart';

class HomeFeedPollWidget extends StatefulWidget {
  Post postModel;
  final PostWithPoll poll;
  final String documentId;
  final Color color;

  HomeFeedPollWidget({required this.postModel, required this.poll, required this.documentId, required this.color, Key? key})
      : super(key: key);

  @override
  State<HomeFeedPollWidget> createState() => _HomeFeedPollWidgetState();
}

class _HomeFeedPollWidgetState extends State<HomeFeedPollWidget> {
  CreatePostController? createPostController;

  @override
  Widget build(BuildContext context) {
    createPostController = Provider.of<CreatePostController>(context, listen: true);
    return Container(
        margin: EdgeInsets.only(bottom: 20.r),
        child: FlutterPolls(
          userVotedOptionId: widget.postModel.postPollModel?.pollOptionId ?? 0,
          hasVoted: widget.postModel.postPollModel?.userId == UserModel.to.uId ? true : false,
          pollId: widget.poll.id.toString(),
          onVoted: (PollOption pollOption, int newTotalVotes, int index) async {
            widget.poll.options![index].counts++;
            PostPollModel poll = PostPollModel(userId: UserModel.to.uId!, pollOptionId: pollOption.id!);
            widget.postModel.postPollModel = poll;
            FeedControllerUtils.updatePostLocally(widget.postModel);
            await Future.delayed(const Duration(milliseconds: 100));

            createPostController!.updatePollDataInFirestore(docId: widget.documentId, poll: widget.poll, pollOptionId: pollOption.id!);

            return true;
          },
          pollTitle: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.poll.question ?? "",
              style: GayaTypography.subtitleRegular,
            ),
          ),
          votedProgressColor: widget.color,
          pollOptions: List<PollOption>.from(
            widget.poll.options!.map(
              (option) {
                var a = PollOption(
                  id: option.id,
                  title: Text(
                    option.title,

                    style: GayaTypography.caption4Medium.copyWith(color: AppColors.black),
                  ),
                  counts: option.counts,
                );
                return a;
              },
            ),
          ),
        )
        );
  }
}
