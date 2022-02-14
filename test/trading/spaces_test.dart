import 'package:lemon_markets_client/lemon_markets_client.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../credentials.dart';

final LemonMarkets lm = LemonMarkets();
String spaceUuid = Credentials.spaceUuid;

void main() {
  setUp(() {
    //logging
    Logger.root.level = Level.ALL; // defaults to Level.INFO
    Logger.root.onRecord.listen((record) {
      print('${record.loggerName} [${record.level.name}]: ${record.time}: ${record.message}');
    });
  }
  );

  test('createAndDeleteSpace', () async { 
    AccessToken token = AccessToken(token: Credentials.JWT_TOKEN);

    TradingResultList<Space> spaces = await lm.getSpaces(token);
    int initialSize = spaces.result.length;

    Space space = (await lm.createSpace(token, "Test2", SpaceType.manual, Amount(value: 1000000), description: 'Hallöchen Welt')).result!;
    print('space ${space.uuid} ${space.description} created');
    print(space.toString());
    spaces = await lm.getSpaces(token);
    int afterCreating = spaces.result.length;
    expect(afterCreating, equals(initialSize+1));

    DeleteSpaceResult success = await lm.deleteSpace(token, space.uuid);
    print('space deleted: $success');
    spaces = await lm.getSpaces(token);
    int afterDeleting = spaces.result.length;
    expect(afterDeleting, equals(initialSize));
  });

  test('getSpaces', () async {
    AccessToken token = AccessToken(token: Credentials.JWT_TOKEN);
    TradingResultList<Space> spaces = await lm.getSpaces(token);
    print('found ${spaces.result.length} spaces');
    spaces.result.forEach((element) {
      print(element.toString());
    });
  });

  test('getSingleSpace', () async {
    AccessToken token = AccessToken(token: Credentials.JWT_TOKEN);

    Space spaces = (await lm.getSpace(token, spaceUuid)).result!;
    print('found ${spaces.name} - ${spaces.description}');
    print(spaces);
  });

  test('deleteSingleSpace', () async {
    AccessToken token = AccessToken(token: Credentials.JWT_TOKEN);

    DeleteSpaceResult spaces = (await lm.deleteSpace(token, 'sp_pyPHTyyLL03WRlBjjpRss8FrgMP9gTDD9x'));
    print('delete ${spaces.success}');
    print(spaces);
  });


  test('alterSpace', () async {
    AccessToken token = AccessToken(token: Credentials.JWT_TOKEN);

    String now =  DateTime.now().toIso8601String();
    Space space = (await lm.alterSpace(token, spaceUuid, description: now)).result!;
    print('space altered: ${space.uuid}: set description to $now');
  });

  test('changeRiskLimit', () async {
    AccessToken token = AccessToken(token: Credentials.JWT_TOKEN);

    Space space = (await lm.createSpace(token, "Test 7", SpaceType.manual, Amount(value: 5.5), description: '5,50')).result!;
    print('space ${space.uuid} created');
    print(space.toString());

    String now =  DateTime.now().toIso8601String();
    space = (await lm.alterSpace(token, space.uuid, description: now, riskLimit: Amount(value: 20))).result!;
    print('space altered: ${space.uuid}: set description to $now and risk limit to ${space.riskLimit}');
    print(space.toString());

    DeleteSpaceResult success = await lm.deleteSpace(token, space.uuid);
    print('space deleted: $success');
  });

}
