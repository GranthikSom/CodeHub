abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class P2pSyncFailure extends Failure {
  const P2pSyncFailure(super.message);
}
