import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:posyandu_app/data/models/response/perkembangan_balita/perkembangan_item.dart';
import 'package:posyandu_app/data/models/response/perkembangan_balita/perkembangan_khusus_item.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xls;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';

class LaporanPosyandu {
  static Future<Uint8List> generateExcel({
    required List<PerkembanganItem> detail,
    required int bulanMulai,
    required int bulanSelesai,
  }) async {
    final workbook = xls.Workbook();
    final sheet = workbook.worksheets[0];

    final headers = [
      "NO",
      "ANAK KE",
      "L/P",
      "NIK",
      "NAMA ANAK",
      "NAMA ORTU",
      "NIK ORTU",
      "HP ORTU",
      "ALAMAT",
      "RT",
      "RW",
    ];

    for (int i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
      sheet.getRangeByIndex(1, i + 1, 2, i + 1).merge();
    }

    int col = 12;
    for (int b = bulanMulai; b <= bulanSelesai; b++) {
      String bulanNama = DateFormat.MMMM(
        "id_ID",
      ).dateSymbols.MONTHS[b - 1].toUpperCase();
      sheet.getRangeByIndex(1, col, 1, col + 3).merge();
      sheet.getRangeByIndex(1, col).setText(bulanNama);
      sheet.getRangeByIndex(2, col).setText("LL");
      sheet.getRangeByIndex(2, col + 1).setText("LK");
      sheet.getRangeByIndex(2, col + 2).setText("TB");
      sheet.getRangeByIndex(2, col + 3).setText("BB");
      col += 4;
    }

    int row = 3;
    for (int i = 0; i < detail.length; i++) {
      final d = detail[i];
      sheet.getRangeByIndex(row, 1).setNumber(i + 1);
      sheet.getRangeByIndex(row, 2).setText(d.anakKe);
      sheet.getRangeByIndex(row, 3).setText(d.jenisKelamin);
      sheet.getRangeByIndex(row, 4).setText(d.nik);
      sheet.getRangeByIndex(row, 5).setText(d.nama);
      sheet.getRangeByIndex(row, 6).setText(d.namaOrtu);
      sheet.getRangeByIndex(row, 7).setText(d.nikOrtu);
      sheet.getRangeByIndex(row, 8).setText(d.nomorHpOrtu);
      sheet.getRangeByIndex(row, 9).setText(d.alamat);
      sheet.getRangeByIndex(row, 10).setText(d.rt);
      sheet.getRangeByIndex(row, 11).setText(d.rw);

      int c = 12;
      for (int b = bulanMulai; b <= bulanSelesai; b++) {
        sheet
            .getRangeByIndex(row, c)
            .setText(
              d.getLingkarLengan(b) > 0
                  ? d.getLingkarLengan(b).toStringAsFixed(1)
                  : "-",
            );
        sheet
            .getRangeByIndex(row, c + 1)
            .setText(
              d.getLingkarKepala(b) > 0
                  ? d.getLingkarKepala(b).toStringAsFixed(1)
                  : "-",
            );
        sheet
            .getRangeByIndex(row, c + 2)
            .setText(
              d.getTinggiBadan(b) > 0
                  ? d.getTinggiBadan(b).toStringAsFixed(0)
                  : "-",
            );
        sheet
            .getRangeByIndex(row, c + 3)
            .setText(
              d.getBeratBadan(b) > 0
                  ? d.getBeratBadan(b).toStringAsFixed(1)
                  : "-",
            );
        c += 4;
      }
      row++;
    }

    final bytes = workbook.saveAsStream();
    workbook.dispose();
    return Uint8List.fromList(bytes);
  }

  static Future<Uint8List> generatePdf({
    required List<PerkembanganItem> detail,
    required int bulanMulai,
    required int bulanSelesai,
    required String bulanNama,
    required int tahun,
  }) async {
    if (bulanMulai <= 6) {
      bulanMulai = 1;
      bulanSelesai = 6;
    } else {
      bulanMulai = 7;
      bulanSelesai = 12;
    }

    final PdfDocument doc = PdfDocument();
    doc.pageSettings.orientation = PdfPageOrientation.landscape;
    doc.pageSettings.size = PdfPageSize.a3;

    final PdfFont fontHeader = PdfStandardFont(
      PdfFontFamily.helvetica,
      8,
      style: PdfFontStyle.bold,
    );
    final PdfFont fontCell = PdfStandardFont(PdfFontFamily.helvetica, 8);

    final PdfGridCellStyle headerStyle = PdfGridCellStyle(
      font: fontHeader,
      textBrush: PdfBrushes.black,
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
      borders: PdfBorders(
        left: PdfPen(PdfColor(0, 0, 0), width: 0.4),
        right: PdfPen(PdfColor(0, 0, 0), width: 0.4),
        top: PdfPen(PdfColor(0, 0, 0), width: 0.4),
        bottom: PdfPen(PdfColor(0, 0, 0), width: 0.4),
      ),
    );

    final PdfGridCellStyle cellStyle = PdfGridCellStyle(
      font: fontCell,
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
      borders: PdfBorders(
        left: PdfPen(PdfColor(0, 0, 0), width: 0.4),
        right: PdfPen(PdfColor(0, 0, 0), width: 0.4),
        top: PdfPen(PdfColor(0, 0, 0), width: 0.4),
        bottom: PdfPen(PdfColor(0, 0, 0), width: 0.4),
      ),
    );

    List<String> headerUtama = [
      "NO",
      "ANAK KE",
      "TGL LAHIR",
      "L/P",
      "NIK",
      "NAMA ANAK",
      "NAMA ORTU",
      "NIK ORTU",
      "HP ORTU",
      "ALAMAT",
      "RT",
      "RW",
    ];

    const int maxRowsPerPage = 20;
    final int totalPages = (detail.length / maxRowsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      final PdfPage page = doc.pages.add();
      final PdfGrid grid = PdfGrid();

      final int totalColumns =
          headerUtama.length + (bulanSelesai - bulanMulai + 1) * 4;
      grid.columns.add(count: totalColumns);

      final List<double> baseWidths = [
        20.0,
        26.0,
        55.0,
        26.0,
        80.0,
        80.0,
        80.0,
        80.0,
        60.0,
        70.0,
        20.0,
        20.0,
      ];

      int wIndex = 0;
      for (double w in baseWidths) {
        if (wIndex < grid.columns.count) {
          grid.columns[wIndex].width = w;
        }
        wIndex++;
      }

      const double small = 20.0;
      for (int m = bulanMulai; m <= bulanSelesai; m++) {
        if (wIndex < grid.columns.count) grid.columns[wIndex++].width = small;
        if (wIndex < grid.columns.count) grid.columns[wIndex++].width = small;
        if (wIndex < grid.columns.count) grid.columns[wIndex++].width = small;
        if (wIndex < grid.columns.count) grid.columns[wIndex++].width = small;
      }

      final header = grid.headers.add(2);
      final PdfGridRow h1 = header[0];
      final PdfGridRow h2 = header[1];

      h1.height = 18;
      h2.height = 18;

      int col = 0;
      for (var h in headerUtama) {
        h1.cells[col].value = h;
        h1.cells[col].rowSpan = 2;
        h1.cells[col].style = headerStyle;
        h2.cells[col].value = "";
        col++;
      }

      for (int b = bulanMulai; b <= bulanSelesai; b++) {
        final String namaBulan = DateFormat.MMMM(
          "id_ID",
        ).dateSymbols.MONTHS[b - 1].toUpperCase();

        h1.cells[col].value = namaBulan;
        h1.cells[col].columnSpan = 4;
        h1.cells[col].style = headerStyle;

        h2.cells[col].value = "LL";
        h2.cells[col + 1].value = "LK";
        h2.cells[col + 2].value = "TB";
        h2.cells[col + 3].value = "BB";

        h2.cells[col].style = headerStyle;
        h2.cells[col + 1].style = headerStyle;
        h2.cells[col + 2].style = headerStyle;
        h2.cells[col + 3].style = headerStyle;

        col += 4;
      }

      final int startIndex = pageIndex * maxRowsPerPage;
      final int endIndex = (pageIndex == totalPages - 1)
          ? detail.length
          : startIndex + maxRowsPerPage;

      for (int idx = startIndex; idx < endIndex; idx++) {
        final PerkembanganItem d = detail[idx];
        final PdfGridRow row = grid.rows.add();
        row.height = 25;

        int c = 0;
        row.cells[c++].value = (idx + 1).toString();
        row.cells[c++].value = d.anakKe;

        String formattedTanggal = "-";
        try {
          final DateTime dt = DateTime.parse(d.tanggalLahir);
          formattedTanggal = DateFormat("dd/MM/yyyy").format(dt);
        } catch (_) {
          formattedTanggal = d.tanggalLahir;
        }
        row.cells[c++].value = formattedTanggal;

        row.cells[c++].value =
            d.jenisKelamin.trim().toUpperCase().startsWith("L") ? "L" : "P";
        row.cells[c++].value = d.nik;
        row.cells[c++].value = d.nama;
        row.cells[c++].value = d.namaOrtu;
        row.cells[c++].value = d.nikOrtu;
        row.cells[c++].value = d.nomorHpOrtu;
        row.cells[c++].value = d.alamat;
        row.cells[c++].value = d.rt;
        row.cells[c++].value = d.rw;

        for (int b = bulanMulai; b <= bulanSelesai; b++) {
          final ll = d.getLingkarLengan(b);
          final lk = d.getLingkarKepala(b);
          final tb = d.getTinggiBadan(b);
          final bb = d.getBeratBadan(b);

          row.cells[c++].value = ll > 0 ? ll.toStringAsFixed(1) : "-";
          row.cells[c++].value = lk > 0 ? lk.toStringAsFixed(1) : "-";
          row.cells[c++].value = tb > 0 ? tb.toStringAsFixed(0) : "-";
          row.cells[c++].value = bb > 0 ? bb.toStringAsFixed(1) : "-";
        }

        for (int x = 0; x < row.cells.count; x++) {
          row.cells[x].style = cellStyle;
        }
      }

      final String titleText =
          "LAPORAN PENIMBANGAN BALITA\nPOSYANDU DAHLIA X\nPERIODE : ${bulanNama.toUpperCase()} $tahun";

      page.graphics.drawString(
        titleText,
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(0, 10, page.getClientSize().width, 60),
      );

      grid.draw(
        page: page,
        bounds: Rect.fromLTWH(
          5,
          80,
          page.getClientSize().width - 40,
          page.getClientSize().height - 80,
        ),
      );
    }

    final List<int> bytes = await doc.save();
    doc.dispose();
    return Uint8List.fromList(bytes);
  }

  static Future<Uint8List> generatePdfKhusus({
    required List<PerkembanganKhususItem> data,
    required String bulanNama,
    required int tahun,
  }) async {
    final PdfDocument doc = PdfDocument();
    doc.pageSettings.orientation = PdfPageOrientation.landscape;
    doc.pageSettings.size = PdfPageSize.a3;

    final PdfFont fontHeader = PdfStandardFont(
      PdfFontFamily.helvetica,
      9,
      style: PdfFontStyle.bold,
    );
    final PdfFont fontCell = PdfStandardFont(PdfFontFamily.helvetica, 9);

    final PdfGridCellStyle headerStyle = PdfGridCellStyle(
      font: fontHeader,
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
      borders: PdfBorders(
        left: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        right: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        top: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        bottom: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      ),
    );

    final PdfGridCellStyle cellStyle = PdfGridCellStyle(
      font: fontCell,
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
      borders: PdfBorders(
        left: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        right: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        top: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        bottom: PdfPen(PdfColor(0, 0, 0), width: 0.5),
      ),
    );

    const int maxRowsPerPage = 20;
    final int totalPages = (data.length / maxRowsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      final page = doc.pages.add();
      final grid = PdfGrid();
      grid.columns.add(count: 20);

      final widths = [
        20,
        35,
        55,
        25,
        85,
        85,
        90,
        40,
        40,
        40,
        40,
        55,
        40,
        40,
        40,
        40,
        80,
        85,
        60,
        110,
      ];

      for (int i = 0; i < widths.length; i++) {
        grid.columns[i].width = widths[i].toDouble();
      }

      final header = grid.headers.add(2);
      final h1 = header[0];
      final h2 = header[1];

      h1.height = 22;
      h2.height = 22;

      final noMerge = {
        0: "NO",
        1: "Anak Ke",
        2: "TGL LAHIR",
        3: "JK",
        4: "NO KK",
        5: "NIK BALITA",
        6: "NAMA BALITA",
        11: "CARA UKUR",
        12: "KMS",
        13: "IMD",
        14: "ASI EKS",
        15: "VIT A",
        16: "NAMA ORANG TUA",
        17: "NIK ORANG TUA",
        18: "NO HP",
        19: "ALAMAT LENGKAP",
      };

      noMerge.forEach((index, text) {
        h1.cells[index].value = text;
        h1.cells[index].rowSpan = 2;
        h1.cells[index].style = headerStyle;
      });

      h1.cells[7].value = "BB";
      h1.cells[7].columnSpan = 2;
      h1.cells[7].style = headerStyle;

      h2.cells[7].value = "Lahir";
      h2.cells[8].value = "Bulan Ini";

      h2.cells[7].style = headerStyle;
      h2.cells[8].style = headerStyle;

      h1.cells[9].value = "TB&PB";
      h1.cells[9].columnSpan = 2;
      h1.cells[9].style = headerStyle;

      h2.cells[9].value = "Lahir";
      h2.cells[10].value = "Bulan Ini";

      h2.cells[9].style = headerStyle;
      h2.cells[10].style = headerStyle;

      final int start = pageIndex * maxRowsPerPage;
      final int end = (pageIndex == totalPages - 1)
          ? data.length
          : start + maxRowsPerPage;

      for (int i = start; i < end; i++) {
        final d = data[i];
        final row = grid.rows.add();
        row.height = 28;

        String tgl = "-";
        try {
          tgl = DateFormat("dd/MM/yyyy").format(DateTime.parse(d.tanggalLahir));
        } catch (_) {
          tgl = d.tanggalLahir;
        }

        final kms = (d.kms != null && d.kms.trim().isNotEmpty) ? d.kms : "-";

        row.cells[0].value = (i + 1).toString();
        row.cells[1].value = d.anakKe;
        row.cells[2].value = tgl;
        row.cells[3].value = d.jenisKelamin;
        row.cells[4].value = d.noKk;
        row.cells[5].value = d.nik;
        row.cells[6].value = d.nama;

        row.cells[7].value = d.bbLahir.isEmpty ? "-" : d.bbLahir;
        row.cells[8].value = d.bbBulanIni.toString();

        row.cells[9].value = d.tbLahir.isEmpty ? "-" : d.tbLahir;
        row.cells[10].value = d.tbBulanIni.toString();

        row.cells[11].value = d.caraUkur;
        row.cells[12].value = kms;
        row.cells[13].value = d.imd;
        row.cells[14].value = d.asiEks;
        row.cells[15].value = d.vitaminA;

        row.cells[16].value = d.namaOrtu;
        row.cells[17].value = d.nikOrtu;
        row.cells[18].value = d.nomorHpOrtu;
        row.cells[19].value = d.alamat;

        for (int c = 0; c < row.cells.count; c++) {
          row.cells[c].style = cellStyle;
        }
      }

      page.graphics.drawString(
        "LAPORAN BULANAN KHUSUS BALITA\nPOSYANDU DAHLIA X\nBULAN ${bulanNama.toUpperCase()} $tahun",
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(0, 10, page.getClientSize().width, 60),
      );

      grid.draw(
        page: page,
        bounds: Rect.fromLTWH(
          5,
          80,
          page.getClientSize().width - 10,
          page.getClientSize().height - 80,
        ),
      );
    }

    final bytes = await doc.save();
    doc.dispose();
    return Uint8List.fromList(bytes);
  }

  static Future<File> saveAndShare(Uint8List bytes, String fileName) async {
    final dir =
        await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$fileName");
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: "Laporan Posyandu $fileName");

    return file;
  }
}
