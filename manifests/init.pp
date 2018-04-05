# == Class: nwdeploy
#
# Setup an easy Git-based deployment method.
#
# === Examples
#
# === Authors
#
# Jawaad Mahmood <jawaad.mahmood@gmail.com>

class nwdeploy {
  package {["git", "git-core"]: ensure => installed }
}
