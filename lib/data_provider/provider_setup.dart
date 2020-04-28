import 'package:backtoschool/data_provider/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ...independentServices,
  ...dependentServices,
  ...uiConsumableProviders,
];

List<SingleChildWidget> independentServices = [
  ChangeNotifierProvider<UserDataProvider>(
    create: (_) {
      var _userDataProvider = UserDataProvider();

      /// try to load any persistent saved data
      /// once loaded from memory reauthenticat user
      _userDataProvider.loadSavedData();
      return _userDataProvider;
    },
  ),
];
List<SingleChildWidget> dependentServices = [
//  ChangeNotifierProxyProvider<UserDataProvider, MessagesDataProvider>(
//      create: (_) {
//    var messageDataProvider = MessagesDataProvider();
//    return messageDataProvider;
//  }, update: (_, userDataProvider, messageDataProvider) {
//    messageDataProvider.userDataProvider = userDataProvider;
//    messageDataProvider.fetchMessages();
//    return messageDataProvider;
//  }),
];
List<SingleChildWidget> uiConsumableProviders = [];
