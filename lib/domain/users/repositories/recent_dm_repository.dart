abstract class RecentDmRepository {
  Future<void> addRecentDm(int userId);
  Future<void> getRecentDms();
}
