import 'package:core/enums/enums.dart';
import 'package:core/models/model_base.dart';

class PartyMember extends ModelBase {
  String partyId;
  String userId;
  PartyMemberRole role;
  int weeklyXpContribution;
  DateTime joinedAt;

  PartyMember({
    required super.id,
    required super.created,
    required super.updated,
    required super.createdBy,
    required super.updatedBy,
    super.isDeleted,
    required this.partyId,
    required this.userId,
    required this.role,
    this.weeklyXpContribution = 0,
    required this.joinedAt,
  });

  @override
  PartyMember copyWith({
    String? id,
    DateTime? created,
    DateTime? updated,
    String? createdBy,
    String? updatedBy,
    bool? isDeleted,
    String? partyId,
    String? userId,
    PartyMemberRole? role,
    int? weeklyXpContribution,
    DateTime? joinedAt,
  }) {
    return PartyMember(
      id: id ?? this.id,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      isDeleted: isDeleted ?? this.isDeleted,
      partyId: partyId ?? this.partyId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      weeklyXpContribution: weeklyXpContribution ?? this.weeklyXpContribution,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
