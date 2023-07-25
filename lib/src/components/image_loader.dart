import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImageLoader extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Color? color;



  const ImageLoader(
      {super.key,
      required this.url,
      this.width,
      this.height,
      this.fit,
      this.color=Colors.white
      });

  @override
  Widget build(BuildContext context) {
    return checkImageType(url) == "svg"
        ? SvgPicture.asset(
            url,
            width: width,
            height: height,
            fit: fit ?? BoxFit.contain,
      colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
          )
        : Image.asset(
            url,
            width: width,
            height: height,
            fit: fit,
          );
  }

  String checkImageType(String url) {
    if (url.contains(".svg")) {
      return "svg";
    } else if (url.contains(".png")) {
      return "png";
    } else if (url.contains(".jpg")) {
      return "jpg";
    } else if (url.contains(".jpeg")) {
      return "jpeg";
    } else {
      return "svg";
    }
  }
}
