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
}
