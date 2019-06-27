
enum View
{
  Home,
  Markets,
  Trades,
  Account,
  News,
  Settings,
  About,
  Lock

}
enum SubView
{
  None,
  MarketFavourites,
  MarketAudMarkets,
  MarketBtcMarkets,
  
  AccountOpenOrders,
  AccountBalances,
  AccountOrderHistory,
  AccountFundHistory,
  

}

class NavView{
  View view;
  SubView subView;
}