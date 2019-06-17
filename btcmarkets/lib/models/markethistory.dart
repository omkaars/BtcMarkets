import 'package:btcmarkets/api/btcmarketsapi.dart';
import 'package:btcmarkets/helpers/markethelper.dart';

class MarketHistory {
  MarketHistory();

  String duration;
  Market market;
  
  double high;
  double low;

  String get highString => high == null?"0.00":MarketHelper.getValueFormat(market.currency, high);
  String get lowString => low==null?"0.00":MarketHelper.getValueFormat(market.currency, low);

  var data = [];

  void refresh(List<HistoricalTick> ticks) {
    data.clear();
 
    if (ticks != null && ticks.isNotEmpty) {
      high = 0.0;
      low = ticks[0].lowValue;
     
      for (var tick in ticks) {
        
        if (tick.highValue > high) high = tick.highValue;
        if (tick.lowValue < low) low = tick.lowValue;
 
        
        var  historyTick = {"open": tick.openValue, "close": tick.closeValue, "high": tick.highValue, "low":tick.lowValue, "volumeto":tick.volumeValue};
         data.add(historyTick);
  
        
      }
    }
  }
}

class MarketHistoryData {
  double open;
  double close;
  double high;
  double low;
  double volumeto;
}
