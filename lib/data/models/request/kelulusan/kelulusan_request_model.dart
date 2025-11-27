class KelulusanRequestModel {
  final String status;     
  final String? keterangan; 

  KelulusanRequestModel({
    required this.status,
    this.keterangan,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (keterangan != null && keterangan!.isNotEmpty)
        'keterangan': keterangan,
    };
  }
}
