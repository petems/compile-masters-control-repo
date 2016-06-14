class profile::mom {

  require profile::base

  $manage_r10k          = hiera('profile::mom::manage_r10k', true)
  $r10k_sources         = hiera_hash('profile::mom::r10k_sources', undef)
  $manage_hiera         = hiera('profile::mom::manage_hiera', true)
  $hiera_backends       = hiera_hash('profile::mom::hiera_backends', undef)
  $hiera_hierarchy      = hiera_array('profile::mom::hiera_hierarchy', undef)
  $enable_firewall      = hiera('profile::mom::enable_firewall',true)
  $manage_eyaml         = hiera('profile::mom::manage_eyaml', false)

  Firewall {
    proto  => tcp,
    action => accept,
    before  => Class['profile::fw::post'],
    require => Class['profile::fw::pre'],
  }

  if $enable_firewall {
    firewall { '100 allow puppet access':
      port   => [8140],
    }

    firewall { '100 allow mco access':
      port   => [61613],
    }

    firewall { '100 allow amq access':
      port   => [61616],
    }

    firewall { '100 allow console access':
      port   => [443],
    }

    firewall { '100 allow nc access':
      port   => [4433],
    }

    firewall { '100 allow puppetdb access':
      port   => [8081],
    }
  }

  if $manage_r10k and ! $r10k_sources {
    fail('The hash `r10k_sources` must exist when managing r10k')
  }

  if $manage_hiera and (! $hiera_backends or ! $hiera_hierarchy) {
    fail('The hash `hiera_backends` and array `hiera_hierarchy` must exist when managing hiera')
  }

  if $manage_r10k {
    class { '::r10k':
      version                 => '2.0.3',
      configfile              => '/etc/puppetlabs/r10k/r10k.yaml',
      sources                 => $r10k_sources,
      notify                  => Exec['r10k_sync'],
    }

    exec { 'r10k_sync':
      command     => '/opt/puppetlabs/puppet/bin/r10k deploy environment -p',
      refreshonly => true,
    }

    include ::r10k::mcollective
  }

  if $manage_hiera {
    package { 'hiera-eyaml':
      ensure   => present,
      provider => 'puppetserver_gem',
      before   => File['/etc/puppetlabs/code/hiera.yaml'],
    }

    if $manage_eyaml {
      file { '/etc/puppetlabs/puppet/ssl/private_key.pkcs7.pem':
        ensure  => file,
        owner   => 'pe-puppet',
        group   => 'pe-puppet',
        mode    => '0600',
        content => file('/etc/puppetlabs/puppet/ssl/private_key.pkcs7.pem'),
        before   => File['/etc/puppetlabs/code/hiera.yaml'],
      }

      file { '/etc/puppetlabs/puppet/ssl/public_key.pkcs7.pem':
        ensure  => file,
        owner   => 'pe-puppet',
        group   => 'pe-puppet',
        mode    => '0644',
        content => file('/etc/puppetlabs/puppet/ssl/public_key.pkcs7.pem'),
        before   => File['/etc/puppetlabs/code/hiera.yaml'],
      }
    }

    file { '/etc/puppetlabs/code/hiera.yaml':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('profile/hiera.yaml.erb'),
      notify  => Service['pe-puppetserver'],
    }
  }

  package { 'puppetclassify':
    ensure   => present,
    provider => 'puppetserver_gem',
  }

}
