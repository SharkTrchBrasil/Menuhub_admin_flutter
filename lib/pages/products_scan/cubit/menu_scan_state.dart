part of 'menu_scan_cubit.dart';

abstract class MenuScanState extends Equatable {
  const MenuScanState();

  @override
  List<Object> get props => [];
}

// Estado inicial: esperando o usuário clicar
class MenuScanInitial extends MenuScanState {
  const MenuScanInitial();
}

// Estado de upload: enviando as imagens para o backend
class MenuScanUploading extends MenuScanState {
  final double progress; // Progresso de 0.0 a 1.0

  const MenuScanUploading({required this.progress});

  @override
  List<Object> get props => [progress];
}

// Estado de processamento: backend recebeu e a IA está trabalhando
class MenuScanProcessing extends MenuScanState {
  final String message;

  const MenuScanProcessing({required this.message});

  @override
  List<Object> get props => [message];
}

// Estado de sucesso: o backend terminou e notificou (será implementado no futuro com WebSockets)
// Por enquanto, o estado 'Processing' é o final da nossa lógica de upload.
class MenuScanSuccess extends MenuScanState {
  final String message;

  const MenuScanSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

// Estado de erro: algo deu errado
class MenuScanError extends MenuScanState {
  final String message;

  const MenuScanError({required this.message});

  @override
  List<Object> get props => [message];
}