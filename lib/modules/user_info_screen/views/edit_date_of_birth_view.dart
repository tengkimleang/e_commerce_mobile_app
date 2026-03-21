import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showDateOfBirthPickerDialog(
  BuildContext context, {
  DateTime? initialDate,
}) {
  return showDialog<DateTime>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (dialogContext) => _DateOfBirthDialog(
      initialDate: initialDate,
      dialogContext: dialogContext,
    ),
  );
}

class _DateOfBirthDialog extends StatefulWidget {
  const _DateOfBirthDialog({
    required this.dialogContext,
    required this.initialDate,
  });

  final BuildContext dialogContext;
  final DateTime? initialDate;

  @override
  State<_DateOfBirthDialog> createState() => _DateOfBirthDialogState();
}

class _DateOfBirthDialogState extends State<_DateOfBirthDialog> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final fallback = DateTime(now.year - 18, now.month, now.day);
    final source = widget.initialDate ?? fallback;
    _selectedDate = DateTime(source.year, source.month, source.day);
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFEC0C6E);
    final now = DateTime.now();
    final minDate = DateTime(now.year - 120, 1, 1);
    final maxDate = DateTime(now.year, now.month, now.day);
    final width = MediaQuery.of(context).size.width;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFFF7EEF2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: const BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Text(
                'Please select date',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(
              height: 190,
              child: CupertinoTheme(
                data: const CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: accent,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  dateOrder: DatePickerDateOrder.ymd,
                  minimumDate: minDate,
                  maximumDate: maxDate,
                  initialDateTime: _selectedDate,
                  backgroundColor: const Color(0xFFF7EEF2),
                  onDateTimeChanged: (value) {
                    _selectedDate = DateTime(
                      value.year,
                      value.month,
                      value.day,
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: accent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(widget.dialogContext).pop(_selectedDate);
                },
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
