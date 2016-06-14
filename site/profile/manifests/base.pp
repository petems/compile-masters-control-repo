class profile::base {

  $enable_firewall  = hiera('profile::base::enable_firewall',true)

  Firewall {
    before  => Class['profile::fw::post'],
    require => Class['profile::fw::pre'],
  }

  if $enable_firewall {
    class { 'firewall':
    }
    class {['profile::fw::pre','profile::fw::post']:
    }
  } else {
    class { 'firewall':
      ensure => stopped,
    }
  }

  file { ['/etc/puppetlabs/facter','/etc/puppetlabs/facter/facts.d']:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  @@host { $::fqdn:
    ensure        => present,
    host_aliases  => [$::hostname],
    ip            => $::ipaddress_eth1,
  }

  host { 'localhost':
    ensure       => present,
    host_aliases => ['localhost.localdomai','localhost6','localhost6.localdomain6'],
    ip           => '127.0.0.1',
  }

  Host <<| |>>

  if $purge {
    resources { 'host':
      purge => true,
    }
  }
}
