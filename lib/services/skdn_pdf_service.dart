import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class SkdnDataModel {
  final String bulan;
  final int s;
  final int k;
  final int d;
  final int n;
  final int jumlahLulus;
  final int jumlahS36;

  SkdnDataModel({
    required this.bulan,
    required this.s,
    required this.k,
    required this.d,
    required this.n,
    required this.jumlahLulus,
    required this.jumlahS36,
  });
}

class LaporanSkdnService {
  static Future<Uint8List> generateSkdnPdf({
    required List<SkdnDataModel> data,
    required String namaPosyandu,
    required String tahun,
  }) async {
    final PdfDocument document = PdfDocument();
    document.pageSettings.orientation = PdfPageOrientation.landscape;
    document.pageSettings.margins.all = 10;

    final PdfPage page = document.pages.add();
    final Size pageSize = page.getClientSize();
    final PdfGraphics g = page.graphics;

    // HEADER JUDUL
    double yPos = 0;
    final PdfFont fontTitle = PdfStandardFont(
      PdfFontFamily.helvetica,
      14,
      style: PdfFontStyle.bold,
    );
    final PdfFont fontSubtitle = PdfStandardFont(
      PdfFontFamily.helvetica,
      10,
      style: PdfFontStyle.bold,
    );

    _drawTextCenter(page, "\"BALOK SKDN\"", fontTitle, yPos, pageSize.width);
    yPos += 16;
    _drawTextCenter(
      page,
      "(TINGKAT PENCAPAIAN PROGRAM UPGK)",
      PdfStandardFont(PdfFontFamily.helvetica, 10),
      yPos,
      pageSize.width,
    );
    yPos += 16;
    _drawTextCenter(page, "TAHUN : $tahun", fontSubtitle, yPos, pageSize.width);
    yPos += 20;

    //KONFIGURASI LAYOUT
    double rowLabelHeight = 15; // Tinggi label Bulan
    double contentStartY =
        yPos + rowLabelHeight; // Mulai konten setelah label Bulan

    double sidebarWidth = 150;
    double contentWidth = pageSize.width - sidebarWidth;
    double totalMonths = 12;
    // Tentukan gap antar bulan horizontal
    double gapHorizontalMonth = 5.0;
    // Hitung lebar total per kolom bulan (termasuk gap)
    double monthColumnWidth = contentWidth / totalMonths;
    // Lebar yang digunakan untuk Box konten (Chart, Data, Persen)
    double contentBoxWidth = monthColumnWidth - gapHorizontalMonth;

    // Lebar kolom data (SKDN, Persen) yang sebenarnya per bulan (dikurangi gap)
    double dataColumnWidth = contentBoxWidth;

    // Tinggi per komponen
    double chartHeight = 300;
    double rowSkdnLabelHeight = 15;
    double rowValueHeight = 15;

    // PENGATURAN JARAK VERTIKAL (GAP)
    double gapAfterData = 10.0; // Jarak setelah baris angka SKDN

    double rowPercentHeight = 25; // Tinggi baris persentase
    double rowExtraDataHeight = 20; // Tinggi baris data tambahan (Lulus & S36)

    // Hitung posisi Y
    double tableStartY =
        contentStartY + chartHeight; // Mulai Tabel SKDN (S,K,D,N)

    // Y mulai Rumus Persentase (Langsung setelah data SKDN + Gap)
    double formulaStartY =
        tableStartY + rowSkdnLabelHeight + rowValueHeight + gapAfterData;

    // Y mulai Tabel Tambahan (Lulus & S36) - Setelah 4 baris rumus
    double extraDataStartY =
        formulaStartY + (rowPercentHeight * 4) + 10; // +10 gap pemisah

    // SIDEBAR KIRI (IDENTITAS, KETERANGAN, RUMUS, TABEL PISAH)
    double startX = 0;
    _drawSidebarComplete(
      page,
      startX: startX,
      contentStartY: contentStartY,
      formulaStartY: formulaStartY,
      extraDataStartY: extraDataStartY,
      width: sidebarWidth - 10,
      rowPercentH: rowPercentHeight,
      rowExtraDataH: rowExtraDataHeight,
    );

    // AREA CHART & DATA (KANAN)

    int maxValue = 0;
    for (var d in data) {
      if (d.s > maxValue) maxValue = d.s;
    }
    if (maxValue == 0) maxValue = 5;
    maxValue = ((maxValue / 5).ceil() * 5);
    int axisMax = maxValue + 5;

    _drawAxisLabels(
      page,
      Rect.fromLTWH(0, contentStartY, sidebarWidth, chartHeight),
      axisMax,
    );

    List<String> monthsShort = [
      "JANUARI",
      "FEBRUARI",
      "MARET",
      "APRIL",
      "MEI",
      "JUNI",
      "JULI",
      "AGUSTUS",
      "SEPTEMBER",
      "OKTOBER",
      "NOVEMBER",
      "DESEMBER",
    ];

    for (int i = 0; i < 12; i++) {
      double columnStartX = sidebarWidth + (i * monthColumnWidth);
      SkdnDataModel? monthData = (i < data.length) ? data[i] : null;

      // A. LABEL BULAN (DI ATAS GRAFIK)
      _drawBoxText(
        page,
        Rect.fromLTWH(columnStartX, yPos, contentBoxWidth, rowLabelHeight),
        monthsShort[i],
        fontSize: 6,
        isBold: true,
      );

      // B. GRAFIK (CHART)
      double chartInnerX = columnStartX;
      double chartInnerW = contentBoxWidth;
      Rect chartRect = Rect.fromLTWH(
        chartInnerX,
        contentStartY,
        chartInnerW,
        chartHeight,
      );
      _drawMonthChart(page, chartRect, monthData, axisMax);

      // C. DATA TABEL DI BAWAH GRAFIK (S, K, D, N)
      double dataStartX = columnStartX;
      double dataWidth = dataColumnWidth;
      double currentY = contentStartY + chartHeight;

      // C1. LABEL S/K/D/N (Putih)
      _drawSkdnLabelRow(
        page,
        Rect.fromLTWH(dataStartX, currentY, dataWidth, rowSkdnLabelHeight),
      );
      currentY += rowSkdnLabelHeight;

      // C2. ANGKA DATA (S, K, D, N)
      _drawSkdnValueRow(
        page,
        Rect.fromLTWH(dataStartX, currentY, dataWidth, rowValueHeight),
        monthData,
      );

      // --- D. PERSENTASE (LANJUTAN TABEL) ---
      double percentY = formulaStartY;
      Rect percentRect = Rect.fromLTWH(
        columnStartX,
        percentY,
        dataColumnWidth,
        rowPercentHeight,
      );

      // 1. K/S
      double valKS = (monthData != null && monthData.s > 0)
          ? (monthData.k / monthData.s) * 100
          : 0.0;
      _drawDynamicPercentBox(page, percentRect, valKS);

      // 2. D/S
      percentRect = Rect.fromLTWH(
        percentRect.left,
        percentRect.top + rowPercentHeight,
        percentRect.width,
        percentRect.height,
      );
      double valDS = (monthData != null && monthData.s > 0)
          ? (monthData.d / monthData.s) * 100
          : 0.0;
      _drawDynamicPercentBox(page, percentRect, valDS);

      // 3. N/D
      percentRect = Rect.fromLTWH(
        percentRect.left,
        percentRect.top + rowPercentHeight,
        percentRect.width,
        percentRect.height,
      );
      double valND = (monthData != null && monthData.d > 0)
          ? (monthData.n / monthData.d) * 100
          : 0.0;
      _drawDynamicPercentBox(page, percentRect, valND);

      // 4. N/S (BARU)
      percentRect = Rect.fromLTWH(
        percentRect.left,
        percentRect.top + rowPercentHeight,
        percentRect.width,
        percentRect.height,
      );
      double valNS = (monthData != null && monthData.s > 0)
          ? (monthData.n / monthData.s) * 100
          : 0.0;
      _drawDynamicPercentBox(page, percentRect, valNS);

      // --- E. DATA TAMBAHAN (TABEL PISAH) ---
      double extraY = extraDataStartY;

      // 1. Jumlah Lulus
      _drawBoxText(
        page,
        Rect.fromLTWH(
          columnStartX,
          extraY,
          dataColumnWidth,
          rowExtraDataHeight,
        ),
        monthData != null ? monthData.jumlahLulus.toString() : "",
        fontSize: 7,
      );

      // 2. Jumlah S 36 Bulan
      extraY += rowExtraDataHeight;
      _drawBoxText(
        page,
        Rect.fromLTWH(
          columnStartX,
          extraY,
          dataColumnWidth,
          rowExtraDataHeight,
        ),
        monthData != null ? monthData.jumlahS36.toString() : "",
        fontSize: 7,
      );
    }

    final List<int> bytes = await document.save();
    document.dispose();
    return Uint8List.fromList(bytes);
  }

  // SIDEBAR
  static void _drawSidebarComplete(
    PdfPage page, {
    required double startX,
    required double contentStartY,
    required double formulaStartY,
    required double extraDataStartY,
    required double width,
    required double rowPercentH,
    required double rowExtraDataH,
  }) {
    final PdfGraphics g = page.graphics;

    double currentY = 0;
    double paddingY = 8.0;
    double fieldH = 12.0;

    // BAGIAN IDENTITAS
    currentY = contentStartY + 10;

    g.drawString(
      "Kelompok Kerja Operasional",
      PdfStandardFont(PdfFontFamily.helvetica, 8, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(startX, currentY, width, 15),
    );
    currentY += 12;
    g.drawString(
      "Posyandu Dahlia X",
      PdfStandardFont(PdfFontFamily.helvetica, 8, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(startX, currentY, width, 15),
    );
    currentY += 15;

    double labelW = 60;
    double gapHorizontal = 5;
    double fieldW = width - labelW - 10 - gapHorizontal;

    void drawIdField(String label) {
      g.drawString(
        label,
        PdfStandardFont(PdfFontFamily.helvetica, 8),
        bounds: Rect.fromLTWH(startX, currentY, labelW, fieldH),
      );
      g.drawRectangle(
        pen: PdfPen(PdfColor(0, 0, 0), width: 0.5),
        bounds: Rect.fromLTWH(
          startX + labelW + gapHorizontal,
          currentY - 1,
          fieldW,
          fieldH,
        ),
      );
      currentY += fieldH + 4;
    }

    drawIdField("Posyandu");
    drawIdField("Desa");
    drawIdField("Kecamatan");
    drawIdField("Kabupaten");
    drawIdField("Provinsi");

    currentY += paddingY;

    // BAGIAN KETERANGAN (S, K, D, N)
    g.drawString(
      "Keterangan",
      PdfStandardFont(
        PdfFontFamily.helvetica,
        9,
        style: PdfFontStyle.underline,
      ),
      bounds: Rect.fromLTWH(startX, currentY, width, 15),
    );
    currentY += 15;

    void drawLegendItem(String code, String title, String desc) {
      g.drawString(
        code,
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(startX, currentY, 15, 15),
      );
      g.drawString(
        ": $title",
        PdfStandardFont(PdfFontFamily.helvetica, 8),
        bounds: Rect.fromLTWH(startX + 15, currentY, width - 20, 10),
      );
      currentY += 10;
      PdfTextElement textElement = PdfTextElement(
        text: desc,
        font: PdfStandardFont(PdfFontFamily.helvetica, 8),
      );
      PdfLayoutResult? res = textElement.draw(
        page: page,
        bounds: Rect.fromLTWH(startX + 15, currentY, width - 20, 40),
        format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate),
      );
      currentY = (res?.bounds.bottom ?? currentY) + 5;
    }

    drawLegendItem("S", "Jumlah seluruh balita", "di wilayah kerja Posyandu");
    drawLegendItem(
      "K",
      "Jumlah balita yang memiliki KMS",
      "di wilayah kerja Posyandu bulan ini",
    );
    drawLegendItem("D", "Jumlah balita yang ditimbang", "bulan ini");
    drawLegendItem(
      "N",
      "Balita yang ditimbang dan naik",
      "garis pertumbuhan pada KMS (Naik)",
    );

    // BAGIAN RUMUS / FORMULA
    currentY = formulaStartY;

    _drawFormulaRow(
      page,
      Rect.fromLTWH(startX, currentY, width - 10, rowPercentH),
      "TINGKAT LIPUTAN\nPROGRAM",
      "K",
      "S",
    );
    currentY += rowPercentH;

    _drawFormulaRow(
      page,
      Rect.fromLTWH(startX, currentY, width - 10, rowPercentH),
      "TINGKAT\nPARTISIPASI",
      "D",
      "S",
    );
    currentY += rowPercentH;

    _drawFormulaRow(
      page,
      Rect.fromLTWH(startX, currentY, width - 10, rowPercentH),
      "TINGKAT\nKEBERHASILAN",
      "N",
      "D",
    );
    currentY += rowPercentH;

    _drawFormulaRow(
      page,
      Rect.fromLTWH(startX, currentY, width - 10, rowPercentH),
      "TINGKAT\nPENCAPAIAN",
      "N",
      "S",
    );
    currentY += rowPercentH;

    // BAGIAN TABEL PISAH (Data Tambahan)
    currentY = extraDataStartY;

    _drawPlainLabelBox(
      page,
      Rect.fromLTWH(startX, currentY, width - 10, rowExtraDataH),
      "Jumlah Lulus (L)",
    );
    currentY += rowExtraDataH;

    _drawPlainLabelBox(
      page,
      Rect.fromLTWH(startX, currentY, width - 10, rowExtraDataH),
      "Jumlah S (36 Bulan)",
    );
  }

  static void _drawPlainLabelBox(PdfPage page, Rect rect, String text) {
    final PdfGraphics g = page.graphics;
    g.drawString(
      text,
      PdfStandardFont(PdfFontFamily.helvetica, 8, style: PdfFontStyle.bold),
      bounds: rect,
      format: PdfStringFormat(
        alignment: PdfTextAlignment.left,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );
  }

  static void _drawFormulaRow(
    PdfPage page,
    Rect rect,
    String label,
    String top,
    String bot,
  ) {
    final PdfGraphics g = page.graphics;
    final PdfBrush textBrush = PdfSolidBrush(PdfColor(0, 0, 0));
    final PdfPen blackPen = PdfPen(PdfColor(0, 0, 0), width: 1.0);

    double splitX = rect.left + (rect.width * 0.45);
    Rect formulaRect = Rect.fromLTWH(
      splitX,
      rect.top,
      rect.width - splitX,
      rect.height,
    );

    List<String> labelLines = label.split('\n');
    double labelLineH = 10;
    double totalLabelH = labelLines.length * labelLineH;
    double startLabelY = rect.top + (rect.height - totalLabelH) / 2;

    for (int i = 0; i < labelLines.length; i++) {
      g.drawString(
        labelLines[i],
        PdfStandardFont(PdfFontFamily.helvetica, 6, style: PdfFontStyle.bold),
        bounds: Rect.fromLTWH(
          rect.left + 2,
          startLabelY + (i * labelLineH),
          splitX - rect.left - 4,
          labelLineH,
        ),
        brush: textBrush,
        format: PdfStringFormat(alignment: PdfTextAlignment.left),
      );
    }

    g.drawRectangle(pen: blackPen, bounds: formulaRect);

    double rightAreaW = formulaRect.width;
    double centerX = formulaRect.left + (rightAreaW * 0.3);

    double lineY = formulaRect.center.dy;
    double topTextY = lineY - 14;
    double botTextY = lineY + 1;

    g.drawString(
      top,
      PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(centerX - 10, topTextY, 20, 15),
      brush: textBrush,
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    g.drawLine(
      PdfPen(PdfColor(0, 0, 0), width: 1.5),
      Offset(centerX - 10, lineY),
      Offset(centerX + 10, lineY),
    );

    g.drawString(
      bot,
      PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(centerX - 10, botTextY, 20, 15),
      brush: textBrush,
      format: PdfStringFormat(alignment: PdfTextAlignment.center),
    );

    g.drawString(
      "x 100 %",
      PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(
        centerX + 15,
        formulaRect.top,
        rightAreaW - (centerX - formulaRect.left) - 10,
        formulaRect.height,
      ),
      brush: textBrush,
      format: PdfStringFormat(
        alignment: PdfTextAlignment.left,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );
  }

  // DRAWING HELPERS
  static void _drawMonthChart(
    PdfPage page,
    Rect rect,
    SkdnDataModel? data,
    int axisMax,
  ) {
    final PdfGraphics g = page.graphics;

    g.drawRectangle(pen: PdfPen(PdfColor(0, 0, 0), width: 0.5), bounds: rect);

    if (data != null) {
      final PdfBrush brushS = PdfSolidBrush(PdfColor(255, 0, 0));
      final PdfBrush brushK = PdfSolidBrush(PdfColor(255, 255, 0));
      final PdfBrush brushD = PdfSolidBrush(PdfColor(0, 255, 0));
      final PdfBrush brushN = PdfSolidBrush(PdfColor(0, 112, 192));

      double paddingX = 0.0;
      double gap = 0.0;
      double availableW = rect.width - (2 * paddingX);
      double barW = availableW / 4;

      void drawBar(int val, PdfBrush brush, int idx) {
        if (val <= 0) return;
        double h = (val / axisMax) * rect.height;
        double x = rect.left + (idx * barW);
        double y = rect.bottom - h;
        g.drawRectangle(brush: brush, bounds: Rect.fromLTWH(x, y, barW, h));
        g.drawRectangle(
          pen: PdfPen(PdfColor(0, 0, 0), width: 0.5),
          bounds: Rect.fromLTWH(x, y, barW, h),
        );
      }

      drawBar(data.s, brushS, 0);
      drawBar(data.k, brushK, 1);
      drawBar(data.d, brushD, 2);
      drawBar(data.n, brushN, 3);
    }

    int gridStep = 1;
    for (int val = 0; val <= axisMax; val += gridStep) {
      double y = rect.bottom - (val / axisMax * rect.height);
      g.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: 0.3),
        Offset(rect.left, y),
        Offset(rect.right, y),
      );
    }

    double colW = rect.width / 4;
    for (int i = 1; i < 4; i++) {
      double x = rect.left + (i * colW);
      g.drawLine(
        PdfPen(PdfColor(0, 0, 0), width: 0.3),
        Offset(x, rect.top),
        Offset(x, rect.bottom),
      );
    }
  }

  static void _drawSkdnLabelRow(PdfPage page, Rect rect) {
    double w = rect.width / 4;
    List<String> labels = ["S", "K", "D", "N"];
    for (int i = 0; i < 4; i++) {
      _drawBoxText(
        page,
        Rect.fromLTWH(rect.left + (i * w), rect.top, w, rect.height),
        labels[i],
        fontSize: 6,
        isBold: true,
      );
    }
  }

  static void _drawSkdnValueRow(PdfPage page, Rect rect, SkdnDataModel? data) {
    double w = rect.width / 4;
    List<String> values = ["", "", "", ""];
    if (data != null) {
      values = [
        data.s.toString(),
        data.k.toString(),
        data.d.toString(),
        data.n.toString(),
      ];
    }
    for (int i = 0; i < 4; i++) {
      _drawBoxText(
        page,
        Rect.fromLTWH(rect.left + (i * w), rect.top, w, rect.height),
        values[i],
        color: PdfColor(245, 245, 245),
        fontSize: 6,
      );
    }
  }

  static void _drawDynamicPercentBox(PdfPage page, Rect rect, double value) {
    PdfColor color;
    if (value == 0) {
      color = PdfColor(255, 255, 255);
    } else if (value < 60) {
      color = PdfColor(255, 51, 51); // Merah
    } else if (value < 80) {
      color = PdfColor(255, 204, 0); // Kuning
    } else {
      color = PdfColor(51, 204, 51); // Hijau
    }
    String text = value == 0 ? "" : "${value.toStringAsFixed(0)}%";
    _drawBoxText(
      page,
      rect,
      text,
      color: color,
      isBold: true,
      fontSize: 8,
      penWidth: 0.5,
    );
  }

  static void _drawBoxText(
    PdfPage page,
    Rect rect,
    String text, {
    double fontSize = 7,
    bool isBold = false,
    PdfColor? color,
    double penWidth = 0.5,
  }) {
    final PdfGraphics g = page.graphics;
    final PdfBrush brush = (color != null)
        ? PdfSolidBrush(color)
        : PdfSolidBrush(PdfColor(255, 255, 255));
    final PdfPen pen = PdfPen(PdfColor(0, 0, 0), width: penWidth);
    final PdfFont font = PdfStandardFont(
      PdfFontFamily.helvetica,
      fontSize,
      style: isBold ? PdfFontStyle.bold : PdfFontStyle.regular,
    );
    final PdfBrush textBrush = PdfSolidBrush(PdfColor(0, 0, 0));

    g.drawRectangle(pen: pen, brush: brush, bounds: rect);
    g.drawString(
      text,
      font,
      bounds: rect,
      brush: textBrush,
      format: PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );
  }

  static void _drawAxisLabels(PdfPage page, Rect rect, int axisMax) {
    final PdfGraphics g = page.graphics;
    final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 7);

    int step = 5;

    for (int val = 0; val <= axisMax; val += step) {
      double y = rect.bottom - (val / axisMax * rect.height);
      g.drawString(
        val.toString(),
        font,
        bounds: Rect.fromLTWH(rect.right - 25, y - 3, 20, 10),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
      );
      g.drawLine(
        PdfPen(PdfColor(0, 0, 0)),
        Offset(rect.right, y),
        Offset(rect.right + 3, y),
      );
    }
  }

  static void _drawTextCenter(
    PdfPage page,
    String text,
    PdfFont font,
    double y,
    double pageWidth,
  ) {
    final Size textSize = font.measureString(text);
    page.graphics.drawString(
      text,
      font,
      bounds: Rect.fromLTWH(
        (pageWidth - textSize.width) / 2,
        y,
        textSize.width,
        textSize.height,
      ),
    );
  }

  static Future<File> saveAndShare(Uint8List bytes, String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$fileName");
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)], text: "Laporan SKDN $fileName");

    return file;
  }
}
