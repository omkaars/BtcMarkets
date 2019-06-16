import 'package:intl/intl.dart';
class Constants {
  static const String BTC = "BTC";
  static const String AUD = "AUD";
  static const String Favourites = "Favourites";
  static const String AudMarkets = "AUD Markets";
  static const String BtcMarkets = "BTC Markets";

  static NumberFormat get  audFormat => new NumberFormat("#,##0.00", "en_AU");
  static NumberFormat get  btcFormat => new NumberFormat("#0.00000000", "en_AU");
}