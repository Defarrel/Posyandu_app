import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class CertificateService {
  static Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status.isGranted) return true;
      final result = await Permission.storage.request();
      return result.isGranted;
    }
    return true;
  }

  static Future<Uint8List> _loadImageAsset() async {
    try {
      final byteData = await rootBundle.load('lib/core/assets/sertifikat.png');
      return byteData.buffer.asUint8List();
    } catch (e) {
      throw Exception('Gagal memuat gambar: $e');
    }
  }

  static Future<Uint8List> generatePdf({required String namaBalita}) async {
    try {
      final backgroundImage = await _loadImageAsset();
      final image = pw.MemoryImage(backgroundImage);

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: pw.Image(image, fit: pw.BoxFit.cover),
                ),

                pw.Positioned(
                  left: 0,
                  right: 0,
                  top: 270,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 40),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          namaBalita.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 35,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                pw.Positioned(
                  right: 95,
                  bottom: 15,
                  child: pw.Container(
                    child: pw.Text(
                      _getCurrentDate(),
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      return pdf.save();
    } catch (e) {
      throw Exception('Gagal generate PDF: $e');
    }
  }

  static String _getCurrentDate() {
    final now = DateTime.now();
    final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
    return formatter.format(now);
  }

  static Future<File> saveAndShare({required String namaBalita}) async {
    try {
      final bytes = await generatePdf(namaBalita: namaBalita);

      final fileName =
          'Sertifikat_Lulus_${namaBalita.replaceAll(' ', '')}.pdf';

      final dir =
          await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/$fileName");

      await file.writeAsBytes(bytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: "Sertifikat Kelulusan Posyandu untuk $namaBalita");

      return file;
    } catch (e) {
      throw Exception('Gagal menyimpan dan membagikan sertifikat: $e');
    }
  }

  static Future<File> downloadOnly({required String namaBalita}) async {
    try {
      final bytes = await generatePdf(namaBalita: namaBalita);

      final fileName = 'Sertifikat_Lulus_${namaBalita.replaceAll(' ', '')}.pdf';
      final dir =
          await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/$fileName");

      await file.writeAsBytes(bytes);

      return file;
    } catch (e) {
      throw Exception('Gagal mendownload sertifikat: $e');
    }
  }
}
