import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:agroledger/features/calculator/data/models/calculator_summary_model.dart';
import 'package:agroledger/features/calculator/presentation/widgets/calculator_sheet_widgets.dart';

class ReportExportService {
  final _dateFormat = DateFormat('yyyy-MM-dd_HH-mm');
  final _displayDateFormat = DateFormat('dd.MM.yyyy HH:mm');

  String buildCsv(CalculatorSummaryModel summary) {
    final buffer = StringBuffer();
    final generatedAt = _displayDateFormat.format(DateTime.now());

    void writeRow(List<String> cells) {
      buffer.writeln(cells.map(_escapeCsvCell).join(','));
    }

    writeRow(['AgroLedger — Финансовый отчёт калькулятора']);
    writeRow(['Дата формирования', generatedAt]);
    if (summary.assetId != null) {
      writeRow(['Фильтр по активу ID', summary.assetId.toString()]);
    }
    writeRow(['']);

    writeRow(['Показатель', 'Значение (₸)']);
    writeRow(['Стартовые вложения', _formatNumber(summary.initialInvestment)]);
    writeRow(['Операционные расходы', _formatNumber(summary.operatingExpenses)]);
    writeRow(['Общие расходы', _formatNumber(summary.totalCosts)]);
    writeRow(['Общий доход', _formatNumber(summary.totalEarnings)]);
    writeRow(['Чистая прибыль', _formatNumber(summary.netProfit)]);
    writeRow(['ROI (%)', summary.roi.toStringAsFixed(2)]);
    writeRow(['Количество активных групп', summary.assetsCount.toString()]);
    writeRow(['']);

    writeRow(['Структура операционных расходов', 'Сумма (₸)', 'Доля (%)']);
    _writeExpenseRow(writeRow, 'Корма', summary.feedCost, summary.operatingExpenses);
    _writeExpenseRow(writeRow, 'Ветеринария', summary.vetCost, summary.operatingExpenses);
    _writeExpenseRow(
      writeRow,
      'Коммунальные услуги',
      summary.utilityCost,
      summary.operatingExpenses,
    );
    _writeExpenseRow(writeRow, 'Прочее', summary.otherCost, summary.operatingExpenses);
    writeRow(['']);

    writeRow(['Источники доходов', 'Сумма (₸)']);
    if (summary.earningsByProduct.isEmpty) {
      writeRow(['Нет данных', '0']);
    } else {
      final sortedEntries = summary.earningsByProduct.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final entry in sortedEntries) {
        writeRow([
          _productLabel(entry.key),
          _formatNumber(entry.value),
        ]);
      }
    }

    return buffer.toString();
  }

  Future<void> exportToCsv(CalculatorSummaryModel summary) async {
    final csvContent = buildCsv(summary);
    final fileName =
        'agroledger_report_${_dateFormat.format(DateTime.now())}.csv';

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
      text: 'Финансовый отчёт AgroLedger от ${_displayDateFormat.format(DateTime.now())}',
    );
  }

  Future<void> copyToClipboard(CalculatorSummaryModel summary) async {
    await Clipboard.setData(ClipboardData(text: buildCsv(summary)));
  }

  void _writeExpenseRow(
    void Function(List<String>) writeRow,
    String label,
    double amount,
    double total,
  ) {
    final share = total > 0 ? (amount / total * 100).toStringAsFixed(1) : '0.0';
    writeRow([label, _formatNumber(amount), share]);
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(2);
  }

  String _escapeCsvCell(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _productLabel(String key) {
    switch (key) {
      case ProductTypes.eggs:
        return 'Яйца';
      case ProductTypes.meat:
        return 'Мясо';
      case ProductTypes.milk:
        return 'Молоко';
      case ProductTypes.liveAnimals:
        return 'Живой вес / молодняк';
      default:
        return ProductTypes.labelFor(key);
    }
  }
}
