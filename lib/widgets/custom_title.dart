import 'package:flutter/material.dart';
import 'package:guideme/core/constants/constants.dart';

class TitlePage extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color borderColor;

  const TitlePage({
    super.key,
    required this.title,
    required this.subtitle,
    this.borderColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            title,
            style: AppTextStyles.titleStyle,
          ),
        ),

        // Subtitle with full-width border
        Container(
          width: double.infinity, // Mengatur lebar penuh sesuai layar
          padding: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.tertiaryColor,
                width: 1.0,
              ),
            ),
          ),
          child: Text(
            subtitle,
            style: AppTextStyles.bodyBlack.copyWith(
              color: AppColors.secondaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomTitle extends StatelessWidget {
  final String firstText;
  final String secondText;

  CustomTitle({required this.firstText, required this.secondText});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              firstText,
              style: AppTextStyles.mediumBlack.copyWith(color: AppColors.secondaryColor),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              secondText,
              style: AppTextStyles.bodyBlack.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTitle2 extends StatelessWidget {
  final String firstText;
  final String secondText;

  CustomTitle2({required this.firstText, required this.secondText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          firstText,
          style: AppTextStyles.mediumBlack.copyWith(color: AppColors.secondaryColor),
        ),
        Text(
          secondText,
          style: AppTextStyles.bodyBlack.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class CustomFormTitle extends StatelessWidget {
  final String firstText;
  final String secondText;

  CustomFormTitle({required this.firstText, required this.secondText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          firstText,
          style: AppTextStyles.bodyBlack.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(
          secondText,
          style: AppTextStyles.mediumBlack.copyWith(color: AppColors.secondaryColor),
        ),
        SizedBox(
          height: 24,
        ),
      ],
    );
  }
}
