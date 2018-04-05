define nwdeploy::basic ($app_name) {

    file{ "/home/${app_name}/repo":
        ensure => "directory",
        require => User["${app_name}"],
        owner => "${app_name}",
        group => "${app_name}",
        recurse => true, # These must be available to the group and to the user.
        mode => "2770"
    }

    exec { "Create ${app_name} Git deployment repo":
      cwd => "/home/${app_name}/repo",
      user => "${app_name}",
      command => "git init --bare --shared=group",
      creates => "/home/${app_name}/repo/.git/HEAD",
      require => [Package["git"], File["/home/${app_name}/"], User[$app_name]],
      unless => "/bin/cat /home/${app_name}/app/.git/HEAD",
    }

    exec { "Create ${app_name} Web Directory":
      cwd => "/home/${app_name}/app",
      user => "${app_name}",
      command => "git init --shared=group",
      creates => "/home/${app_name}/app/.git/HEAD",
      require => Exec["Create ${app_name} Git deployment repo"]
    }

    exec { "Setting ${app_name} Origin":
      cwd => "/home/${app_name}/app",
      user => "${app_name}",
      command => "git remote add origin /home/${app_name}/repo",
      require => [Package["git"], Exec["Create ${app_name} Web Directory"]],
      unless => "grep 'origin' /home/${app_name}/app/.git/config",
    }

    file{ "/home/${app_name}/repo/hooks/post-update":
        ensure => "present",
        owner => "${app_name}",
        group => "${app_name}",
        mode => "755",
        content => template("nwdeploy/deploy-post-update"),
        require => Exec["Create ${app_name} Git deployment repo"]
    }

}