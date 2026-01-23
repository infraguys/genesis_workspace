class CreateChannelRequestDto {
  final String name;
  final String? description;
  final List<int> subscribers;
  final bool announce;
  final bool inviteOnly;

  CreateChannelRequestDto({
    required this.name,
    this.description,
    required this.subscribers,
    this.announce = false,
    this.inviteOnly = false,
  });
}
