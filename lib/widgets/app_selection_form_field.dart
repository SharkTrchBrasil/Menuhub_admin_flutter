import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/app_list_controller.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_table.dart';

abstract interface class SelectableItem {
  String get title;
}

class AppSelectionFormField<T extends SelectableItem> extends StatelessWidget {
  const AppSelectionFormField({
    super.key,
    required this.title,
    required this.fetch,
    required this.columns,
    this.validator,
    required this.onChanged,
    this.initialValue,
  });

  final String title;
  final Future<Either<void, List<T>>> Function() fetch;
  final List<AppTableColumn<T>> columns;
  final String? Function(T?)? validator;
  final Function(T?) onChanged;
  final T? initialValue;

  Future<void> showSelectionDialog(
      BuildContext context,
      FormFieldState<T> state,
      ) async {
    final item = await showDialog(
      context: context,
      builder: (_) => AppSelectionDialog<T>(fetch: fetch, columns: columns),
    );
    if (item != null) {
      state.didChange(item);
      onChanged(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: initialValue,
      validator: validator,
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(80),
                border:
                state.hasError
                    ? Border.all(color: Theme.of(context).colorScheme.error)
                    : null,
              ),
              child: InkWell(
                onTap: () => showSelectionDialog(context, state),
                child:
                state.value == null
                    ? Center(
                  child: Text(
                    'Selecionar $title',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : Center(
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          state.value!.title,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          state.didChange(null);
                          onChanged(null);
                        },
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 6),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class AppSelectionDialog<T> extends StatelessWidget {
  AppSelectionDialog({super.key, required this.fetch, required this.columns});

  final Future<Either<void, List<T>>> Function() fetch;
  final List<AppTableColumn<T>> columns;

  late final AppListController<T> listController = AppListController<T>(
    fetch: fetch,
  );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 548,
        child: AnimatedBuilder(
          animation: listController,
          builder: (_, __) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: const Text(
                            'Selecione um item',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        CloseButton(),
                      ],
                    ),
                  ),
                  AppPageStatusBuilder<List<T>>(
                    status: listController.status,
                    successBuilder: (items) {
                      return AppTable<T>(
                        items: items,
                        columns: [
                          ...columns,
                          AppTableColumnWidget(
                            title: '',
                            width: FixedColumnWidth(48),
                            dataSelector:
                                (item) => IconButton(
                              onPressed: () {
                                context.pop(item);
                              },
                              icon: Icon(Icons.chevron_right),
                            ),
                          ),
                        ],
                        maxWidth: 500,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
