import 'package:flutter/material.dart';
import 'package:genesis_workspace/gen/assets.gen.dart';

class GenesisLogo extends StatelessWidget {
  final double? size;
  final Duration duration;
  const GenesisLogo({super.key, this.size, this.duration = const Duration(milliseconds: 300)});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      width: size,
      height: size,
      child: Assets.images.genesisLogoSvg.svg(),
    );
  }
}
