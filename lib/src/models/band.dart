class Band {
  String id;
  String name;
  int votes;

  Band({
    required this.id,
    required this.name,
    required this.votes,
  });

  //Nueva instancia de Band
  factory Band.fromMap(Map<String, dynamic> obj) => Band(
        id: obj.containsKey('id') ? obj['id'] : 'no-id',
        name: obj.containsKey('id') ? obj['name'] : 'no-name',
        votes: obj.containsKey('id') ? obj['votes'] : 'no-votes',
      );
}
