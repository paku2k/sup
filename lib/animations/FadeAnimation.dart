import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:sa_v1_migration/simple_animations/multi_track_tween.dart';
import 'package:supercharged/supercharged.dart';

enum AniProps { opacity, Ytranslate }

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeAnimation(
    this.delay,
    this.child,
  );

  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<AniProps>()
      ..add(AniProps.opacity, 0.0.tweenTo(1.0), 1000.milliseconds)
      ..add(AniProps.Ytranslate, (-30.0).tweenTo(0.0), 500.milliseconds,
          Curves.easeOut);

    return CustomAnimation(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builder: (context, child, animation) => Opacity(
        opacity: animation.get(AniProps.opacity),
        child: Transform.translate(
            offset: Offset(0, animation.get(AniProps.Ytranslate)),
            child: child),
      ),
    );
  }
}

class FadeAnimationApple extends StatelessWidget {
  final double delay;
  final Widget child;

  FadeAnimationApple(
      this.delay,
      this.child,
      );

  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<AniProps>()
      ..add(AniProps.opacity, 0.0.tweenTo(1.0), 600.milliseconds)
      ..add(AniProps.Ytranslate, (-120.0).tweenTo(0.0), 650.milliseconds,
          Curves.easeInCubic);

    return CustomAnimation(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builder: (context, child, animation) => Opacity(
        opacity: animation.get(AniProps.opacity),
        child: Transform.translate(
            offset: Offset(0, animation.get(AniProps.Ytranslate)),
            child: child),
      ),
    );
  }
}
