import 'package:equatable/equatable.dart';

enum SubscriptionTier { free, premium }

enum SubscriptionStatus { unknown, loading, free, premium, error }

class SubscriptionEntity extends Equatable {
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final String? activeOfferingId;
  final String? expirationDate;
  final bool willRenew;

  const SubscriptionEntity({
    this.tier = SubscriptionTier.free,
    this.status = SubscriptionStatus.free,
    this.activeOfferingId,
    this.expirationDate,
    this.willRenew = false,
  });

  bool get isPremium => tier == SubscriptionTier.premium;

  SubscriptionEntity copyWith({
    SubscriptionTier? tier,
    SubscriptionStatus? status,
    String? activeOfferingId,
    String? expirationDate,
    bool? willRenew,
  }) {
    return SubscriptionEntity(
      tier: tier ?? this.tier,
      status: status ?? this.status,
      activeOfferingId: activeOfferingId ?? this.activeOfferingId,
      expirationDate: expirationDate ?? this.expirationDate,
      willRenew: willRenew ?? this.willRenew,
    );
  }

  @override
  List<Object?> get props => [tier, status, activeOfferingId, expirationDate, willRenew];
}
