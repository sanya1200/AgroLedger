import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:agroledger/features/calculator/data/models/calculator_summary_model.dart';

class ReportExportService {
  final _dateFormat = DateFormat('yyyy-MM-dd_HH-mm');
  final _displayDateFormat = DateFormat('dd.MM.yyyy HH:mm');
  final _currencyFormat = NumberFormat('#,##0.00', 'ru_RU');

  String buildCsv(CalculatorSummaryModel summary) {
    final buffer = StringBuffer();
    final generatedAt = _displayDateFormat.format(DateTime.now());

    void writeRow(List<String> cells) {
      buffer.writeln(cells.map(_escapeCsvCell).join(','));
    }

    writeRow(['AgroLedger — Финансовый отчёт калькулятора']);
    writeRow(['Дата формирования', generatedAt]);
    writeRow(['']);

    writeRow(['Показатель', 'Значение (₸)']);
    writeRow(['Стартовые вложения', _currencyFormat.format(summary.initialInvestment)]);
    writeRow(['Операционные расходы', _currencyFormat.format(summary.operatingExpenses)]);
    writeRow(['Общие расходы', _currencyFormat.format(summary.totalCosts)]);
    writeRow(['Общий доход', _currencyFormat.format(summary.totalEarnings)]);
    writeRow(['Чистая прибыль', _currencyFormat.format(summary.netProfit)]);
    writeRow(['ROI (%)', summary.roi.toStringAsFixed(2)]);
    writeRow(['']);

    writeRow(['Структура расходов', 'Сумма (₸)']);
    writeRow(['Корма', _currencyFormat.format(summary.feedCost)]);
    writeRow(['Ветеринария', _currencyFormat.format(summary.vetCost)]);
    writeRow(['Коммунальные услуги', _currencyFormat.format(summary.utilityCost)]);
    writeRow(['Прочее', _currencyFormat.format(summary.otherCost)]);

    return buffer.toString();
  }

  Future<void> exportToCsv(CalculatorSummaryModel summary) async {
    final csvContent = buildCsv(summary);
    final fileName = 'agroledger_report_${_dateFormat.format(DateTime.now())}.csv';

    if (kIsWeb) {
      await Clipboard.setData(ClipboardData(text: csvContent));
      return;
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csvContent, flush: true);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv', name: fileName)],
      subject: 'AgroLedger — Финансовый отчёт',
    );
  }

  Future<void> exportToPdf(CalculatorSummaryModel summary) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('AgroLedger', style: pw.TextStyle(font: fontBold, fontSize: 24, color: PdfColors.green800)),
                  pw.Text('ФИНАНСОВЫЙ ОТЧЕТ', style: pw.TextStyle(font: fontBold, color: PdfColors.grey700)),
                ],
              ),
              pw.Divider(thickness: 2, color: PdfColors.green900),
              pw.SizedBox(height: 20),
              pw.Text('Дата формирования: ${_displayDateFormat.format(DateTime.now())}', style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 30),
              
              pw.Text('Основные показатели', style: pw.TextStyle(font: fontBold, fontSize: 18)),
              pw.SizedBox(height: 10),
              _buildPdfTable([
                ['Показатель', 'Сумма (₸)'],
                ['Стартовые вложения', _currencyFormat.format(summary.initialInvestment)],
                ['Операционные расходы', _currencyFormat.format(summary.operatingExpenses)],
                ['Общий доход', _currencyFormat.format(summary.totalEarnings)],
                ['Чистая прибыль', _currencyFormat.format(summary.netProfit)],
                ['ROI', '${summary.roi}%'],
              ], font, fontBold),
              
              pw.SizedBox(height: 40),
              pw.Text('Структура операционных расходов', style: pw.TextStyle(font: fontBold, fontSize: 18)),
              pw.SizedBox(height: 10),
              _buildPdfTable([
                ['Категория', 'Сумма (₸)', 'Доля'],
                ['Корма', _currencyFormat.format(summary.feedCost), _percent(summary.feedCost, summary.operatingExpenses)],
                ['Ветеринария', _currencyFormat.format(summary.vetCost), _percent(summary.vetCost, summary.operatingExpenses)],
                ['Коммунальные услуги', _currencyFormat.format(summary.utilityCost), _percent(summary.utilityCost, summary.operatingExpenses)],
                ['Прочее', _currencyFormat.format(summary.otherCost), _percent(summary.otherCost, summary.operatingExpenses)],
              ], font, fontBold),
              
              pw.Spacer(),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Сформировано в AgroLedger Premium', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600)),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'agroledger_premium_report.pdf');
  }

  pw.Widget _buildPdfTable(List<List<String>> data, pw.Font font, pw.Font fontBold) {
    return pw.TableHelper.fromTextArray(
      headers: data[0],
      data: data.sublist(1),
      headerStyle: pw.TextStyle(font: fontBold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.green900),
      cellStyle: pw.TextStyle(font: font),
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerAlignment: pw.Alignment.centerLeft,
      cellAlignment: pw.Alignment.centerLeft,
    );
  }

  String _percent(double val, double total) {
    if (total == 0) return '0%';
    return '${(val / total * 100).toStringAsFixed(1)}%';
  }

  String _escapeCsvCell(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
