class suricata::service {

  case $::suricata::service_provider {
    'systemd': {
      
      $systemd_path = $::operatingsystem ? {
        /(Ubuntu|Debian)/ => '/lib/systemd/system',
        default           => '/usr/lib/systemd/system',
      }

      $service_require = File["${systemd_path}/suricata.service"]

      file { "${systemd_path}/suricata.service":
        ensure  => file,
        owner   => 'root',
        group   => '0',
        mode    => '0644',
        content => epp('suricata/suricata.service.epp'),
      }

      exec { 'Daemon-reload':
        command     => '/bin/systemctl daemon-reload',
        subscribe   => File["${systemd_path}/suricata.service"],
        refreshonly => true,
        notify      => Service[$::suricata::service_name],
      }
    }
    'openbsd': {
      # left empty
    }
    default: {
      $service_require = undef

      notice("Your ${::suricata::service_provider} is not supported")
    }
  }

  service { $::suricata::service_name:
    ensure   => $::suricata::service_ensure,
    enable   => $::suricata::service_enable,
    provider => $::suricata::service_provider,
    flags    => $::suricata::service_flags,
    require  => $service_require,
  }

}
