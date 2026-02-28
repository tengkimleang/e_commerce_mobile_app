class PartnerPrivilegeState {
  final List<String> partnerImages;
  final int currentIndex;
  final bool isLoading;
  final String? errorMessage;

  const PartnerPrivilegeState({
    required this.partnerImages,
    required this.currentIndex,
    required this.isLoading,
    this.errorMessage,
  });

  const PartnerPrivilegeState.initial()
    : partnerImages = const [],
      currentIndex = 0,
      isLoading = true,
      errorMessage = null;

  PartnerPrivilegeState copyWith({
    List<String>? partnerImages,
    int? currentIndex,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PartnerPrivilegeState(
      partnerImages: partnerImages ?? this.partnerImages,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
