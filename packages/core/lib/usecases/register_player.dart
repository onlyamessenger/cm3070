import 'package:core/enums/enums.dart';
import 'package:core/interface/services/services.dart';
import 'package:core/models/models.dart';
import 'package:core/usecases/usecase_future.dart';

class RegisterPlayerInput {
  final String email;
  final String password;
  final String name;

  const RegisterPlayerInput({required this.email, required this.password, required this.name});
}

class RegisterPlayer extends UseCaseFuture<RegisterPlayerInput, Player> {
  final AuthService _authService;
  final PlayerService _playerService;
  final RoleService _roleService;
  final ReadinessSectionService _sectionService;
  final KitItemService _kitItemService;
  final LoggerService _logger;
  final String _playerTeamId;

  RegisterPlayer({
    required AuthService authService,
    required PlayerService playerService,
    required RoleService roleService,
    required ReadinessSectionService sectionService,
    required KitItemService kitItemService,
    required LoggerService logger,
    required String playerTeamId,
  }) : _authService = authService,
       _playerService = playerService,
       _roleService = roleService,
       _sectionService = sectionService,
       _kitItemService = kitItemService,
       _logger = logger,
       _playerTeamId = playerTeamId;

  @override
  Future<Player> execute(RegisterPlayerInput input) async {
    _logger.info('Creating auth account for ${input.email}');
    final String userId = await _authService.createAccount(
      email: input.email,
      password: input.password,
      name: input.name,
    );
    _logger.info('Auth account created: $userId');

    try {
      _logger.info('Adding $userId to team $_playerTeamId');
      await _roleService.addToTeam(userId: userId, teamId: _playerTeamId);
      _logger.info('Team membership created');

      _logger.info('Creating player document for $userId');
      final Player player = await _playerService.createPlayer(userId: userId, displayName: input.name);
      _logger.info('Player created: ${player.id}');

      // Seed readiness sections
      _logger.info('Seeding readiness sections for $userId');
      for (final ReadinessSectionType type in ReadinessSectionType.values) {
        await _sectionService.createSection(
          ReadinessSection(
            id: '',
            created: DateTime.now(),
            updated: DateTime.now(),
            createdBy: userId,
            updatedBy: userId,
            userId: userId,
            sectionType: type,
            isUnlocked: type == ReadinessSectionType.floodRisk,
            unlockedAt: type == ReadinessSectionType.floodRisk ? DateTime.now() : null,
          ),
        );
      }
      _logger.info('Readiness sections seeded');

      // Clone kit item templates
      _logger.info('Cloning kit item templates for $userId');
      final List<KitItem> templates = await _kitItemService.getPublishedTemplates();
      for (final KitItem template in templates) {
        await _kitItemService.createKitItem(
          KitItem(
            id: '',
            created: DateTime.now(),
            updated: DateTime.now(),
            createdBy: userId,
            updatedBy: userId,
            source: template.source,
            isPublished: template.isPublished,
            userId: userId,
            itemName: template.itemName,
            description: template.description,
            sortOrder: template.sortOrder,
          ),
        );
      }
      _logger.info('Kit items cloned: ${templates.length} templates');

      return player;
    } catch (e) {
      _logger.error('Registration failed at post-auth step: $e');
      _logger.info('Rolling back auth account $userId');
      try {
        await _authService.deleteAccount(userId: userId);
        _logger.info('Rollback complete');
      } catch (rollbackError) {
        _logger.error('Rollback failed: $rollbackError');
      }
      rethrow;
    }
  }
}
