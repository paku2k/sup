import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:sa_v1_migration/simple_animations/multi_track_tween.dart';
import 'package:supercharged/supercharged.dart';

enum AniProps { opacity, Ytranslate, Xtranslate, radius, Ysize, Xsize, scale }

class CircleBoxAnimation extends StatelessWidget {
  final double delay;
  final Widget child;
  final CustomAnimationControl control;

  CircleBoxAnimation(
    this.delay,
    this.child,
    this.control,
  );

  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<AniProps>()
      ..add(AniProps.opacity, 0.0.tweenTo(1.0), 1000.milliseconds)
      ..add(AniProps.Ytranslate, (-30.0).tweenTo(0.0), 1000.milliseconds)
      ..add(AniProps.radius, 40.0.tweenTo(10.0), 1000.milliseconds)
      ..add(AniProps.Ytranslate, 0.0.tweenTo(-150.0), 1000.milliseconds)
      ..add(AniProps.Xtranslate, 0.0.tweenTo(-60.0), 1000.milliseconds)
      ..add(AniProps.Ysize, 60.0.tweenTo(250.0), 1000.milliseconds)
      ..add(AniProps.Xsize, 60.0.tweenTo(200.0), 1000.milliseconds)
      ..add(AniProps.scale, 0.2.tweenTo(1.0), 1000.milliseconds);

    return CustomAnimation(
        control: control,
        delay: Duration(milliseconds: (500 * delay).round()),
        duration: tween.duration,
        tween: tween,
        child: child,
        builder: (context, child, animation) => Transform.translate(
              offset: Offset(
                animation.get(AniProps.Xtranslate),
                0

              ),
              child: Transform.translate(
               offset: Offset( 0,animation.get(AniProps.Ytranslate)),
                child: Container(
                  width: animation.get(AniProps.Ysize),
                  height: animation.get(AniProps.Xsize),

                  child: Text("Hello"),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        animation.get(AniProps.radius),
                      ),
                    ),
                  ),
                ),
              ),
            ));
  }
}
