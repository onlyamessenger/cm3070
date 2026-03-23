import 'package:appwrite/appwrite.dart';
import 'package:core/core.dart' hide AuthService, RoleService;
import 'package:fortify/appwrite/data_sources/appwrite_activity_log_data_source.dart';
import 'package:fortify/appwrite/data_sources/appwrite_bonus_event_data_source.dart';
import 'package:fortify/appwrite/data_sources/appwrite_player_challenge_progress_data_source.dart';
import 'package:fortify/appwrite/data_sources/appwrite_player_quest_progress_data_source.dart';
import 'package:fortify/appwrite/data_sources/appwrite_readiness_section_data_source.dart';
import 'package:fortify/controllers/challenge_play_controller.dart';
import 'package:fortify/controllers/profile_controller.dart';
import 'package:fortify/controllers/quest_play_controller.dart';
import 'package:fortify/controllers/readiness_controller.dart';
import 'package:fortify/state/challenge_play_state.dart';
import 'package:fortify/state/profile_state.dart';
import 'package:fortify/state/quest_play_state.dart';
import 'package:fortify/state/readiness_state.dart';
import 'package:fortify/appwrite/data_sources/appwrite_player_data_source.dart';
import 'package:fortify/controllers/player_controller.dart';
import 'package:fortify/state/player_state.dart';
import 'package:fortify/appwrite/data_sources/appwrite_challenge_data_source.dart';
import 'package:fortify/appwrite/data_sources/appwrite_challenge_question_data_source.dart';
import 'package:fortify/appwrite/data_sources/appwrite_kit_item_data_source.dart';
import 'package:fortify/appwrite/data_sources/appwrite_level_data_source.dart';
import 'package:fortify/appwrite/data_sources/appwrite_quest_data_source.dart';
import 'package:fortify/appwrite/data_sources/appwrite_quest_node_data_source.dart';
import 'package:fortify/config/environment.dart';
import 'package:fortify/controllers/auth_controller.dart';
import 'package:fortify/controllers/admin/admin_bonus_event_controller.dart';
import 'package:fortify/controllers/admin/admin_challenge_controller.dart';
import 'package:fortify/controllers/admin/admin_kit_item_controller.dart';
import 'package:fortify/controllers/admin/admin_level_controller.dart';
import 'package:fortify/controllers/admin/admin_quest_controller.dart';
import 'package:fortify/controllers/admin/admin_role_controller.dart';
import 'package:fortify/interface/services/services.dart';
import 'package:fortify/services/services.dart';
import 'package:fortify/state/auth_state.dart';
import 'package:fortify/state/admin/admin_bonus_event_state.dart';
import 'package:fortify/state/admin/admin_challenge_state.dart';
import 'package:fortify/state/admin/admin_kit_item_state.dart';
import 'package:fortify/state/admin/admin_level_state.dart';
import 'package:fortify/state/admin/admin_quest_state.dart';
import 'package:fortify/state/admin/admin_role_state.dart';

void registerDependencies() {
  final Client client = Client()
      .setEndpoint(Environment.appwriteEndpoint)
      .setProject(Environment.appwriteProjectId)
      .setSelfSigned(status: false);

  // ── AppWrite SDK ──
  Inject.registerSingleton<Client>(client);
  Inject.registerSingleton<Account>(Account(client));
  Inject.registerSingleton<Functions>(Functions(client));
  Inject.registerSingleton<Databases>(Databases(client));
  Inject.registerSingleton<Storage>(Storage(client));
  Inject.registerSingleton<Realtime>(Realtime(client));
  Inject.registerSingleton<Teams>(Teams(client));

  // ── Services (interface → implementation) ──
  Inject.registerSingleton<AppService>(AppWriteService(functions: Inject.get<Functions>()));
  Inject.registerSingleton<AuthService>(AppWriteAuthService(account: Inject.get<Account>()));
  Inject.registerSingleton<RoleService>(
    AppWriteRoleService(teams: Inject.get<Teams>(), adminTeamId: Environment.appwriteAdminTeamId),
  );

  // ── Data Sources ──
  Inject.registerSingleton<DataSource<Level>>(
    AppWriteLevelDataSource(
      databases: Inject.get<Databases>(),
      databaseId: Environment.appwriteDatabaseId,
      collectionId: Environment.levelsCollectionId,
    ),
  );
  Inject.registerSingleton<DataSource<Challenge>>(
    AppWriteChallengeDataSource(
      databases: Inject.get<Databases>(),
      databaseId: Environment.appwriteDatabaseId,
      collectionId: Environment.challengesCollectionId,
    ),
  );
  Inject.registerSingleton<DataSource<ChallengeQuestion>>(
    AppWriteChallengeQuestionDataSource(
      databases: Inject.get<Databases>(),
      databaseId: Environment.appwriteDatabaseId,
      collectionId: Environment.challengeQuestionsCollectionId,
    ),
  );
  Inject.registerSingleton<DataSource<Quest>>(
    AppWriteQuestDataSource(
      databases: Inject.get<Databases>(),
      databaseId: Environment.appwriteDatabaseId,
      collectionId: Environment.questsCollectionId,
    ),
  );
  Inject.registerSingleton<DataSource<QuestNode>>(
    AppWriteQuestNodeDataSource(
      databases: Inject.get<Databases>(),
      databaseId: Environment.appwriteDatabaseId,
      collectionId: Environment.questNodesCollectionId,
    ),
  );
  Inject.registerSingleton<DataSource<KitItem>>(
    AppWriteKitItemDataSource(
      databases: Inject.get<Databases>(),
      databaseId: Environment.appwriteDatabaseId,
      collectionId: Environment.kitItemsCollectionId,
    ),
  );
  Inject.registerSingleton<DataSource<BonusEvent>>(
    AppWriteBonusEventDataSource(
      databases: Inject.get<Databases>(),
      databaseId: Environment.appwriteDatabaseId,
      collectionId: Environment.bonusEventsCollectionId,
    ),
  );
  Inject.registerSingleton<DataSource<Player>>(
    AppWritePlayerDataSource(
      databases: Inject.get<Databases>(),
      databaseId: Environment.appwriteDatabaseId,
      collectionId: Environment.playersCollectionId,
    ),
  );
  Inject.registerSingleton<DataSource<PlayerChallengeProgress>>(
    AppWritePlayerChallengeProgressDataSource(
      databases: Inject.get<Databases>(),
      databaseId: Environment.appwriteDatabaseId,
      collectionId: Environment.playerChallengeProgressCollectionId,
    ),
  );
  Inject.registerSingleton<DataSource<PlayerQuestProgress>>(
    AppWritePlayerQuestProgressDataSource(
      databases: Inject.get<Databases>(),
      databaseId: Environment.appwriteDatabaseId,
      collectionId: Environment.playerQuestProgressCollectionId,
    ),
  );
  Inject.registerSingleton<DataSource<ReadinessSection>>(
    AppWriteReadinessSectionDataSource(
      databases: Inject.get<Databases>(),
      databaseId: Environment.appwriteDatabaseId,
      collectionId: Environment.readinessSectionsCollectionId,
    ),
  );
  Inject.registerSingleton<DataSource<ActivityLogEntry>>(
    AppWriteActivityLogDataSource(
      databases: Inject.get<Databases>(),
      databaseId: Environment.appwriteDatabaseId,
      collectionId: Environment.activityLogCollectionId,
    ),
  );

  // ── State (pure data containers) ──
  Inject.registerSingleton<AuthState>(AuthState());
  Inject.registerSingleton<AdminLevelState>(AdminLevelState());
  Inject.registerSingleton<AdminChallengeState>(AdminChallengeState());
  Inject.registerSingleton<AdminQuestState>(AdminQuestState());
  Inject.registerSingleton<AdminKitItemState>(AdminKitItemState());
  Inject.registerSingleton<AdminBonusEventState>(AdminBonusEventState());
  Inject.registerSingleton<AdminRoleState>(AdminRoleState());
  Inject.registerSingleton<PlayerState>(PlayerState());
  Inject.registerSingleton<ChallengePlayState>(ChallengePlayState());
  Inject.registerSingleton<QuestPlayState>(QuestPlayState());
  Inject.registerSingleton<ReadinessState>(ReadinessState());
  Inject.registerSingleton<ProfileState>(ProfileState());

  // ── Controllers ──
  Inject.registerSingleton<AuthController>(
    AuthController(
      authService: Inject.get<AuthService>(),
      roleService: Inject.get<RoleService>(),
      state: Inject.get<AuthState>(),
    ),
  );
  Inject.registerSingleton<AdminLevelController>(
    AdminLevelController(
      dataSource: Inject.get<DataSource<Level>>(),
      state: Inject.get<AdminLevelState>(),
      functions: Inject.get<Functions>(),
    ),
  );
  Inject.registerSingleton<AdminChallengeController>(
    AdminChallengeController(
      dataSource: Inject.get<DataSource<Challenge>>(),
      questionDataSource: Inject.get<DataSource<ChallengeQuestion>>(),
      state: Inject.get<AdminChallengeState>(),
      functions: Inject.get<Functions>(),
    ),
  );
  Inject.registerSingleton<AdminQuestController>(
    AdminQuestController(
      dataSource: Inject.get<DataSource<Quest>>(),
      nodeDataSource: Inject.get<DataSource<QuestNode>>(),
      state: Inject.get<AdminQuestState>(),
      functions: Inject.get<Functions>(),
    ),
  );
  Inject.registerSingleton<AdminKitItemController>(
    AdminKitItemController(
      dataSource: Inject.get<DataSource<KitItem>>(),
      state: Inject.get<AdminKitItemState>(),
      functions: Inject.get<Functions>(),
    ),
  );
  Inject.registerSingleton<AdminBonusEventController>(
    AdminBonusEventController(
      dataSource: Inject.get<DataSource<BonusEvent>>(),
      state: Inject.get<AdminBonusEventState>(),
      functions: Inject.get<Functions>(),
    ),
  );
  Inject.registerSingleton<AdminRoleController>(
    AdminRoleController(roleService: Inject.get<RoleService>(), state: Inject.get<AdminRoleState>()),
  );
  Inject.registerSingleton<PlayerController>(
    PlayerController(
      playerDataSource: Inject.get<DataSource<Player>>(),
      levelDataSource: Inject.get<DataSource<Level>>(),
      functions: Inject.get<Functions>(),
      state: Inject.get<PlayerState>(),
    ),
  );
  Inject.registerSingleton<ReadinessController>(
    ReadinessController(
      sectionDataSource: Inject.get<DataSource<ReadinessSection>>(),
      kitItemDataSource: Inject.get<DataSource<KitItem>>(),
      questDataSource: Inject.get<DataSource<Quest>>(),
      questNodeDataSource: Inject.get<DataSource<QuestNode>>(),
      challengeDataSource: Inject.get<DataSource<Challenge>>(),
      state: Inject.get<ReadinessState>(),
    ),
  );
  Inject.registerSingleton<ChallengePlayController>(
    ChallengePlayController(
      challengeDataSource: Inject.get<DataSource<Challenge>>(),
      questionDataSource: Inject.get<DataSource<ChallengeQuestion>>(),
      progressDataSource: Inject.get<DataSource<PlayerChallengeProgress>>(),
      functions: Inject.get<Functions>(),
      state: Inject.get<ChallengePlayState>(),
      playerController: Inject.get<PlayerController>(),
      readinessController: Inject.get<ReadinessController>(),
    ),
  );
  Inject.registerSingleton<QuestPlayController>(
    QuestPlayController(
      questDataSource: Inject.get<DataSource<Quest>>(),
      questNodeDataSource: Inject.get<DataSource<QuestNode>>(),
      progressDataSource: Inject.get<DataSource<PlayerQuestProgress>>(),
      functions: Inject.get<Functions>(),
      state: Inject.get<QuestPlayState>(),
      playerController: Inject.get<PlayerController>(),
      readinessController: Inject.get<ReadinessController>(),
    ),
  );
  Inject.registerSingleton<ProfileController>(
    ProfileController(
      activityLogDataSource: Inject.get<DataSource<ActivityLogEntry>>(),
      questPlayController: Inject.get<QuestPlayController>(),
      challengePlayController: Inject.get<ChallengePlayController>(),
      state: Inject.get<ProfileState>(),
    ),
  );
}
