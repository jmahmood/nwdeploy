define nwdeploy::db($user, $db) {

  # createuser
  # createdb
  # add permissions on db to user

  # 1. Modify logins so we don't need passwords.
  # (use templated postgres version)

  if !defined(Service["postgresql"]) {
    service { "postgresql":
        ensure  => "running",
        enable  => "true",
        require => Package["postgresql"],
    }
  }

  file_line {  "passwordless connection for postgres ${user}  ${db}":
    path  => "/etc/postgresql/${postgres_version}/main/pg_hba.conf",
    line  => 'local all postgres trust',
    match => 'local all postgres trust',
    require => Package["postgresql"],
  }


  exec { "create db user ${user}":
    command     => "createuser --no-createdb --no-createrole --no-superuser --username=postgres --no-password ${user}",
    unless      => "psql postgres -tAc \"SELECT 1 FROM pg_roles WHERE rolname='${user}'\" -U postgres | grep \"1\"",
    require    => File_Line["passwordless connection for postgres ${user}  ${db}"],
    user => postgres,
  }

  exec { "Enable Passwordless login for ${user} on ${db}":
    command     => "sed -i \"75i local ${db} ${user} trust\" /etc/postgresql/${postgres_version}/main/pg_hba.conf",
    unless      => "grep \"local ${db} ${user} trust\" /etc/postgresql/${postgres_version}/main/pg_hba.conf",
    require    => Exec["create db user ${user}"],
    notify  => Service["postgresql"],
    user => postgres,
  }

  exec { "Create Unicode db (${db}) for user ${user}":
    command     => "createdb --encoding UNICODE ${db} -O ${user} --username postgres --template=template0",
    unless      => "psql -l -U postgres | grep \"${db}\" | wc -l | grep \"1\"",
    require    => Exec["Enable Passwordless login for ${user} on ${db}"],
    user => postgres,
  }

  # 3. Run as user postgres.
  # createdb --encoding UNICODE $db -O $user --username postgres --template=template0

  # psql -d template1 -U postgres
  # CREATE USER tom WITH PASSWORD 'myPassword';
  # CREATE DATABASE jerry;
  # GRANT ALL PRIVILEGES ON DATABASE jerry to tom;
}