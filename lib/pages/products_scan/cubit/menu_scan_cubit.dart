import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';

part 'menu_scan_state.dart';

class MenuScanCubit extends Cubit<MenuScanState> {
  final ProductRepository _productRepository;
  final int storeId;

  MenuScanCubit({
    required this.storeId,
    required ProductRepository productRepository,
  })  : _productRepository = productRepository,
        super(const MenuScanInitial());

  Future<void> pickAndUploadImages() async {
    // 1. Selecionar as imagens
    final imagePicker = ImagePicker();
    final List<XFile> pickedFiles = await imagePicker.pickMultiImage();

    if (pickedFiles.isEmpty) {
      return; // Usuário cancelou a seleção
    }

    emit(MenuScanUploading(progress: 0.0));

    // 2. Fazer o upload
    final result = await _productRepository.importMenuFromImages(
      storeId: storeId,
      imageFiles: pickedFiles,
      onSendProgress: (sent, total) {
        if (total > 0) {
          final progress = sent / total;
          emit(MenuScanUploading(progress: progress));
        }
      },
    );

    // 3. Tratar o resultado
    result.fold(
          (failure) => emit(MenuScanError(message: failure)),
          (successMessage) => emit(MenuScanProcessing(message: successMessage)),
    );
  }

  void reset() {
    emit(const MenuScanInitial());
  }
}