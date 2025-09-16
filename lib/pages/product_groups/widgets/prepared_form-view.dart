import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/product_groups/widgets/unifield_product_form.dart';

import '../../../widgets/app_image_form_field.dart';
import '../cubit/complement_form_cubit.dart';

class PreparedFormView extends StatelessWidget {
  const PreparedFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return UnifiedProductForm(isPrepared: true);
  }
}