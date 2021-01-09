class Credentials {
  String platform;
  String accountName;
  String username;
  String password;
  String notes;

  Credentials(this.platform,
      {this.accountName, this.username, this.password, this.notes});

  Credentials.clone(Credentials credentials)
      : this(credentials.platform,
            accountName: credentials.accountName,
            username: credentials.username,
            password: credentials.password,
            notes: credentials.notes);

  Map<String, dynamic> toMap() => {
        'platform': platform,
        'account_name': accountName,
        'username': username,
        'password': password,
        'notes': notes,
      };

  factory Credentials.fromMap(dynamic json) {
    return Credentials(
      json['platform'] as String,
      accountName: json['account_name'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      notes: json['notes'] as String,
    );
  }

  @override
  String toString() {
    return "Platform: $platform | Account Name: $accountName | Username: $username | Password: $password | Notes: $notes";
  }
}
