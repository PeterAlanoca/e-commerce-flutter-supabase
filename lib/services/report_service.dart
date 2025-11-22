import '../database/database.dart';
import 'database_service.dart';
import 'sale_service.dart';
import 'purchase_service.dart';
import 'transfer_service.dart';

class ReportService {
  final DatabaseService _db = DatabaseService.instance;
  final SaleService _saleService = SaleService();
  final PurchaseService _purchaseService = PurchaseService();
  final TransferService _transferService = TransferService();

  // Reporte de ventas por tienda y fecha
  Future<Map<String, dynamic>> getSalesReport({
    int? storeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final sales = await _saleService.getSales(
      storeId: storeId,
      startDate: startDate,
      endDate: endDate,
    );
    
    final total = sales.fold<double>(0.0, (sum, sale) => sum + sale.total);
    final count = sales.length;
    
    // Agrupar por producto
    final Map<int, double> productSales = {};
    final Map<int, double> productQuantities = {};
    
    for (var sale in sales) {
      final items = await _saleService.getSaleItems(sale.id);
      for (var item in items) {
        productSales[item.productId] = 
            (productSales[item.productId] ?? 0) + item.total;
        productQuantities[item.productId] = 
            (productQuantities[item.productId] ?? 0) + item.quantity;
      }
    }
    
    return {
      'sales': sales,
      'total': total,
      'count': count,
      'productSales': productSales,
      'productQuantities': productQuantities,
    };
  }

  // Reporte de compras por almacén y fecha
  Future<Map<String, dynamic>> getPurchasesReport({
    int? warehouseId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final purchases = await _purchaseService.getPurchases(
      warehouseId: warehouseId,
      startDate: startDate,
      endDate: endDate,
    );
    
    final total = purchases.fold<double>(0.0, (sum, purchase) => sum + purchase.total);
    final count = purchases.length;
    
    // Agrupar por producto
    final Map<int, double> productPurchases = {};
    final Map<int, double> productQuantities = {};
    
    for (var purchase in purchases) {
      final items = await _purchaseService.getPurchaseItems(purchase.id);
      for (var item in items) {
        productPurchases[item.productId] = 
            (productPurchases[item.productId] ?? 0) + item.total;
        productQuantities[item.productId] = 
            (productQuantities[item.productId] ?? 0) + item.quantity;
      }
    }
    
    return {
      'purchases': purchases,
      'total': total,
      'count': count,
      'productPurchases': productPurchases,
      'productQuantities': productQuantities,
    };
  }

  // Reporte de transferencias
  Future<Map<String, dynamic>> getTransfersReport({
    int? storeId,
    int? warehouseId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final transfers = await _transferService.getTransfers(
      storeId: storeId,
      warehouseId: warehouseId,
      startDate: startDate,
      endDate: endDate,
    );
    
    // Agrupar por tipo
    final Map<String, int> transfersByType = {};
    for (var transfer in transfers) {
      transfersByType[transfer.type] = (transfersByType[transfer.type] ?? 0) + 1;
    }
    
    return {
      'transfers': transfers,
      'count': transfers.length,
      'transfersByType': transfersByType,
    };
  }

  // Reporte de ventas globales del día
  Future<Map<String, dynamic>> getTodayGlobalSalesReport() async {
    return await getSalesReport(
      startDate: DateTime.now().copyWith(hour: 0, minute: 0, second: 0),
      endDate: DateTime.now().copyWith(hour: 23, minute: 59, second: 59),
    );
  }

  // Reporte de ventas por tienda del día
  Future<Map<String, dynamic>> getTodayStoreSalesReport(int storeId) async {
    return await getSalesReport(
      storeId: storeId,
      startDate: DateTime.now().copyWith(hour: 0, minute: 0, second: 0),
      endDate: DateTime.now().copyWith(hour: 23, minute: 59, second: 59),
    );
  }
}
