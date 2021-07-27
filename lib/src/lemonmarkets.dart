import 'dart:async';

import 'package:lemon_markets_client/clients/lemonMarketsTransactions.dart';
import 'package:lemon_markets_client/data/accessToken.dart';
import 'package:lemon_markets_client/data/createdOrder.dart';
import 'package:lemon_markets_client/data/existingOrder.dart';
import 'package:lemon_markets_client/data/instrument.dart';
import 'package:lemon_markets_client/data/latestQuote.dart';
import 'package:lemon_markets_client/data/latestTrade.dart';
import 'package:lemon_markets_client/data/ohlcList.dart';
import 'package:lemon_markets_client/data/portfolioItem.dart';
import 'package:lemon_markets_client/data/space.dart';
import 'package:lemon_markets_client/data/spaceState.dart';
import 'package:lemon_markets_client/data/stateInfo.dart';
import 'package:lemon_markets_client/clients/lemonMarketsHttpClient.dart';
import 'package:lemon_markets_client/clients/lemonMarketsAuth.dart';
import 'package:lemon_markets_client/clients/lemonMarketsHistoric.dart';
import 'package:lemon_markets_client/clients/lemonMarketsMarketData.dart';
import 'package:lemon_markets_client/clients/lemonMarketsPortfolio.dart';
import 'package:lemon_markets_client/clients/lemonMarketsSpaces.dart';
import 'package:lemon_markets_client/clients/lemonMarketsTrading.dart';
import 'package:lemon_markets_client/data/transaction.dart';
import 'package:lemon_markets_client/data/transactionList.dart';
import 'package:lemon_markets_client/helper/lemonMarketsURLs.dart';
import 'package:logging/logging.dart';

//Alle, Aktie, Anleihe, Fond, ETF, Optionsschein
enum SearchType { NONE, STOCK, BOND, FUND, ETF, WARRANT }
enum OrderSide { BUY, SELL }
enum OrderStatus { inactive, active, in_progress, executed, deleted, expired }
enum OrderType { limit, market, stopLimit, stopMarket }
enum OHLCType { m1, h1, d1 }

class LemonMarkets {
  final Logger log = Logger('LemonMarkets');

  late LemonMarketsSpaces _spacesClient;
  late LemonMarketsPortfolio _portfolioClient;
  late LemonMarketsAuth _authClient;
  late LemonMarketsTrading _tradingClient;
  late LemonMarketsMarketData _marketClient;
  late LemonMarketsHistoric _historicClient;
  late LemonMarketsTransaction _transactionClient;

  LemonMarkets() {
    LemonMarketsHttpClient client = LemonMarketsHttpClient();
    _spacesClient = LemonMarketsSpaces(client);
    _authClient = LemonMarketsAuth(client);
    _tradingClient = LemonMarketsTrading(client);
    _marketClient = LemonMarketsMarketData(client);
    _portfolioClient = LemonMarketsPortfolio(client);
    _historicClient = LemonMarketsHistoric(client);
    _transactionClient = LemonMarketsTransaction(client);
  }

  Future<AccessToken> requestToken(String clientId, String clientSecret) async {
    AccessToken token = await _authClient.requestToken(clientId, clientSecret);
    return token;
  }

  Future<List<Instrument>> searchInstruments(AccessToken token, String? query, SearchType type) async {
    List<Instrument> result = await _tradingClient.searchInstruments(token, query, type);
    return result;
  }

  Future<CreatedOrder> placeOrder(
      AccessToken token, String spaceUuid, String isin, bool sell, int quantity, double? validUntil, double? stopPrice, double? limitPrice) async {
    String side = sell ? LemonMarketsURL.SELL_CONST : LemonMarketsURL.BUY_CONST;
    if (validUntil == null) {
      DateTime oneYear = DateTime.now().add(Duration(days: 365));
      validUntil = oneYear.toUtc().millisecondsSinceEpoch / 1000;
    }
    CreatedOrder o = await _tradingClient.placeOrder(token, spaceUuid, isin, validUntil, side, quantity, stopPrice, limitPrice);
    return o;
  }

  Future<bool> activateOrder(AccessToken token, String spaceUuid, String orderUuid) async {
    bool result = await _tradingClient.activateOrder(token, spaceUuid, orderUuid);
    return result;
  }

  Future<bool> deleteOrder(AccessToken token, String spaceUuid, String orderUuid) async {
    bool result = await _tradingClient.deleteOrder(token, spaceUuid, orderUuid);
    return result;
  }

  Future<List<ExistingOrder>> getOrders(AccessToken token, String spaceUuid,
      {int? createdAtUntil, int? createdAtFrom, OrderSide? side, OrderType? type, OrderStatus? status, int? limit, int? offset}) async {
    //isin as query parameter would be nice
    return _tradingClient.getOrders(token, spaceUuid, createdAtUntil, createdAtFrom, side, type, status, limit, offset);
  }

  Future<LatestTrade> getLatestTrade(AccessToken token, String isin) async {
    String mic = 'XMUN';
    return _marketClient.getLatestTrade(token, isin, mic);
  }

  Future<LatestQuote> getLatestQuote(AccessToken token, String isin) async {
    String mic = 'XMUN';
    return _marketClient.getLatestQuote(token, isin, mic);
  }

  Future<List<Space>> getSpaces(AccessToken token) async {
    return _spacesClient.getSpaces(token);
  }

  Future<Space> getSpace(AccessToken token, String spaceUuid) async {
    return _spacesClient.getSpace(token, spaceUuid);
  }

  Future<SpaceState> getSpaceState(AccessToken token, String spaceUuid) async {
    return _spacesClient.getSpaceState(token, spaceUuid);
  }

  Future<StateInfo> getStateInfo(AccessToken token) async {
    return _spacesClient.getStateInfo(token);
  }

  Future<List<PortfolioItem>> getPortfolioItems(AccessToken token, String spaceUuid) async {
    return _portfolioClient.getPortfolioItems(token, spaceUuid);
  }

  Future<OHLCList> getOHLC(AccessToken token, String isin, OHLCType type, DateTime? from, DateTime? until, bool? reverseOrdering) async {
    String mic = 'XMUN';
    return _historicClient.getOHLC(token, isin, mic, type, from, until, reverseOrdering);
  }

  Future<OHLCList> getOHLCFromUrl(AccessToken token, String url) async {
    return _historicClient.getOHLCFromUrl(token, url);
  }

  Future<TransactionList> getTransactionsForSpace(AccessToken token, String spaceUuid,
      {int? createdAtUntil, int? createdAtFrom, int? limit, int? offset}) async {
    return _transactionClient.getTransactionsForSpace(token, spaceUuid, createdAtFrom: createdAtFrom, createdAtUntil: createdAtUntil, limit: limit, offset: offset);
  }

  Future<Transaction> getTransactionForSpace(AccessToken token, String spaceUuid, String transactionUuid) async {
    return _transactionClient.getTransactionForSpace(token, spaceUuid, transactionUuid);
  }
}