import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/create.post.controller.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:provider/provider.dart';


class PostPollBuilderWidget extends StatelessWidget {
  const PostPollBuilderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final createPostController = Provider.of<CreatePostController>(context, listen: true);
    return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.78,
            crossAxisSpacing: 13,mainAxisSpacing: 13),
        itemCount: createPostController.pollTiles.length,
        itemBuilder: (context,index){
          return createPostController.pollTiles[index];
        });
  }
}


class PostTile extends StatelessWidget {
 final TextEditingController controller;
 final String hintText;
  const PostTile({required this.controller,required this.hintText,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.pollTileColor,
        borderRadius: BorderRadius.circular(4).r,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8,right: 8,).r,
        child: TextFormField(keyboardType: TextInputType.text,
           controller: controller,
           maxLength: 15,
           cursorColor: AppColors.black,textAlign: TextAlign.center,
           style: GayaTypography.caption4Medium.copyWith(color: AppColors.black),
           decoration:  InputDecoration(
             contentPadding: const EdgeInsets.only(top: 10).r,
             border: InputBorder.none,
             hintText: hintText,

             hintStyle: GayaTypography.caption4Medium.copyWith(color: AppColors.secondary)
           ),

    ),
      ),
    );
  }
}
