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
}
