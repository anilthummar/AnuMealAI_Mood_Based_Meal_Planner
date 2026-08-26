/// Narrow interface [FeatureAccessService] depends on so `core` never has to
/// import the subscription feature's domain layer. The subscription
/// feature's repository implementation is registered under this type in the
/// DI container — see `core/dependency_injection/injection_container.dart`.
abstract class PremiumStatusProvider {
  bool get isPremium;

  Stream<bool> get premiumChanges;
}
