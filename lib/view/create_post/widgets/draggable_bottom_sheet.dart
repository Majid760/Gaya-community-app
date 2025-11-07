import 'package:flutter/material.dart';
import 'package:gaya/view/create_post/controller/new_post_creation_controller.dart';
import 'package:get/get.dart';

// Partially visible bottom sheet that can be dragged into the screen. Provides different
// views for expanded and collapsed states
class DraggableBottomSheet extends StatefulWidget {
  /// Alignment of the sheet. Default Alignment.bottomCenter
  final Alignment alignment;

  /// Widget above which draggable sheet will be placed.
  final Widget backgroundWidget;

  /// Color of the modal barrier. Default Colors.black54
  final Color barrierColor;

  /// Whether tapping on the barrier will dismiss the dialog. Default true.
  /// If false, draggable bottom sheet will act as persistent sheet
  final bool barrierDismissible;

  /// Whether the sheet is collapsed initially. Default true.
  final bool collapsed;

  /// Sheet expansion animation curve. Default Curves.linear
  final Curve curve;

  /// Duration for sheet expansion animation. Default Duration(milliseconds: 0)
  final Duration duration;

  /// Widget to show on expanded sheet
  final Widget expandedWidget;

  /// Increment [expansionExtent] on [minExtent] to change from [previewWidget] to [expandedWidget]
  final double expansionExtent;

  /// Maximum extent for sheet expansion
  final double maxExtent;

  /// Minimum extent for the sheet
  final double minExtent;

  /// Callback function when sheet is being dragged
  /// pass current extent (position) as an argument
  final Function(double) onDragging;

  /// Widget to show on collapsed sheet
  final Widget previewWidget;

  /// indicate if the dialog should only display in 'safe' areas of the screen. Default true
  final bool useSafeArea;

  const DraggableBottomSheet({
    Key? key,
    required this.previewWidget,
    required this.backgroundWidget,
    required this.expandedWidget,
    required this.onDragging,
    this.minExtent = 50.0,
    this.collapsed=true,
    this.useSafeArea = true,
    this.curve = Curves.linear,
    this.expansionExtent = 10.0,
    this.barrierDismissible = true,
    this.maxExtent = double.infinity,
    this.barrierColor = Colors.black54,
    this.alignment = Alignment.bottomCenter,
    this.duration = const Duration(milliseconds: 0),
  })  : assert(minExtent > 0.0),
        assert(expansionExtent > 0.0),
        assert(minExtent + expansionExtent < maxExtent),
        super(key: key);

  @override
  DraggableBottomSheetState createState() => DraggableBottomSheetState();
}

class DraggableBottomSheetState extends State<DraggableBottomSheet> {


  @override
  void initState() {
    super.initState();
    PostWithVibeController.to.currentExtent.value =  354;
  }

  @override
  Widget build(BuildContext context) {
    return widget.useSafeArea ? SafeArea(child: _body()) : _body();
  }

  /// body content
  Widget _body() {
    return Obx(
        ()=> Stack(
        children: [
          // background widget
          widget.backgroundWidget,
          // barrier
          if (PostWithVibeController.to.currentExtent.value.roundToDouble() > widget.minExtent + 0.1) Positioned.fill(child: _barrier()),
          // sheet
          Align(alignment: widget.alignment, child: _sheet()),
        ],
      ),
    );
  }

  /// barrier film between sheet & background widget
  Widget _barrier() {
    return IgnorePointer(
        ignoring: !widget.barrierDismissible,
        child: GestureDetector(
          onTap: widget.barrierDismissible ? () => setState(() => PostWithVibeController.to.currentExtent.value = widget.minExtent) : null,
          child: Container(color: widget.barrierColor),
        ),

    );
  }

  /// draggable bottom sheet
  Widget _sheet() {
    return Obx(
      ()=> GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onHorizontalDragUpdate: _onHorizontalDragUpdate,
        child: AnimatedContainer(
          curve: widget.curve,
          duration: widget.duration,
          width: _axis() == Axis.horizontal ? PostWithVibeController.to.currentExtent.value : null,
          height: _axis() == Axis.horizontal ? null : PostWithVibeController.to.currentExtent.value,
          child: PostWithVibeController.to.currentExtent.value >= widget.minExtent + widget.expansionExtent ? widget.expandedWidget : widget.previewWidget,
        ),
      ),
    );
  }

  /// determine scroll direction based on DraggableBottomSheetPosition
  Axis _axis() {
    if (widget.alignment == Alignment.topLeft ||
        widget.alignment == Alignment.topRight ||
        widget.alignment == Alignment.topCenter ||
        widget.alignment == Alignment.bottomLeft ||
        widget.alignment == Alignment.bottomRight ||
        widget.alignment == Alignment.bottomCenter) {
      return Axis.vertical;
    }

    return Axis.horizontal;
  }

  /// callback function when sheet is dragged horizontally
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_axis() == Axis.vertical) return;

    // delta dx is positive when dragged towards right &
    // negative when dragged towards left
    final newExtent = (PostWithVibeController.to.currentExtent.value + details.delta.dx).roundToDouble();
    if (newExtent >= widget.minExtent && newExtent <= widget.maxExtent) {
      setState(() => PostWithVibeController.to.currentExtent.value = newExtent);
      widget.onDragging(PostWithVibeController.to.currentExtent.value);
    }
  }

  /// callback function when sheet is dragged vertically
  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_axis() == Axis.horizontal) return;

    // delta dy is positive when dragged downward &
    // negetive when dragged upward
    final newExtent = (PostWithVibeController.to.currentExtent.value - details.delta.dy).roundToDouble();
    if (newExtent >= widget.minExtent && newExtent <= widget.maxExtent) {
      setState(() => PostWithVibeController.to.currentExtent.value = newExtent);
      widget.onDragging(PostWithVibeController.to.currentExtent.value);
    }
  }
}