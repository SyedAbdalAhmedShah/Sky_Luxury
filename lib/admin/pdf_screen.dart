import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:sky_luxury/components/strings.dart';
import 'package:sky_luxury/model/add_agent.dart';
import 'package:sky_luxury/model/invoice_items.dart';

class PdfPageView {
  static dynamic invoiceNumber = 0;
  static pdfCreation({required MemoryImage image, required AddAgent addAgent}) {
    return MultiPage(
      margin: EdgeInsets.all(0),
      header: (_) => _buildHeader(image),
      mainAxisAlignment: MainAxisAlignment.start,
      build: (context) => [
        _buildBillToAndInvoiceData(addAgent),
        verticalGap(),
        buildInvoice(addAgent),
        verticalGap(),
        _buildTotalPrice(addAgent),
        verticalGap(),
        verticalGap(),
        _buildNoteAndTermText(),
        noteNterms()
      ],
    );
  }

  static Padding _buildNoteAndTermText() {
    return Padding(
        padding: EdgeInsets.fromLTRB(34, 0, 0, 0),
        child: Text(Strings.noteNterm,
            style: TextStyle(fontWeight: FontWeight.bold)));
  }

  static noteNterms() {
    return Padding(
        padding: EdgeInsets.fromLTRB(34, 0, 0, 0),
        child: _buildText(Strings.noteNtermDesc));
  }

  static Row _buildTotalPrice(AddAgent addAgent) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Spacer(flex: 6),
      Expanded(
        flex: 4,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 34, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(addAgent.totalBalance.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold))
                  ]),
            ),
            SizedBox(height: 0.5 * PdfPageFormat.cm),
            _customDivier(),
            _customDivier(),
            SizedBox(height: 0.5 * PdfPageFormat.cm),
            Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 34, 0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ammount Due (GBP):',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('£${addAgent.remainingBalance}',
                          style: TextStyle(fontWeight: FontWeight.bold))
                    ]))
          ],
        ),
      )
    ]);
  }

  static Container _customDivier() {
    return Container(
        margin: EdgeInsets.fromLTRB(0, 0, 34, 0),
        height: 1,
        color: PdfColors.grey400);
  }

  static Row _buildBillToAndInvoiceData(AddAgent addAgent) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      _buildBillToInformation(addAgent),
      _buildInvoicemakerData(addAgent)
    ]);
  }

  static Padding _buildInvoicemakerData(AddAgent finance) {
    invoiceNumber = invoiceNumber + 1;

    return Padding(
      padding: EdgeInsets.only(right: 34, top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          // _buildRichText(Strings.invoiceNumber, '$invoiceNumber'),
          _richText(Strings.invoiceNumber, invoiceNumber.toString()),
          _richText(Strings.invoiceDate,
              ' ${DateFormat.yMMMMd(Strings.english).format(DateTime.now())}'),
          _richText(Strings.paymentdue,
              '${DateFormat.yMMMMd(Strings.english).format(DateTime.now())}'),

          _richText(Strings.AmountDue, '${finance.remainingBalance}',
              color: PdfColors.grey200),
        ],
      ),
    );
  }

  static Container _richText(String key, String value, {PdfColor? color}) {
    return Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.fromLTRB(1, 5, 2, 5),
        color: color ?? PdfColors.white,
        width: PdfPageFormat.mm * 71,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          _buildKey(key),
          SizedBox(
            width: 1 * PdfPageFormat.mm,
          ),
          _buildValue(value)
        ]));
  }

  static Container _buildKey(String key) {
    return Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.fromLTRB(1, 5, 2, 5),
        width: 41 * PdfPageFormat.mm,
        child: Text(
          key,
          style: TextStyle(fontWeight: FontWeight.bold),
        ));
  }

  static Column _buildValue(String value) {
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Text(value),
    ]);
  }

  // static RichText _buildRichText(String key, String Value) {
  //   return RichText(
  //       text: TextSpan(children: [
  //     TextSpan(
  //       text: key,
  //       style: TextStyle(fontWeight: FontWeight.bold),
  //     ),
  //     TextSpan(text: Value)
  //   ]));
  // }

  static buildInvoice(AddAgent addAgent) {
    var items = [addAgent];
    var headers = ['Items', 'Quantity', 'Price', 'Ammount'];
    final data = items.map((item) {
      return [
        invoiceNumber,
        item.ticketQuantity != null ? item.ticketQuantity : 0,
        item.revievingBalance,
        item.totalBalance,
      ];
    }).toList();
    var pendingBalance = [
      'Your Pending balance',
      addAgent.ticketQuantity,
      addAgent.remainingBalance,
      addAgent.remainingBalance
    ];
    data.add(pendingBalance);
    return Table.fromTextArray(
      // rowDecoration: BoxDecoration(
      //     border: Border.symmetric(
      //         horizontal: BorderSide(color: PdfColors.grey200))),
      headers: headers,
      data: data,
      // cellDecoration: (cellnumber , _ , _) {
      //       return BoxDecoration()
      // },

      // cellStyle: TextStyle(fontWeight: FontWeigt.bold),
      border: null,
      // cellStyle: TextStyle(fontWeight:  ),

      tableWidth: TableWidth.max,
      headerStyle: TextStyle(color: PdfColors.white),
      headerDecoration: BoxDecoration(color: PdfColors.grey800),
      headerPadding: EdgeInsets.only(left: 34, right: 34, top: 0),
      cellHeight: 20,
      headerAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.center,
        2: Alignment.centerRight,
        3: Alignment.centerRight
      },
      cellPadding: EdgeInsets.only(left: 34, right: 34, top: 5, bottom: 30),
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.center,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
      },
    );
  }

  static Padding _buildBillToInformation(AddAgent addAgent) {
    return Padding(
        padding: EdgeInsets.only(
          left: 34,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            Strings.billTo,
            style: TextStyle(color: PdfColors.grey),
          ),

          _buildBoldText(addAgent.name.toString()),
          _buildText(addAgent.address.toString()),
          // _buildText(Strings.addressTo3),
          // _buildText(Strings.address3),
          verticalGap(),
          _buildText(addAgent.phoneNumber.toString()),
          _buildText(addAgent.email.toString()),
        ]));
  }

  static Padding _buildHeader(MemoryImage image) {
    return Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Image(
              image,
              width: 3 * PdfPageFormat.cm,
              height: 4 * PdfPageFormat.cm,
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Align(
                alignment: Alignment.centerRight,
                child: Text(Strings.invoice, style: TextStyle(fontSize: 36)),
              ),
              verticalGap(),
              _buildBoldText(Strings.skyLuxury),
              _buildText(Strings.address1),
              _buildText(Strings.address2),
              _buildText(Strings.address3),
              verticalGap(),
              _buildText(Strings.phoneNumber),
              _buildText(Strings.mobileNumber),
            ])
          ]),
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [])
              ]),
          Divider(thickness: 0.2, color: PdfColors.grey)
        ]));
  }

  static Text _buildBoldText(String text) {
    return Text(text, style: TextStyle(fontWeight: FontWeight.bold));
  }

  static SizedBox verticalGap() => SizedBox(height: 0.8 * PdfPageFormat.cm);

  static Text _buildText(String text) {
    return Text(text, style: TextStyle(fontWeight: FontWeight.normal));
  }
}
