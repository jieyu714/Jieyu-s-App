import 'package:flutter/material.dart';
import 'package:jieyu_app/api/InvoiceApi.dart';
import 'package:jieyu_app/utils/ProgressDialog.dart';
import 'package:jieyu_app/viewmodels/Invoices.dart'; 

class InvoiceListFragment extends StatefulWidget {
  const InvoiceListFragment({super.key});

  @override
  State<InvoiceListFragment> createState() => _InvoiceListFragmentState();
}

class _InvoiceListFragmentState extends State<InvoiceListFragment> with AutomaticKeepAliveClientMixin {
  List<InvoiceModel>? _invoices;

  final InvoiceApi _api = InvoiceApi();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async => _loadInvoices());
  }

  ListView _buildInvoiceList() {
    return ListView.separated(
      itemCount: _invoices!.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _invoices![index];
        final isWinner = item.prizeAmount! > 0;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isWinner ? Colors.redAccent : Colors.grey[200],
            child: Icon(
              isWinner ? Icons.card_giftcard : Icons.description,
              color: isWinner ? Colors.white : Colors.grey,
            ),
          ),
          title: Text(item.number),
          subtitle: Text(item.consumptionDate.split('T')[0]),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isWinner)
                Text(
                  item.prizeType ?? "中獎", 
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold
                  )
                ),
              Text(
                isWinner ? "\$${item.prizeAmount}" : "未中獎",
                style: TextStyle(
                  color: isWinner ? Colors.red : Colors.black54
                )
              ),
            ],
          ),
        );
      },
    );
  }

  void _loadInvoices() async {
    ProgressDialog().showLoading(context, title: "載入發票中...", minDuration: 2);
    _invoices = (await _api.getInvoices()).data ?? [];
    setState(() {});
    if (!mounted) return;
    ProgressDialog().hide(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: () async => _loadInvoices(),
      child: _invoices == null || _invoices!.isEmpty
        ? Center(child: Text("尚無發票紀錄"))
        : _buildInvoiceList()
    );
  }
}