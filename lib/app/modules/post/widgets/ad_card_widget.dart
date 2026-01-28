import 'package:cached_network_image/cached_network_image.dart';
import 'package:casarancha/app/data/models/ad_campaign_model.dart';
import 'package:casarancha/app/resources/app_colors.dart';
import 'package:casarancha/app/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AdCard extends StatelessWidget {
  final AdCampaign ad;
  const AdCard({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ad.name,
            style: Get.textTheme.bodyMedium!
                .copyWith(fontWeight: FontWeight.w800, color: AppColors.primaryColor),
          ),
          if (ad.contentText?.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(
              ad.contentText!,
              style: Get.textTheme.bodySmall,
            ),
          ],
          if (ad.mediaUrl?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: ad.mediaUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          if (ad.linkUrl?.isNotEmpty == true) ...[
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: ad.linkUrl!));
                CustomSnackbar.showSuccessToast("Link copied. Paste in your browser to open.");
              },
              child: const Text("Copy link"),
            ),
          ],
        ],
      ),
    );
  }
}
