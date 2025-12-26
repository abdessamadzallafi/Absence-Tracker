import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExportService {
  Future<File> exportCsv(String filename, List<List<dynamic>> rows) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename.csv');
    final csv = const ListToCsvConverter().convert(rows);
    return file.writeAsString(csv);
  }

  Future<void> shareFile(File file, {String? text}) async {
    await Share.shareXFiles([XFile(file.path)], text: text);
  }

  Future<void> exportPdfAndShare({
    required String filename,
    required String title,
    required List<List<String>> table,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title,
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            pw.TableHelper.fromTextArray(data: table),
          ],
        ),
      ),
    );
    final bytes = await doc.save();
    await Printing.sharePdf(bytes: bytes, filename: '$filename.pdf');
  }
}
