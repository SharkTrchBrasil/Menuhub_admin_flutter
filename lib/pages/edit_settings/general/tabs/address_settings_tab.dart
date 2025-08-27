// lib/pages/edit_settings/tabs/address_settings_tab.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/helpers/mask.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';

import '../../../../models/store_address.dart';

class AddressSettingsTab extends StatelessWidget {
  final Store store;
  final Function(Store) onChanged;

  const AddressSettingsTab({
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

            Text("Endereço Principal", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text("Este é o endereço físico da sua loja, usado para retiradas e como referência.", style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),
            AppTextField(
              initialValue: store.address!.zipCode,

              onChanged: (v) => onChanged(store.copyWith(
                  address: store.address?.copyWith(zipCode: v) ?? StoreAddress(zipCode: v)
              ),),

              title: 'CEP',
              hint: '00000-000',
              formatters: [cepMask],
            ),
            const SizedBox(height: 16),
            AppTextField(
              initialValue: store.address!.street,

              onChanged: (v) => onChanged(store.copyWith(
                  address: store.address?.copyWith(street: v) ?? StoreAddress(street: v)
              ),),

              title: 'Rua / Avenida', hint: '',
            ),



            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    initialValue: store.address!.number,
                    onChanged: (v) => onChanged(store.copyWith(
                        address: store.address?.copyWith(number: v) ?? StoreAddress(number: v)
                    )),

                    title: 'Número', hint: '',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppTextField(
                    initialValue: store.address!.neighborhood,

                    onChanged: (v) => onChanged(store.copyWith(
                        address: store.address?.copyWith(neighborhood: v) ?? StoreAddress(neighborhood: v)
                    ),),

                    title: 'Bairro', hint: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              initialValue: store.address!.complement,
              onChanged: (v) => onChanged(store.copyWith(
                  address: store.address?.copyWith(complement: v) ?? StoreAddress(complement: v)
              ),),
              title: 'Complemento (Opcional)',
              hint: 'Apto, Bloco, etc.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: AppTextField(
                    initialValue: store.address!.city,

                    onChanged: (v) => onChanged(store.copyWith(
                        address: store.address?.copyWith(city: v) ?? StoreAddress(city: v)
                    ),),

                    title: 'Cidade', hint: '',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: AppTextField(
                    initialValue: store.address!.state,


                    onChanged: (v) => onChanged(store.copyWith(
                        address: store.address?.copyWith(state: v) ?? StoreAddress(state: v)
                    ),),

                    title: 'Estado',
                    hint: 'UF',
                  ),
                ),
              ],
            ),


          ],
        ),
      ),
    );
  }
}