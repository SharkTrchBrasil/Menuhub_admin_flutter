import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:totem_pro_admin/widgets/ds_primary_button.dart';

import 'cubit/menu_scan_cubit.dart';

class MenuScanWidget extends StatelessWidget {
  const MenuScanWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuScanCubit, MenuScanState>(
      builder: (context, state) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildContentForState(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContentForState(BuildContext context, MenuScanState state) {
    switch (state.runtimeType) {
      case MenuScanUploading:
        final progress = (state as MenuScanUploading).progress;
        return _UploadingView(key: const ValueKey('uploading'), progress: progress);

      case MenuScanProcessing:
        final message = (state as MenuScanProcessing).message;
        return _ProcessingView(key: const ValueKey('processing'), message: message);

      case MenuScanError:
        final message = (state as MenuScanError).message;
        return _ErrorView(key: const ValueKey('error'), message: message);

      case MenuScanInitial:
      default:
        return _InitialView(key: const ValueKey('initial'));
    }
  }
}

// View Inicial: Botão para selecionar imagens
class _InitialView extends StatelessWidget {
  const _InitialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.camera_alt_outlined, size: 80, color: Colors.grey),
        const SizedBox(height: 24),
        Text(
          'Automático com Fotos (IA)',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Envie uma ou mais fotos nítidas do seu cardápio. Nossa inteligência artificial fará a leitura e o cadastro para você.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        DsButton(
          label: 'Selecionar Imagens',
          icon: Icons.upload_file,
          onPressed: () {
            context.read<MenuScanCubit>().pickAndUploadImages();
          },
        ),
      ],
    );
  }
}

// View de Upload: Mostra o progresso
class _UploadingView extends StatelessWidget {
  final double progress;
  const _UploadingView({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Enviando imagens...',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor),
        ),
      ],
    );
  }
}

// View de Processamento: Avisa que a IA está trabalhando
class _ProcessingView extends StatelessWidget {
  final String message;
  const _ProcessingView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.psychology_outlined, size: 80, color: Colors.blue),
        const SizedBox(height: 24),
        Text(
          'Processando Cardápio',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Isso pode levar alguns instantes. Você pode avançar para a próxima etapa enquanto aguarda.',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// View de Erro: Mostra a falha e permite tentar de novo
class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 80, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: 24),
        Text(
          'Ocorreu um Erro',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        DsButton(
          label: 'Tentar Novamente',
          icon: Icons.refresh,
          style: DsButtonStyle.secondary,
          onPressed: () {
            context.read<MenuScanCubit>().reset();
          },
        ),
      ],
    );
  }
}