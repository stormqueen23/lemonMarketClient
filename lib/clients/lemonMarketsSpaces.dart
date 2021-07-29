import 'package:lemon_markets_client/data/accessToken.dart';
import 'package:lemon_markets_client/data/resultList.dart';
import 'package:lemon_markets_client/data/space.dart';
import 'package:lemon_markets_client/data/spaceState.dart';
import 'package:lemon_markets_client/data/stateInfo.dart';
import 'package:lemon_markets_client/clients/lemonMarketsHttpClient.dart';
import 'package:lemon_markets_client/exception/lemonMarketsConvertException.dart';
import 'package:lemon_markets_client/helper/lemonMarketsURLs.dart';
import 'package:logging/logging.dart';

class LemonMarketsSpaces {
  final log = Logger('LemonMarketsSpaces');
  LemonMarketsHttpClient _client;

  LemonMarketsSpaces(this._client);

  Future<ResultList<Space>> getSpaces(AccessToken token) async {
    String url = LemonMarketsURL.BASE_URL+'/spaces/';
    LemonMarketsClientResponse response = await _client.sendGet(url, token);
    try {
      ResultList<Space> result = ResultList<Space>.fromJson(response.decodedBody);
      return result;
    } catch (e) {
      log.warning(e.toString());
      throw LemonMarketsConvertException(url, e.toString(), response.statusCode, response.decodedBody.toString());
    }
  }

  Future<Space> getSpace(AccessToken token, String uuid) async {
    String url = LemonMarketsURL.BASE_URL+'/spaces/'+uuid;
    LemonMarketsClientResponse response = await _client.sendGet(url, token);
    try {
      Space result = Space.fromJson(response.decodedBody);
      return result;
    } catch (e) {
      log.warning(e.toString());
      throw LemonMarketsConvertException(url, e.toString(), response.statusCode, response.decodedBody.toString());
    }

  }

  Future<SpaceState> getSpaceState(AccessToken token, String uuid) async {
    String url = LemonMarketsURL.BASE_URL+'/spaces/'+uuid+'/state';
    LemonMarketsClientResponse response = await _client.sendGet(url, token);
    try {
      SpaceState result = SpaceState.fromJson(response.decodedBody);
      return result;
    } catch (e) {
      log.warning(e.toString());
      throw LemonMarketsConvertException(url, e.toString(), response.statusCode, response.decodedBody.toString());
    }
  }

  Future<StateInfo> getStateInfo(AccessToken token) async {
    String url = LemonMarketsURL.BASE_URL+'/state/';
    LemonMarketsClientResponse response = await _client.sendGet(url, token);
    try {
      StateInfo result = StateInfo.fromJson(response.decodedBody);
      return result;
    } catch (e) {
      log.warning(e.toString());
      throw LemonMarketsConvertException(url, e.toString(), response.statusCode, response.decodedBody.toString());
    }
  }
}