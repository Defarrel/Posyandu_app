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

  final Map<String, dynamic> perkembanganBulanan;

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
    required this.perkembanganBulanan,
  });

  double getBeratBadan(int bulan) {
    final dataBulan = perkembanganBulanan[bulan.toString()];
    return dataBulan != null ? (dataBulan['bb'] ?? 0.0).toDouble() : 0.0;
  }

  double getTinggiBadan(int bulan) {
    final dataBulan = perkembanganBulanan[bulan.toString()];
    return dataBulan != null ? (dataBulan['tb'] ?? 0.0).toDouble() : 0.0;
  }

  double getLingkarLengan(int bulan) {
    final dataBulan = perkembanganBulanan[bulan.toString()];
    return dataBulan != null ? (dataBulan['ll'] ?? 0.0).toDouble() : 0.0;
  }

  double getLingkarKepala(int bulan) {
    final dataBulan = perkembanganBulanan[bulan.toString()];
    return dataBulan != null ? (dataBulan['lk'] ?? 0.0).toDouble() : 0.0;
  }
}

class LaporanBulananPdf {
  static final _tglFmt = DateFormat("dd/MM/yy");

  static Future<Uint8List> buildPdf({
    required int tahun,
    required int semester,
    required int bulanMulai,
    required int bulanSelesai,
    required List<PerkembanganItem> detail,
    required bool isBulanKhusus,
  }) async {
    if (isBulanKhusus) {
      return _buildLaporanKhususPdf(tahun, bulanMulai, detail);
    } else {
      return _buildLaporanSemesterPdf(
        tahun: tahun,
        semester: semester,
        bulanMulai: bulanMulai,
        bulanSelesai: bulanSelesai,
        detail: detail,
      );
    }
  }

  static Future<Uint8List> _buildLaporanSemesterPdf({
    required int tahun,
    required int semester,
    required int bulanMulai,
    required int bulanSelesai,
    required List<PerkembanganItem> detail,
  }) async {
    final pdf = pw.Document();

    final bulanNamaMulai = DateFormat.MMMM(
      "id_ID",
    ).dateSymbols.MONTHS[bulanMulai - 1];
    final bulanNamaSelesai = DateFormat.MMMM(
      "id_ID",
    ).dateSymbols.MONTHS[bulanSelesai - 1];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(10),
        build: (context) => [
          pw.Text(
            "LAPORAN PENIMBANGAN BALITA",
            style: pw.TextStyle(fontSize: 8),
          ),
          pw.SizedBox(height: 4),
          pw.Text("POSYANDU DAHLIA X", style: pw.TextStyle(fontSize: 8)),
          pw.SizedBox(height: 4),
          pw.Text(
            "Periode ($bulanNamaMulai - $bulanNamaSelesai $tahun)",
            style: const pw.TextStyle(fontSize: 8),
          ),
          pw.SizedBox(height: 10),

          _buildTabelUtama(detail, bulanMulai, bulanSelesai),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildTabelUtama(
    List<PerkembanganItem> detail,
    int bulanMulai,
    int bulanSelesai,
  ) {
    final bulanList = DateFormat.MMMM("id_ID").dateSymbols.MONTHS;

    final rows = <pw.Widget>[];

    const perPage = 20;
    final totalPages = (detail.length / perPage).ceil();

    for (int page = 0; page < totalPages; page++) {
      final start = page * perPage;
      final end = (start + perPage > detail.length)
          ? detail.length
          : start + perPage;
      final chunk = detail.sublist(start, end);

      rows.add(
        pw.Table(
          border: pw.TableBorder.all(width: 0.5),
          columnWidths: _getColumnWidths(bulanMulai, bulanSelesai),
          children: [
            _buildHeaderRow1(bulanMulai, bulanSelesai, bulanList),
            _buildHeaderRow2(bulanMulai, bulanSelesai),
            ..._buildDataRows(chunk, bulanMulai, bulanSelesai),
          ],
        ),
      );

      rows.add(pw.SizedBox(height: 30));
    }

    return pw.Column(children: rows);
  }

  static pw.TableRow _buildHeaderRow1(
    int bulanMulai,
    int bulanSelesai,
    List<String> bulanList,
  ) {
    final cells = <pw.Widget>[
      _headerCell("NO", 1),
      _headerCell("ANAK\nKE", 1),
      _headerCell("L/P", 1),
      _headerCell("NIK", 1),
      _headerCell("NAMA ANAK", 1),
      _headerCell("NAMA ORTU", 1),
      _headerCell("NIK ORTU", 1),
      _headerCell("HP ORTU", 1),
      _headerCell("ALAMAT", 1),
      _headerCell("RT", 1),
      _headerCell("RW", 1),
    ];

    for (int b = bulanMulai; b <= bulanSelesai; b++) {
      cells.add(
        pw.Container(
          width: 56,
          padding: const pw.EdgeInsets.all(2),
          child: pw.Center(
            child: pw.Text(
              bulanList[b - 1].toUpperCase(),
              style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ),
      );
    }

    return pw.TableRow(children: cells);
  }

  static pw.TableRow _buildHeaderRow2(int bulanMulai, int bulanSelesai) {
    final cells = <pw.Widget>[for (int i = 0; i < 11; i++) pw.Container()];

    for (int b = bulanMulai; b <= bulanSelesai; b++) {
      cells.addAll([
        _subHeaderCell("LL"),
        _subHeaderCell("LK"),
        _subHeaderCell("TB"),
        _subHeaderCell("BB"),
      ]);
    }

    return pw.TableRow(children: cells);
  }

  static List<pw.TableRow> _buildDataRows(
    List<PerkembanganItem> detail,
    int bulanMulai,
    int bulanSelesai,
  ) {
    return detail.asMap().entries.map((entry) {
      final i = entry.key;
      final d = entry.value;

      String lp = d.jenisKelamin.toUpperCase().startsWith("L") ? "L" : "P";

      final cells = <pw.Widget>[
        _dataCell("${i + 1}"),
        _dataCell(d.anakKe),
        _dataCell(lp),
        _dataCell(d.nik),
        _dataCell(d.nama),
        _dataCell(d.namaOrtu),
        _dataCell(d.nikOrtu),
        _dataCell(d.nomorHpOrtu),
        _dataCell(d.alamat),
        _dataCell(d.rt),
        _dataCell(d.rw),
      ];

      for (int b = bulanMulai; b <= bulanSelesai; b++) {
        final ll = d.getLingkarLengan(b);
        final lk = d.getLingkarKepala(b);
        final tb = d.getTinggiBadan(b);
        final bb = d.getBeratBadan(b);

        cells.addAll([
          _dataCellSmall(ll > 0 ? ll.toStringAsFixed(1) : "-"),
          _dataCellSmall(lk > 0 ? lk.toStringAsFixed(1) : "-"),
          _dataCellSmall(tb > 0 ? tb.toStringAsFixed(0) : "-"),
          _dataCellSmall(bb > 0 ? bb.toStringAsFixed(1) : "-"),
        ]);
      }

      return pw.TableRow(children: cells);
    }).toList();
  }

  static pw.Widget _headerCell(String text, int colspan) {
    return pw.Container(
      width: colspan * 14.0,
      padding: const pw.EdgeInsets.all(2),
      child: pw.Center(
        child: pw.Text(
          text,
          style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  static pw.Widget _subHeaderCell(String text) {
    return pw.Container(
      width: 14,
      padding: const pw.EdgeInsets.all(1),
      child: pw.Center(
        child: pw.Text(
          text,
          style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
          textAlign: pw.TextAlign.center,
        ),
      ),
    );
  }

  static pw.Widget _dataCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(1),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 6),
        textAlign: pw.TextAlign.center,
        maxLines: 2,
      ),
    );
  }

  static pw.Widget _dataCellSmall(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(1),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 5),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static Map<int, pw.TableColumnWidth> _getColumnWidths(
    int bulanMulai,
    int bulanSelesai,
  ) {
    final widths = <int, pw.TableColumnWidth>{
      0: const pw.FixedColumnWidth(10),
      1: const pw.FixedColumnWidth(12),
      2: const pw.FixedColumnWidth(8),
      3: const pw.FixedColumnWidth(25),
      4: const pw.FixedColumnWidth(30),
      5: const pw.FixedColumnWidth(30),
      6: const pw.FixedColumnWidth(25),
      7: const pw.FixedColumnWidth(20),
      8: const pw.FixedColumnWidth(40),
      9: const pw.FixedColumnWidth(8),
      10: const pw.FixedColumnWidth(8),
    };

    int colIndex = 11;
    for (int b = bulanMulai; b <= bulanSelesai; b++) {
      for (int i = 0; i < 4; i++) {
        widths[colIndex++] = const pw.FixedColumnWidth(14);
      }
    }

    return widths;
  }

  static Future<Uint8List> _buildLaporanKhususPdf(
    int tahun,
    int bulan,
    List<PerkembanganItem> detail,
  ) async {
    final pdf = pw.Document();
    final bulanNama = DateFormat.MMMM("id_ID").dateSymbols.MONTHS[bulan - 1];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a3.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          pw.Center(
            child: pw.Text(
              "LAPORAN KHUSUS BULAN $bulanNama $tahun",
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            "Laporan khusus untuk bulan $bulanNama $tahun",
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            "Total data: ${detail.length} balita",
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );

    return pdf.save();
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
