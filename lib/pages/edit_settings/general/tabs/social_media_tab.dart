// lib/pages/edit_settings/tabs/social_media_tab.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';

class SocialMediaTab extends StatelessWidget {
  final Store store;
  final Function(Store) onChanged;

  const SocialMediaTab({
    super.key,
    required this.store,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Redes Sociais", style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        AppTextField(
          initialValue: store.marketing?.instagram,
          title: 'Instagram',
          hint: '@sua_loja',
          onChanged: (v) => onChanged(store.copyWith(
              marketing: store.marketing?.copyWith(instagram: v)
          ),
          ),),
          const SizedBox(height: 16),
          AppTextField(
            initialValue: store.marketing?.facebook,
            title: 'Facebook',
            hint: 'facebook.com/sua_loja',
            onChanged: (v) => onChanged(store.copyWith(
                marketing: store.marketing?.copyWith(facebook: v)
            )),
          ),
          const SizedBox(height: 16),
          AppTextField(
            initialValue: store.marketing?.tiktok,
            title: 'TikTok',
            hint: 'tiktok.com/@sua_loja',
            onChanged: (v) => onChanged(store.copyWith(
                marketing: store.marketing?.copyWith(tiktok: v)
            )),
          ),
          ],
        ),
      ),
    );
  }
}