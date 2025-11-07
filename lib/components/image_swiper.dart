import 'dart:async';
import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';

/*class SlidePage extends StatefulWidget {
  const SlidePage({this.url});
  final String? url;
  @override
  _SlidePageState createState() => _SlidePageState();
}

class _SlidePageState extends State<SlidePage> {
  GlobalKey<ExtendedImageSlidePageState> slidePagekey = GlobalKey<ExtendedImageSlidePageState>();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ExtendedImageSlidePage(
        key: slidePagekey,
        child: GestureDetector(
          child: HeroWidget(
            child: ExtendedImage.network(
              widget.url!,
              enableSlideOutPage: true,
            ),
            tag: widget.url!,
            slideType: SlideType.onlyImage,
            slidePagekey: slidePagekey,
          ),
          onTap: () {
            slidePagekey.currentState!.popPage();
            Navigator.pop(context);
          },
        ),
        slideAxis: SlideAxis.both,
        slideType: SlideType.onlyImage,
      ),
    );
  }
}*/

typedef DoubleClickAnimationListener = void Function();




class PicSwiper extends StatefulWidget {
  const PicSwiper({super.key, this.index, this.pics});

  final int? index;
  final List<String>? pics;

  @override
  _PicSwiperState createState() => _PicSwiperState();
}

class _PicSwiperState extends State<PicSwiper> with TickerProviderStateMixin {
  final StreamController<int> rebuildIndex = StreamController<int>.broadcast();
  final StreamController<bool> rebuildSwiper = StreamController<bool>.broadcast();
  final StreamController<double> rebuildDetail = StreamController<double>.broadcast();
  final Map<int, ImageDetailInfo> detailKeys = <int, ImageDetailInfo>{};
  late AnimationController _doubleClickAnimationController;
  late AnimationController _slideEndAnimationController;
  late Animation<double> _slideEndAnimation;
  Animation<double>? _doubleClickAnimation;
  late DoubleClickAnimationListener _doubleClickAnimationListener;
  List<double> doubleTapScales = <double>[1.0, 2.0];
  GlobalKey<ExtendedImageSlidePageState> slidePagekey = GlobalKey<ExtendedImageSlidePageState>();
  int? _currentIndex = 0;
  bool _showSwiper = true;
  double _imageDetailY = 0;
  Rect? imageDRect;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    imageDRect = Offset.zero & size;
    if (widget.pics?.length == 1) {
      Widget result = Material(

          /// if you use ExtendedImageSlidePage and slideType =SlideType.onlyImage,
          /// make sure your page is transparent background
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ExtendedImageGesturePageView.builder(
                controller: ExtendedPageController(initialPage: widget.index!, pageSpacing: 50, shouldIgnorePointerWhenScrolling: false),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                canScrollPage: (_) => false,
                itemBuilder: (BuildContext context, int index) {
                  final String item = widget.pics![index];

                  Widget image = ExtendedImage.network(
                    item,
                    fit: BoxFit.contain,
                    enableSlideOutPage: true,
                    mode: ExtendedImageMode.gesture,
                    imageCacheName: 'CropImage',
                    //layoutInsets: EdgeInsets.all(20),
                    initGestureConfigHandler: (ExtendedImageState state) {
                      double? initialScale = 1.0;
                      return GestureConfig(
                        inPageView: true,
                        initialScale: initialScale ,
                        maxScale: max(initialScale, 5.0),
                        animationMaxScale: max(initialScale, 5.0),
                        initialAlignment: InitialAlignment.center,
                        cacheGesture: false,
                      );
                    },
                    onDoubleTap: (ExtendedImageGestureState state) {
                      ///you can use define pointerDownPosition as you can,
                      ///default value is double tap pointer down postion.
                      final Offset? pointerDownPosition = state.pointerDownPosition;
                      final double? begin = state.gestureDetails!.totalScale;
                      double end;

                      //remove old
                      _doubleClickAnimation?.removeListener(_doubleClickAnimationListener);

                      //stop pre
                      _doubleClickAnimationController.stop();

                      //reset to use
                      _doubleClickAnimationController.reset();

                      if (begin == doubleTapScales[0]) {
                        end = doubleTapScales[1];
                      } else {
                        end = doubleTapScales[0];
                      }

                      _doubleClickAnimationListener = () {
                        //print(_animation.value);
                        state.handleDoubleTap(scale: _doubleClickAnimation!.value, doubleTapPosition: pointerDownPosition);
                      };
                      _doubleClickAnimation = _doubleClickAnimationController.drive(Tween<double>(begin: begin, end: end));

                      _doubleClickAnimation!.addListener(_doubleClickAnimationListener);

                      _doubleClickAnimationController.forward();
                    },
                    loadStateChanged: (ExtendedImageState state) {
                      if (state.extendedImageLoadState == LoadState.completed) {
                        final Rect imageDRect = getDestinationRect(
                          rect: Offset.zero & size,
                          inputSize: Size(
                            state.extendedImageInfo!.image.width.toDouble(),
                            state.extendedImageInfo!.image.height.toDouble(),
                          ),
                          fit: BoxFit.contain,
                        );

                        detailKeys[index] ??= ImageDetailInfo(
                          imageDRect: imageDRect,
                          pageSize: size,
                          imageInfo: state.extendedImageInfo!,
                        );
                        final ImageDetailInfo? imageDetailInfo = detailKeys[index];
                        return StreamBuilder<double>(
                          builder: (BuildContext context, AsyncSnapshot<double> data) {
                            return ExtendedImageGesture(
                              state,
                              canScaleImage: (_) => _imageDetailY == 0,
                              imageBuilder: (Widget image) {
                                return Stack(
                                  children: <Widget>[
                                    Positioned.fill(
                                      top: _imageDetailY,
                                      bottom: -_imageDetailY,
                                      child: image,
                                    ),
                                    Positioned(
                                      left: 0.0,
                                      right: 0.0,
                                      top: imageDetailInfo!.imageBottom + _imageDetailY,
                                      child: Opacity(
                                        opacity: _imageDetailY == 0
                                            ? 0
                                            : min(
                                          1,
                                          _imageDetailY.abs() / (imageDetailInfo.maxImageDetailY / 4.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          initialData: _imageDetailY,
                          stream: rebuildDetail.stream,
                        );
                      }
                      return null;
                    },
                  );

                  if (index < min(9, widget.pics!.length)) {
                    image = HeroWidget(
                      tag: item,
                      slideType: SlideType.onlyImage,
                      slidePagekey: slidePagekey,
                      child: image,
                    );
                  }

                  image = GestureDetector(
                    child: image,
                    onTap: () {
                      if (_imageDetailY != 0) {
                        _imageDetailY = 0;
                        rebuildDetail.sink.add(_imageDetailY);
                      } else {
                        // slidePagekey.currentState!.popPage();
                        // Navigator.pop(context);
                      }
                    },
                  );

                  return image;
                },
                itemCount: widget.pics!.length,
                onPageChanged: (int index) {
                  _currentIndex = index;
                  rebuildIndex.add(index);
                  if (_imageDetailY != 0) {
                    _imageDetailY = 0;
                    rebuildDetail.sink.add(_imageDetailY);
                  }
                  _showSwiper = true;
                  rebuildSwiper.add(_showSwiper);
                },
              ),
              StreamBuilder<bool>(
                builder: (BuildContext c, AsyncSnapshot<bool> d) {
                  if (d.data == null || !d.data!) {
                    return const SizedBox.shrink();
                  }

                  return Positioned(
                    top: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: MySwiperPlugin(widget.pics, _currentIndex, rebuildIndex),
                  );
                },
                initialData: true,
                stream: rebuildSwiper.stream,
              )
            ],
          ));

      result = ExtendedImageSlidePage(
        key: slidePagekey,
        slideAxis: SlideAxis.vertical,
        slideType: SlideType.onlyImage,
        slideScaleHandler: (Offset offset, {ExtendedImageSlidePageState? state}) {
          //image is ready and it's not sliding.
          if (state != null && detailKeys[_currentIndex!] != null && state.scale == 1.0) {
            //don't slide page if scale of image is more than 1.0
            if((state.imageGestureState?.gestureDetails?.totalScale ??0) > 1.0) {
              return 1.0;
            }
            //or slide down into detail mode
            if (offset.dy < 0 || _imageDetailY < 0) {
              return 1.0;
            }
          }

          return null;
        },
        slideEndHandler: (Offset offset, {ExtendedImageSlidePageState? state, ScaleEndDetails? details}) {
          if (_imageDetailY != 0 && state!.scale == 1) {
            if (!_slideEndAnimationController.isAnimating) {
// get magnitude from gesture velocity
              final double magnitude = details!.velocity.pixelsPerSecond.distance;

              // do a significant magnitude

              if (magnitude.greaterThanOrEqualTo(minMagnitude)) {
                final Offset direction = details.velocity.pixelsPerSecond / magnitude * 1000;

                _slideEndAnimation = _slideEndAnimationController.drive(Tween<double>(
                  begin: _imageDetailY,
                  end: (_imageDetailY + direction.dy).clamp(-detailKeys[_currentIndex!]!.maxImageDetailY, 0.0).toDouble(),
                ));
                _slideEndAnimationController.reset();
                _slideEndAnimationController.forward();
              }
            }
            return false;
          }

          return null;
        },
        child: result,
      );
      return result;
    }

    Widget result = Material(

      /// if you use ExtendedImageSlidePage and slideType =SlideType.onlyImage,
      /// make sure your page is transparent background
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ExtendedImageGesturePageView.builder(
              controller: ExtendedPageController(initialPage: widget.index!, pageSpacing: 50, shouldIgnorePointerWhenScrolling: false),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              canScrollPage: (GestureDetails? gestureDetails) {
                return _imageDetailY >= 0;
                //return (gestureDetails?.totalScale ?? 1.0) <= 1.0;
              },
              itemBuilder: (BuildContext context, int index) {
                final String item = widget.pics![index];

                Widget image = ExtendedImage.network(
                  item,
                  fit: BoxFit.contain,
                  enableSlideOutPage: true,
                  mode: ExtendedImageMode.gesture,
                  //layoutInsets: EdgeInsets.all(20),
                  initGestureConfigHandler: (ExtendedImageState state) {
                    double? initialScale = 1.0;


                    return GestureConfig(
                      inPageView: true,
                      initialScale: initialScale,
                      maxScale: max(initialScale, 5.0),
                      animationMaxScale: max(initialScale, 5.0),
                      initialAlignment: InitialAlignment.center,
                      //you can cache gesture state even though page view page change.
                      //remember call clearGestureDetailsCache() method at the right time.(for example,this page dispose)
                      cacheGesture: false,
                    );
                  },
                  onDoubleTap: (ExtendedImageGestureState state) {
                    ///you can use define pointerDownPosition as you can,
                    ///default value is double tap pointer down postion.
                    final Offset? pointerDownPosition = state.pointerDownPosition;
                    final double? begin = state.gestureDetails!.totalScale;
                    double end;

                    //remove old
                    _doubleClickAnimation?.removeListener(_doubleClickAnimationListener);

                    //stop pre
                    _doubleClickAnimationController.stop();

                    //reset to use
                    _doubleClickAnimationController.reset();

                    if (begin == doubleTapScales[0]) {
                      end = doubleTapScales[1];
                    } else {
                      end = doubleTapScales[0];
                    }

                    _doubleClickAnimationListener = () {
                      //print(_animation.value);
                      state.handleDoubleTap(scale: _doubleClickAnimation!.value, doubleTapPosition: pointerDownPosition);
                    };
                    _doubleClickAnimation = _doubleClickAnimationController.drive(Tween<double>(begin: begin, end: end));

                    _doubleClickAnimation!.addListener(_doubleClickAnimationListener);

                    _doubleClickAnimationController.forward();
                  },
                  loadStateChanged: (ExtendedImageState state) {
                    if (state.extendedImageLoadState == LoadState.completed) {
                      final Rect imageDRect = getDestinationRect(
                        rect: Offset.zero & size,
                        inputSize: Size(
                          state.extendedImageInfo!.image.width.toDouble(),
                          state.extendedImageInfo!.image.height.toDouble(),
                        ),
                        fit: BoxFit.contain,
                      );

                      detailKeys[index] ??= ImageDetailInfo(
                        imageDRect: imageDRect,
                        pageSize: size,
                        imageInfo: state.extendedImageInfo!,
                      );
                      final ImageDetailInfo? imageDetailInfo = detailKeys[index];
                      return StreamBuilder<double>(
                        builder: (BuildContext context, AsyncSnapshot<double> data) {
                          return ExtendedImageGesture(
                            state,
                            canScaleImage: (_) => _imageDetailY == 0,
                            imageBuilder: (Widget image) {
                              return Stack(
                                children: <Widget>[
                                  Positioned.fill(
                                    top: _imageDetailY,
                                    bottom: -_imageDetailY,
                                    child: image,
                                  ),
                                  Positioned(
                                    left: 0.0,
                                    right: 0.0,
                                    top: imageDetailInfo!.imageBottom + _imageDetailY,
                                    child: Opacity(
                                      opacity: _imageDetailY == 0
                                          ? 0
                                          : min(
                                        1,
                                        _imageDetailY.abs() / (imageDetailInfo.maxImageDetailY / 4.0),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        initialData: _imageDetailY,
                        stream: rebuildDetail.stream,
                      );
                    }
                    return null;
                  },
                );

                if (index < min(9, widget.pics!.length)) {
                  image = HeroWidget(
                    tag: item,
                    slideType: SlideType.onlyImage,
                    slidePagekey: slidePagekey,
                    child: image,
                  );
                }

                image = GestureDetector(
                  child: image,
                  onTap: () {
                    if (_imageDetailY != 0) {
                      _imageDetailY = 0;
                      rebuildDetail.sink.add(_imageDetailY);
                    } else {
                      // slidePagekey.currentState!.popPage();
                      // Navigator.pop(context);
                    }
                  },
                );

                return image;
              },
              itemCount: widget.pics!.length,
              onPageChanged: (int index) {
                _currentIndex = index;
                rebuildIndex.add(index);
                if (_imageDetailY != 0) {
                  _imageDetailY = 0;
                  rebuildDetail.sink.add(_imageDetailY);
                }
                _showSwiper = true;
                rebuildSwiper.add(_showSwiper);
              },
            ),
            StreamBuilder<bool>(
              builder: (BuildContext c, AsyncSnapshot<bool> d) {
                if (d.data == null || !d.data!) {
                  return const SizedBox.shrink();
                }

                return Positioned(
                  top: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: MySwiperPlugin(widget.pics, _currentIndex, rebuildIndex),
                );
              },
              initialData: true,
              stream: rebuildSwiper.stream,
            )
          ],
        ));

    result = ExtendedImageSlidePage(
      key: slidePagekey,
      slideAxis: SlideAxis.vertical,
      slideType: SlideType.onlyImage,
      slideScaleHandler: (
          Offset offset, {
            ExtendedImageSlidePageState? state,
          }) {
        //image is ready and it's not sliding.
        if (state != null && detailKeys[_currentIndex!] != null && state.scale == 1.0) {
          //don't slide page if scale of image is more than 1.0
          if (state.imageGestureState!.gestureDetails!.totalScale! > 1.0) {
            return 1.0;
          }
          //or slide down into detail mode
          if (offset.dy < 0 || _imageDetailY < 0) {
            return 1.0;
          }
        }

        return null;
      },
      slideEndHandler: (
          Offset offset, {
            ExtendedImageSlidePageState? state,
            ScaleEndDetails? details,
          }) {
        if (_imageDetailY != 0 && state!.scale == 1) {
          if (!_slideEndAnimationController.isAnimating) {
            // get magnitude from gesture velocity
            final double magnitude = details!.velocity.pixelsPerSecond.distance;

            // do a significant magnitude

            if (magnitude.greaterThanOrEqualTo(minMagnitude)) {
              final Offset direction = details.velocity.pixelsPerSecond / magnitude * 1000;

              _slideEndAnimation = _slideEndAnimationController.drive(Tween<double>(
                begin: _imageDetailY,
                end: (_imageDetailY + direction.dy).clamp(-detailKeys[_currentIndex!]!.maxImageDetailY, 0.0).toDouble(),
              ));
              _slideEndAnimationController.reset();
              _slideEndAnimationController.forward();
            }
          }
          return false;
        }

        return null;
      },
      onSlidingPage: (ExtendedImageSlidePageState state) {
        ///you can change other widgets' state on page as you want
        ///base on offset/isSliding etc
        //var offset= state.offset;
        final bool showSwiper = !state.isSliding;
        if (showSwiper != _showSwiper) {
          // do not setState directly here, the image state will change,
          // you should only notify the widgets which are needed to change
          // setState(() {
          // _showSwiper = showSwiper;
          // });

          _showSwiper = showSwiper;
          rebuildSwiper.add(_showSwiper);
        }
      },
      child: result,
    );

    return result;
  }

  @override
  void dispose() {
    rebuildIndex.close();
    rebuildSwiper.close();
    rebuildDetail.close();
    _doubleClickAnimationController.dispose();
    _slideEndAnimationController.dispose();
    clearGestureDetailsCache();
    //cancelToken?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _doubleClickAnimationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);

    _slideEndAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _slideEndAnimationController.addListener(() {
      _imageDetailY = _slideEndAnimation.value;
      if (_imageDetailY == 0) {
        _showSwiper = true;
        rebuildSwiper.add(_showSwiper);
      }
      rebuildDetail.sink.add(_imageDetailY);
    });
  }
}

class InsetsClipper extends CustomClipper<Rect> {
  final EdgeInsets _insets;

  InsetsClipper([this._insets = EdgeInsets.zero]);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0 + _insets.left, 0 + _insets.top, size.width - _insets.right, size.height - _insets.bottom);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

class VerticalScrollOffsetTransition extends AnimatedWidget {
  final double topOffset;
  final double bottomOffset;
  final double paddingTop;
  final Animation<double> animation;
  final Widget child;
  final RectTween heroRectTween;
  final Size overlaySize;

  const VerticalScrollOffsetTransition(
      {Key? key,
        required this.animation,
        required this.child,
        required this.overlaySize,
        required this.paddingTop,
        required this.bottomOffset,
        required this.topOffset,
        required this.heroRectTween})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final Rect rect = heroRectTween.evaluate(animation)!;
    final RelativeRect offsets = RelativeRect.fromSize(rect, overlaySize);

    return ClipRect(
        clipper: InsetsClipper(
          EdgeInsets.only(top: topOffset + paddingTop - offsets.top, bottom: bottomOffset - offsets.bottom),
        ),
        child: child);
  }
}

class ScrolledHero extends StatelessWidget {
  final Object tag;
  final Tween<Rect?> Function(Rect?, Rect?)? createRectTween;
  final Widget Function(BuildContext, Animation<double>, HeroFlightDirection, BuildContext, BuildContext)? flightShuttleBuilder;
  final Widget Function(BuildContext, Size, Widget)? placeholderBuilder;
  final bool transitionOnUserGestures;
  final Widget child;

  const ScrolledHero(
      {Key? key,
        required this.tag,
        this.createRectTween,
        this.flightShuttleBuilder,
        this.placeholderBuilder,
        this.transitionOnUserGestures = false,
        required this.child})
      : super(key: key);

  Rect _boundingBoxFor(BuildContext context, BuildContext? ancestorContext) {
    assert(ancestorContext != null);
    final RenderBox box = context.findRenderObject()! as RenderBox;
    assert(box.hasSize && box.size.isFinite);
    return MatrixUtils.transformRect(
      box.getTransformTo(ancestorContext?.findRenderObject()),
      Offset.zero & box.size,
    );
  }

  Widget scrolledShuttleBuilder(
      BuildContext flightContext,
      Animation<double> animation,
      HeroFlightDirection flightDirection,
      BuildContext fromHeroContext,
      BuildContext toHeroContext,
      ) {
    final Hero toHero = toHeroContext.widget as Hero;

    final fromRouteContext = Navigator.of(fromHeroContext).context;
    final toRouteContext = Navigator.of(toHeroContext).context;

    final mediaQueryData = MediaQuery.of(flightDirection == HeroFlightDirection.push ? toHeroContext : fromHeroContext);
    final scrolledScreenSize = mediaQueryData.size;
    // generally, status bar height
    final paddingTop = mediaQueryData.padding.top;

    final Rect fromHeroLocation = _boundingBoxFor(fromHeroContext, fromRouteContext);
    final Rect toHeroLocation = _boundingBoxFor(toHeroContext, toRouteContext);

    final heroRectTween = RectTween(begin: fromHeroLocation, end: toHeroLocation);

    final proxyAnimation = flightDirection == HeroFlightDirection.push ? animation : ReverseAnimation(animation);

    return VerticalScrollOffsetTransition(
        bottomOffset: 56,
        topOffset: 56,
        paddingTop: paddingTop,
        heroRectTween: heroRectTween,
        overlaySize: scrolledScreenSize,
        animation: proxyAnimation,
        child: toHero.child);
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: createRectTween,
      flightShuttleBuilder: flightShuttleBuilder,
      child: child,
    );
  }
}

class MySwiperPlugin extends StatelessWidget {
  const MySwiperPlugin(this.pics, this.index, this.reBuild, {super.key});

  final List<String>? pics;
  final int? index;
  final StreamController<int> reBuild;

  @override
  Widget build(BuildContext context) {
    final bool isSingle = pics!.length == 1;
    return SafeArea(
      child: StreamBuilder<int>(
        builder: (BuildContext context, AsyncSnapshot<int> data) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  margin: const EdgeInsets.only(left: 12.0).r,
                  decoration: BoxDecoration(
                    color: Colors.transparent ,
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: const GayaBackButton()),
              if (isSingle == false)
                SizedBox(
                  height: 50.0,
                  child: Row(
                    children: <Widget>[
                      const SizedBox(width: 10.0),
                      Text('${data.data! + 1}'),
                      Text(' / ${pics!.length}'),
                      const SizedBox(width: 10.0),
                    ],
                  ),
                ),
            ],
          );
        },
        initialData: index,
        stream: reBuild.stream,
      ),
    );
  }
}

/// make hero better when slide out
class HeroWidget extends StatefulWidget {
  const HeroWidget({
    super.key,
    required this.child,
    required this.tag,
    required this.slidePagekey,
    this.slideType = SlideType.onlyImage,
  });

  final Widget child;
  final SlideType slideType;
  final Object tag;
  final GlobalKey<ExtendedImageSlidePageState> slidePagekey;

  @override
  _HeroWidgetState createState() => _HeroWidgetState();
}

class _HeroWidgetState extends State<HeroWidget> {
  RectTween? _rectTween;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.tag,
      createRectTween: (Rect? begin, Rect? end) {
        _rectTween = RectTween(begin: begin, end: end);
        return _rectTween!;
      },
      // make hero better when slide out
      flightShuttleBuilder: (BuildContext flightContext, Animation<double> animation, HeroFlightDirection flightDirection,
          BuildContext fromHeroContext, BuildContext toHeroContext) {
        // make hero more smoothly
        final Hero hero = (flightDirection == HeroFlightDirection.pop ? fromHeroContext.widget : toHeroContext.widget) as Hero;
        if (_rectTween == null) {
          return hero;
        }

        if (flightDirection == HeroFlightDirection.pop) {
          final bool fixTransform = widget.slideType == SlideType.onlyImage &&
              (widget.slidePagekey.currentState!.offset != Offset.zero || widget.slidePagekey.currentState!.scale != 1.0);

          final Widget toHeroWidget = (toHeroContext.widget as Hero).child;
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext buildContext, Widget? child) {
              Widget animatedBuilderChild = hero.child;

              // make hero more smoothly
              animatedBuilderChild = Stack(
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 1 - animation.value,
                    child: UnconstrainedBox(
                      child: SizedBox(
                        width: _rectTween!.begin!.width,
                        height: _rectTween!.begin!.height,
                        child: toHeroWidget,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: animation.value,
                    child: animatedBuilderChild,
                  )
                ],
              );

              // fix transform when slide out
              if (fixTransform) {
                final Tween<Offset> offsetTween = Tween<Offset>(begin: Offset.zero, end: widget.slidePagekey.currentState!.offset);

                final Tween<double> scaleTween = Tween<double>(begin: 1.0, end: widget.slidePagekey.currentState!.scale);
                animatedBuilderChild = Transform.translate(
                  offset: offsetTween.evaluate(animation),
                  child: Transform.scale(
                    scale: scaleTween.evaluate(animation),
                    child: animatedBuilderChild,
                  ),
                );
              }

              return animatedBuilderChild;
            },
          );
        }
        return hero.child;
      },
      child: widget.child,
    );
  }
}

class ImageDetailInfo {
  ImageDetailInfo({required this.imageDRect, required this.pageSize, required this.imageInfo});

  final GlobalKey<State<StatefulWidget>> key = GlobalKey<State>();

  final Rect imageDRect;

  final Size pageSize;

  final ImageInfo imageInfo;

  double? _maxImageDetailY;

  double get imageBottom => imageDRect.bottom - 20;

  double get maxImageDetailY {
    try {
      //
      return _maxImageDetailY ??= max(key.currentContext!.size!.height - (pageSize.height - imageBottom), 0.1);
    } catch (e) {
      //currentContext is not ready
      return 100.0;
    }
  }
}

