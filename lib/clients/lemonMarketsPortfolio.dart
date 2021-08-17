import 'package:lemon_markets_client/data/accessToken.dart';
import 'package:lemon_markets_client/data/portfolioItem.dart';
import 'package:lemon_markets_client/clients/lemonMarketsHttpClient.dart';
import 'package:lemon_markets_client/data/portfolioTransaction.dart';
import 'package:lemon_markets_client/data/resultList.dart';
import 'package:lemon_markets_client/exception/lemonMarketsConvertException.dart';
import 'package:lemon_markets_client/helper/lemonMarketsTimeConverter.dart';
import 'package:lemon_markets_client/helper/lemonMarketsURLs.dart';
import 'package:logging/logging.dart';

class LemonMarketsPortfolio {
  final log = Logger('LemonMarketsPortfolio');
  LemonMarketsHttpClient _client;

  LemonMarketsPortfolio(this._client);

  Future<ResultList<PortfolioItem>> getPortfolioItems(AccessToken token, String spaceUuid) async {
    String url = LemonMarketsURL.BASE_URL+'/spaces/'+spaceUuid+'/portfolio/';
    return getPortfolioItemsByUrl(token, url);
  }

  Future<ResultList<PortfolioItem>> getPortfolioItemsByUrl(AccessToken token, String url) async {
    LemonMarketsClientResponse response = await _client.sendGet(url, token);
    try {
      ResultList<PortfolioItem> result = ResultList<PortfolioItem>.fromJson(response.decodedBody);
      return result;
    } catch (e, stackTrace) {
      log.warning(e.toString());
      throw LemonMarketsConvertException(url, e.toString(), response.statusCode, response.decodedBody.toString(), stackTrace);
    }
  }

  Future<ResultList<PortfolioTransaction>> getPortfolioTransactions(AccessToken token, String spaceUuid,
      {DateTime? createdAtUntil, DateTime? createdAtFrom, int? limit, int? offset}) async {
    String url = LemonMarketsURL.BASE_URL+'/spaces/'+spaceUuid+'/portfolio/transactions/';
    String append = _generateParamString(createdAtUntil: createdAtUntil, createdAtFrom: createdAtFrom, limit: limit, offset: offset);
    url += append;
    return getPortfolioTransactionsByUrl(token, url);
  }

  Future<ResultList<PortfolioTransaction>> getPortfolioTransactionsByUrl(AccessToken token, String url) async {
    LemonMarketsClientResponse response = await _client.sendGet(url, token);
    try {
      ResultList<PortfolioTransaction> result = ResultList<PortfolioTransaction>.fromJson(response.decodedBody);
      return result;
    } catch (e, stackTrace) {
      log.warning(e.toString());
      throw LemonMarketsConvertException(url, e.toString(), response.statusCode, response.decodedBody.toString(), stackTrace);
    }
  }

  String _generateParamString({DateTime? createdAtUntil, DateTime? createdAtFrom, int? limit, int? offset}) {
    List<String> query = [];
    if (createdAtUntil != null) {
      query.add("created_at_until="+LemonMarketsTimeConverter.getDoubleTimeForDateTime(createdAtUntil).toString());
    }
    if (createdAtFrom != null) {
      query.add("created_at_from="+LemonMarketsTimeConverter.getDoubleTimeForDateTime(createdAtFrom).toString());
    }
    if (limit != null) {
      query.add("limit="+limit.toString());
    }
    if (offset != null) {
      query.add("offset="+offset.toString());
    }
    String result = LemonMarketsHttpClient.generateQueryParams(query);
    return result;
  }
}