import 'package:serverpod/protocol.dart';
import 'package:serverpod/serverpod.dart';

class Protocol extends SerializationManagerServer {
  @override
  String getModuleName() => 'wallet_explain_server';

  @override
  Table? getTableForType(Type t) => null;

  @override
  List<TableDefinition> getTargetTableDefinitions() => const [];
}
