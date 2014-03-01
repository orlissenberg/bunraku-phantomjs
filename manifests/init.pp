# == Class: phantomjs
#
# Full description of class phantomjs here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { phantomjs:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#

class phantomjs  ($phantomjsversion = "1.9.2", $phantomcleanup = "true") {
  case $::operatingsystem {
    'CentOS' : {
      # Package["openssl-devel"]
      $requiredpackages = ["gcc", "gcc-c++", "make", "freetype-devel", "fontconfig-devel"]

      package {$requiredpackages:
        ensure => present,
      }

      Package<||> -> Exec["wget-phantomjs"]

      exec { "wget-phantomjs":
        command => "wget https://phantomjs.googlecode.com/files/phantomjs-${phantomjsversion}-linux-x86_64.tar.bz2",
        cwd     =>"/tmp",
        path    => ["/usr/bin", "/usr/sbin"],
        creates => "/usr/local/bin/phantomjs",
      } ->

      exec { "extract-phantomjs":
        command => "tar -xvf phantomjs-${phantomjsversion}-linux-x86_64.tar.bz2",
        cwd     =>"/tmp",
        path    => ["/bin", "/usr/bin", "/usr/sbin"],
        creates => "/usr/local/bin/phantomjs",
      } ->

      file { "move-phantomjs":
        ensure => present,
        path => "/usr/local/bin/phantomjs",
        source => "/tmp/phantomjs-${phantomjsversion}-linux-x86_64/bin/phantomjs",
        mode => "0755",
      }

      if $phantomcleanup == 'true' {
        File["move-phantomjs"] -> Exec["remove-tmp"]

        exec {"remove-tmp":
          command => "rm -Rf /tmp/phantomjs-${phantomjsversion}*",
          path => ["/bin"],
        }
      }
    } # end CentOS

    default : {
    fail("Operating system is unsupported.")
    }
  } # end case
}