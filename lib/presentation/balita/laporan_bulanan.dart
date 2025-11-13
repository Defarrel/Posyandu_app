import 'dart:typed_data';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class PerkembanganItem {
  final String nama;
  final String nik;
  final String jenisKelamin;
  final String tanggalLahir; 
  final String anakKe;
  final String namaOrtu;
  final String nikOrtu;
  final String nomorHpOrtu;
  final String alamat;
  final String rt;
  final String rw;

  final double berat;
  final double tinggi;
  final double lingkarLengan;
  final double lingkarKepala;

  final String kms;
  final String vitaminA;
  final String imd;
  final String asiEks;

  PerkembanganItem({
    required this.nama,
    required this.nik,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.anakKe,
    required this.namaOrtu,
    required this.nikOrtu,
    required this.nomorHpOrtu,
    required this.alamat,
    required this.rt,
    required this.rw,
    required this.berat,
    required this.tinggi,
    required this.lingkarLengan,
    required this.lingkarKepala,
    required this.kms,
    required this.vitaminA,
    required this.imd,
    required this.asiEks,
  });
}

class LaporanBulananPdf {
  static final _tglFmt = DateFormat("dd/MM/yy");

  static Future<Uint8List> buildPdf({
    required int bulanIndex,
    required int tahun,
    required List<PerkembanganItem> detail,
    required bool includeScannerColumns,
  }) async {
    final pdf = pw.Document();
    final bulanNama = DateFormat.MMMM(
      "id_ID",
    ).dateSymbols.MONTHS[bulanIndex - 1];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a3.landscape, 
        orientation: pw.PageOrientation.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          pw.Text(
            "LAPORAN PENIMBANGAN BALITA",
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            "Posyandu Dahlia X - Bulan $bulanNama $tahun",
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 20),

          _buildTable(detail, includeScannerColumns),

          pw.SizedBox(height: 35),

          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text("Kader Posyandu,"),
                pw.SizedBox(height: 50),
                pw.Text("______________________________"),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildTable(
    List<PerkembanganItem> detail,
    bool includeScanner,
  ) {
    final headers = _getHeaders(includeScanner);
    final rows = _getRows(detail, includeScanner);

    return pw.Table.fromTextArray(
      headers: headers,
      data: rows,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellAlignment: pw.Alignment.center,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
      cellStyle: const pw.TextStyle(fontSize: 9),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5),
        1: const pw.FlexColumnWidth(1.6),
        2: const pw.FlexColumnWidth(2.3),
        3: const pw.FlexColumnWidth(0.9),
        4: const pw.FlexColumnWidth(1.3),
        5: const pw.FlexColumnWidth(0.7),
        6: const pw.FlexColumnWidth(2.2),
        7: const pw.FlexColumnWidth(1.7),
        8: const pw.FlexColumnWidth(1.7),
        9: const pw.FlexColumnWidth(2.0),
        10: const pw.FlexColumnWidth(0.7),
        11: const pw.FlexColumnWidth(0.7),
        12: const pw.FlexColumnWidth(0.9),
        13: const pw.FlexColumnWidth(0.9),
        14: const pw.FlexColumnWidth(0.9),
        15: const pw.FlexColumnWidth(0.9),
        16: const pw.FlexColumnWidth(0.9),
        if (includeScanner) 17: const pw.FlexColumnWidth(1.0),
        if (includeScanner) 18: const pw.FlexColumnWidth(1.0),
        if (includeScanner) 19: const pw.FlexColumnWidth(1.0),
      },
    );
  }

  static List<String> _getHeaders(bool includeScanner) {
    final base = [
      "No",
      "NIK",
      "Nama Balita",
      "JK",
      "Tgl Lahir",
      "Anak ke",
      "Nama Ortu",
      "NIK Ortu",
      "No HP",
      "Alamat",
      "RT",
      "RW",
      "BB",
      "TB",
      "LL",
      "LK",
      "KMS",
    ];

    if (includeScanner) base.addAll(["Vit A", "IMD", "ASI Eks"]);
    return base;
  }

  static List<List<String>> _getRows(
    List<PerkembanganItem> detail,
    bool includeScanner,
  ) {
    return detail.asMap().entries.map((entry) {
      final i = entry.key;
      final d = entry.value;

      final formattedTanggal = _formatDate(d.tanggalLahir);

      final row = [
        "${i + 1}",
        d.nik,
        d.nama,
        d.jenisKelamin,
        formattedTanggal, 
        d.anakKe,
        d.namaOrtu,
        d.nikOrtu,
        d.nomorHpOrtu,
        d.alamat,
        d.rt,
        d.rw,
        d.berat.toStringAsFixed(1),
        d.tinggi.toStringAsFixed(1),
        d.lingkarLengan.toStringAsFixed(1),
        d.lingkarKepala.toStringAsFixed(1),
        d.kms,
      ];

      if (includeScanner) {
        row.addAll([d.vitaminA, d.imd, d.asiEks]);
      }

      return row;
    }).toList();
  }

  static String _formatDate(String tgl) {
    try {
      final parsed = DateTime.parse(tgl);
      return _tglFmt.format(parsed);
    } catch (e) {
      return tgl;
    }
  }

  static Future<void> downloadPdf(Uint8List bytes, String fileName) async {
    try {
      final dir =
          await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/$fileName");

      await file.writeAsBytes(bytes);

      await Printing.sharePdf(bytes: bytes, filename: fileName);
    } catch (e) {
      print("Error saving PDF: $e");
    }
  }
}
