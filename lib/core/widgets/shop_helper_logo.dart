
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../app_colors.dart';

class ShopHelperLogo extends StatelessWidget {
  final double size;
  const ShopHelperLogo({super.key, this.size = 32.0});

  @override
  Widget build(BuildContext context) {
    // Ваш SVG-код, обгорнутий у рядок
    const String svgString = '''
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M7.5 7.67001V6.70001C7.5 4.45001 9.31 2.24001 11.56 2.03001C14.24 1.77001 16.5 3.88001 16.5 6.51001V7.89001" stroke="#333" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>
      <path d="M15.44 16.83C15.22 16.75 14.98 16.71 14.73 16.71C13.63 16.71 12.72 17.39 12.41 18.35L12.04 19.55C11.84 20.18 12.31 20.82 12.96 20.82H14.73H15.63C16.27 20.82 16.75 20.19 16.57 19.58L16.23 18.42C16.01 17.6 15.44 16.83 15.44 16.83Z" fill="#333"/>
      <path d="M8.99981 22H14.9998C19.0198 22 19.7398 20.39 19.9498 18.43L20.6998 12.43C20.9698 9.99 20.2798 8 15.9998 8H7.99981C3.71981 8 3.02981 9.99 3.29981 12.43L4.04981 18.43C4.25981 20.39 4.97981 22 8.99981 22Z" stroke="#333" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>
    ''';

    return SvgPicture.string(
      svgString,
      width: size,
      height: size,
      colorFilter: const ColorFilter.mode(AppColors.textDark, BlendMode.srcIn),
    );
  }
}