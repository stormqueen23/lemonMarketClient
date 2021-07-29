import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_markets_client/data/existingOrderList.dart';
import 'package:lemon_markets_client/data/portfolioTransactionList.dart';
import 'package:lemon_markets_client/data/transaction.dart';
import 'package:lemon_markets_client/data/transactionList.dart';
import 'package:lemon_markets_client/lemon_markets_client.dart';

import 'credentials.dart';

String clientId = Credentials.clientId;
String clientSecret = Credentials.clientSecret;
String spaceUuid = Credentials.spaceUuid;
String transactionUuidPayIn = Credentials.transactionUuidPayIn;

final LemonMarkets lm = LemonMarkets();

void main() {
  test('requestToken', () async {
    AccessToken token = await lm.requestToken(clientId, clientSecret);
    expect(token, isNotNull);
  });

  test('getSpaces', () async {
    AccessToken token = await lm.requestToken(clientId, clientSecret);
    List<Space> spaces = await lm.getSpaces(token);
    expect(spaces.length, 1);
    expect(spaces[0].uuid, spaceUuid);
  });

  test('getTransactionsForSpace', () async {
    AccessToken token = await lm.requestToken(clientId, clientSecret);
    TransactionList list = await lm.getTransactionsForSpace(token, spaceUuid);
    expect(list.result.length, greaterThan(0));
  });

  test('getTransactionsForPortfolio', () async {
    AccessToken token = await lm.requestToken(clientId, clientSecret);
    PortfolioTransactionList list = await lm.getTransactionsForPortfolio(token, spaceUuid);
    expect(list.result.length, greaterThan(0));
  });

  test('getTransactionsForSpaceFromUntil', () async {
    AccessToken token = await lm.requestToken(clientId, clientSecret);
    DateTime from = DateTime(2021, 6, 23, 9);
    double fromDouble = LemonMarketsTimeConverter.getDoubleTimeForDateTime(from);
    DateTime until = DateTime(2021, 7, 15, 14, 3);
    double untilDouble = LemonMarketsTimeConverter.getDoubleTimeForDateTime(until);
    TransactionList list = await lm.getTransactionsForSpace(token, spaceUuid, createdAtFrom: fromDouble.toInt(), createdAtUntil: untilDouble.toInt());
    expect(list.result.length, 2);
  });

  test('getTransactionsFromURL', () async {
    AccessToken token = await lm.requestToken(clientId, clientSecret);
    TransactionList list = await lm.getTransactionsForSpace(token, spaceUuid, limit: 1);
    expect(list.result.length, 1);
    expect(list.next, isNotNull);
    String nextUrl = list.next!;
    TransactionList nextList = await lm.getTransactionsFromURL(token, nextUrl);
    expect(nextList, isNotNull);
  });

  test('getTransactionForSpace', () async {
    AccessToken token = await lm.requestToken(clientId, clientSecret);
    Transaction transaction = await lm.getTransactionForSpace(token, spaceUuid, transactionUuidPayIn);
    expect(transaction.order, null);
  });

  test('getTradingVenues', () async {
    AccessToken token = await lm.requestToken(clientId, clientSecret);
    TradingVenueList tradingVenues = await lm.getTradingVenues(token);
    expect(tradingVenues.result, isNotEmpty);
  });

  test('getXMUNTradingVenue', () async {
    AccessToken token = await lm.requestToken(clientId, clientSecret);
    String mic = 'XMUN';
    TradingVenue tradingVenue = await lm.getTradingVenue(token, mic);
    expect(tradingVenue.mic, mic);
  });

  test('getXMUNOpeningDays', () async {
    AccessToken token = await lm.requestToken(clientId, clientSecret);
    String mic = 'XMUN';
    OpeningDaysList openingDays = await lm.getTradingVenueOpeningDays(token, mic);
    expect(openingDays.result, isNotEmpty);
  });

  test('searchInstrumentsWithoutParams', () async {
    AccessToken token = await lm.requestToken(clientId, clientSecret);
    InstrumentList all = await lm.searchInstruments(token);
    expect(all.result.length, greaterThan(0));
  });

  test('searchInstrumentsWithQuery', () async {
    AccessToken token = await lm.requestToken(clientId, clientSecret);
    InstrumentList all = await lm.searchInstruments(token, search: 'Tesla');
    expect(all.result.length, greaterThan(0));
  });

  test('searchInstrumentsWithQueryAndType', () async {
    AccessToken token = await lm.requestToken(clientId, clientSecret);
    InstrumentList all = await lm.searchInstruments(token, search: 'Tesla', type: SearchType.STOCK);
    expect(all.result.length, greaterThan(0));
  });

  test('searchInstrumentsWithQueryAndLimit', () async {
    AccessToken token = await lm.requestToken(clientId, clientSecret);
    InstrumentList all = await lm.searchInstruments(token, search: 'Tesla', limit: "2");
    expect(all.result.length, 2);
  });

  test('searchInstrumentsWithQueryAndLimitAndOffset', () async {
    AccessToken token = await lm.requestToken(clientId, clientSecret);
    InstrumentList prev = await lm.searchInstruments(token, search: 'Tesla', limit: "1", offset: 0);
    InstrumentList all = await lm.searchInstruments(token, search: 'Tesla', limit: "1", offset: 1);
    expect(prev.result.length, 1);
    expect(all.result.length, 1);
    expect(all.result.first.isin, isNot(prev.result.first.isin));
  });

  test('searchInstrumentsWithQueryAndCurrency', () async {
    AccessToken token = await lm.requestToken(clientId, clientSecret);
    InstrumentList all = await lm.searchInstruments(token, search: 'Tesla', currency: 'USD');
    expect(all.result.length, greaterThan(0));
  });

  test('getOrders', () async {
    AccessToken token = await lm.requestToken(clientId, clientSecret);
    ExistingOrderList all = await lm.getOrders(token, Credentials.spaceUuid);
    expect(all.result.length, greaterThan(0));
  });
}
