enum Audience { everyone, nobody }

class PrivacySettings {
  const PrivacySettings({this.lastSeen = Audience.everyone, this.readReceipts = true});

  final Audience lastSeen;
  final bool readReceipts;

  Map<String, dynamic> toMap() => {'lastSeen': lastSeen.name, 'readReceipts': readReceipts};

  factory PrivacySettings.fromMap(Map<String, dynamic>? m) => PrivacySettings(
    lastSeen: m?['lastSeen'] == 'nobody' ? Audience.nobody : Audience.everyone,
    readReceipts: m?['readReceipts'] as bool? ?? true,
  );

  PrivacySettings copyWith({Audience? lastSeen, bool? readReceipts}) =>
      PrivacySettings(lastSeen: lastSeen ?? this.lastSeen, readReceipts: readReceipts ?? this.readReceipts);
}

class AppUser {
  const AppUser({
    required this.uid,
    required this.username,
    required this.displayName,
    this.photoUrl,
    this.bio,
    this.privacy = const PrivacySettings(),
  });

  final String uid;
  final String username;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final PrivacySettings privacy;

  String get handle => '@$username';

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'username': username,
    'usernameLower': username.toLowerCase(),
    'displayName': displayName,
    'photoUrl': photoUrl,
    'bio': bio,
    'privacy': privacy.toMap(),
  };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
    uid: m['uid'] as String,
    username: m['username'] as String? ?? '',
    displayName: m['displayName'] as String? ?? '',
    photoUrl: m['photoUrl'] as String?,
    bio: m['bio'] as String?,
    privacy: PrivacySettings.fromMap(m['privacy'] is Map ? Map<String, dynamic>.from(m['privacy'] as Map) : null),
  );

  AppUser copyWith({String? displayName, String? photoUrl, String? bio, PrivacySettings? privacy}) => AppUser(
    uid: uid,
    username: username,
    displayName: displayName ?? this.displayName,
    photoUrl: photoUrl ?? this.photoUrl,
    bio: bio ?? this.bio,
    privacy: privacy ?? this.privacy,
  );
}
