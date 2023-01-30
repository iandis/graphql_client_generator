class Example {
  const Example({
    required this.title,
    required this.description,
  });

  factory Example.fromMap(Map<String, dynamic> map) {
    return Example(
      title: map['title'],
      description: map['description'],
    );
  }

  final String title;
  final String description;

  Map<String, dynamic> get toMap {
    return <String, dynamic>{
      'title': title,
      'description': description,
    };
  }
}
