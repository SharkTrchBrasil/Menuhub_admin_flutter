part of 'add_option_cubit.dart';

// Enum para controlar o passo atual do wizard
enum AddOptionStep { initialChoice, creationForm, copyList }

// Enum para o status do formulário (você já deve ter um parecido)
enum FormStatus { initial, loading, success, error }

class AddOptionState extends Equatable {
  final AddOptionStep step;
  final FormStatus status;
  final VariantOption? result; // Onde guardamos o complemento criado

  const AddOptionState({
    this.step = AddOptionStep.initialChoice,
    this.status = FormStatus.initial,
    this.result,
  });

  AddOptionState copyWith({
    AddOptionStep? step,
    FormStatus? status,
    VariantOption? result,
  }) {
    return AddOptionState(
      step: step ?? this.step,
      status: status ?? this.status,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [step, status, result];
}