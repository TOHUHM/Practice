class dkt_mon::sopo {

if ($facts['networking']['hostname'] == 'sopoo1php04') or ($facts['networking']['hostname'] == 'sopoo1php025') {

  file {['/data','/data/software','/data/software/php','/data/software/php/etc','/data/software/php/etc/php-fpm.d','/data/software/php/etc/php-fpm.d/php']:
    ensure  => directory,
    owner   => 'root',
    group   => 0,
    mode    => '0755',
  }

#  file {['/data/www','/data/www/web-sopo-v2','/data/www/api-sopo-v2','/data/www/api-sopo-v2/sopo_v2_backend']:
#    ensure  => directory,
#    owner   => 'nginx',
#    group   => 'nginx',
#    mode    => '0755',
# }

  file {'/var/run/php-fpm':
    ensure  => directory,
    owner   => 'nginx',
    group   => 'nginx',
    mode    => '0755',
  }

  file { ['/applog','/applog/php-fpm','/applog/nginx']:
    ensure  => directory,
    owner   => 'root',
    group   => 0, # 0 instead of root because OS X uses "wheel".
    mode    => '0755',
  }

  file {'/applog/simplesaml':
    ensure => directory;
  }

  file {'/var/log/simplesaml/':
    ensure  => link,
    require => File['/applog/simplesaml'],
    target  => '/applog/simplesaml/',
  }

  file {'/applog/simplesaml/simplesamlphp.log':
    ensure => present,
    owner  => 'nginx',
    group  => 'nginx',
    mode   => '0644',
  }

  # nginx setting and config management

  file { '/etc/nginx/nginx.conf':
    ensure  => present,
    source  => 'puppet:///modules/dkt_mon/nginx.conf',
    group   => 'root',
    owner   => 'root',
    mode    => '0755',
  }

  file { '/etc/nginx/conf.d/sopo_v2_api.conf':
    ensure  => present,
    source  => 'puppet:///modules/dkt_mon/sopo_v2_api.conf',
    group   => 'root',
    owner   => 'root',
    mode    => '0755',
  }

  file { '/etc/nginx/conf.d/sopo_v2_web.conf':
    ensure  => present,
    source  => 'puppet:///modules/dkt_mon/sopo_v2_web.conf',
    group   => 'root',
    owner   => 'root',
    mode    => '0755',
  }

  exec { 'nginx_service':
    command     => '/usr/bin/systemctl restart nginx',
    subscribe   => File['/etc/nginx/nginx.conf','/etc/nginx/conf.d/sopo_v2_api.conf','/etc/nginx/conf.d/sopo_v2_web.conf'],
    refreshonly => true,
  }

  file { '/etc/php.ini':
    ensure  => present,
    source  => 'puppet:///modules/dkt_mon/php.ini',
    group   => 'root',
    owner   => 'root',
    mode    => '0755',
  }

  file { '/etc/php-fpm.conf':
    ensure  => present,
    source  => 'puppet:///modules/dkt_mon/php-fpm.conf',
    group   => 'root',
    owner   => 'root',
    mode    => '0755',
  }

  file { '/data/software/php/etc/php-fpm.d/www.conf':
    ensure  => present,
    source  => 'puppet:///modules/dkt_mon/www.conf',
    group   => 'root',
    owner   => 'root',
    mode    => '0755',
  }

  file {'/data/software/php/etc/php-fpm.conf':
    ensure => link,
    target => '/etc/php-fpm.conf',
  }

  # file { '/data/software/nodejs':
  #     ensure  => directory,
  #     source  => 'puppet:///modules/dkt_mon/nodejs/',
  #     group   => 'root',
  #     owner   => 'root',
  #     mode    => '0755',
  #     recurse => true,
  #     purge   => true,
  #     force   => true,
  # }
  #
  # file {'/data/software/nodejs/bin/node':
  #     ensure  => link,
  #     require => File['/data/software/nodejs'],
  #     target  => '/usr/bin/node',
  #   }

  # $install_path        = '/data/software/nodejs'
  # $package_name        = 'node'
  # $package_ensure      = 'v6.9.0'
  # $repository_url      = 'https://nodejs.org/download/release'
  # $archive_name        = "${package_name}-${package_ensure}.tgz"
  # $wso2_package_source = "${repository_url}/${archive_name}"
  # https://nodejs.org/download/release/v6.9.0/node-v6.9.0.tar.gz
  #
  # archive { $archive_name:
  #   path         => "/tmp/${archive_name}",
  #   source       => $wso2_package_source,
  #   extract      => true,
  #   extract_path => $install_path,
  #   creates      => "${install_path}/${package_name}-${package_ensure}",
  #   cleanup      => true,
  #   require      => File['wso2_appdir'],
  # }

  file {'/data/software/php/sbin/':
    ensure => directory,
  }

  file {'/data/software/php/sbin/php-fpm':
    ensure => link,
    target => '/usr/sbin/php-fpm',
  }

  # file_line { 'add_envpath':
  #   require => Package[$php_packages],
  #   path    => '/etc/profile',
  #   line    => ['PATH=$PATH:/usr/local/php/bin','export PATH'],
  # }

  #   service {'php-fpm':
  #                 ensure => true,
  #                 enable => true,
  #                 restart => '/usr/bin/systemctl restart php-fpm.service',
  #                 subscribe => File['/data/software/php/etc/php-fpm.conf'],
  #         }

  user { 'sopodeploy':
    name       => 'sopodeploy',
    ensure     => present,
    require    => File['/data/www','/data/www/web-sopo-v2','/data/www/api-sopo-v2','/data/www/api-sopo-v2/sopo_v2_backend'],
  }

  exec { 'setfacl':
    command     => '/usr/bin/setfacl -R -m u:sopodeploy:rwx /data/www',
    require     => User['sopodeploy'],
  }

}else {

  $base_packages = [
    'gcc',
    'gcc-c++',
    'libxml2',
    'libxml2-devel',
    'openssl',
    'openssl-devel',
    'curl-devel',
    'libjpeg-devel',
    'libpng-devel',
    'freetype-devel',
    'libmcrypt-devel',
    'libxslt',
    'libxslt-devel',
    'bzip2-devel',
    'm4',
    'gmp-devel',
    'readline-devel',
    'nginx-1.16.1-1.el7',
    'expect'
  ]

  $php_packages = [
    'php70w',
    'php70w-fpm',
    'php70w-bcmath',
    'php70w-bz2',
    'php70w-calendar',
    'php70w-core',
    'php70w-ctype',
    'php70w-curl',
    'php70w-date',
    'php70w-dba',
    'php70w-dom',
    'php70w-exif',
    'php70w-fileinfo',
    'php70w-filter',
    'php70w-ftp',
    'php70w-gd',
    'php70w-gettext',
    'php70w-gmp',
    'php70w-hash',
    'php70w-iconv',
    'php70w-json',
    'php70w-libxml',
    'php70w-mbstring',
    'php70w-mcrypt',
    'php70w-mysqli',
    'php70w-openssl',
    'php70w-pcre',
    'php70w-pdo',
    'php70w-pdo_mysql',
    'php70w-pdo_sqlite',
    'php70w-phar',
    'php70w-posix',
    'php70w-readline',
    'php70w-reflection',
    'php70w-session',
    'php70w-shmop',
    'php70w-simplexml',
    'php70w-soap',
    'php70w-sockets',
    'php70w-spl',
    'php70w-sqlite3',
    'php70w-standard',
    'php70w-sysvmsg',
    'php70w-sysvsem',
    'php70w-sysvshm',
    'php70w-tokenizer',
    'php70w-wddx',
    'php70w-xml',
    'php70w-xmlreader',
    'php70w-xmlrpc',
    'php70w-xmlwriter',
    'php70w-xsl',
    'php70w-zip',
    'php70w-zlib',
  ]

  # file{ '/tmp/install_mcrypt.sh':
  #   ensure  => present,
  #   require => Package[$php_packages],
  #   source  => 'puppet:///modules/dkt_mon/install_mcrypt.sh',
  #   group   => 'root',
  #   owner   => 'root',
  #   mode    => '0755',
  # }

  # exec{ "install mcrypt":
  #   command => "expect /tmp/install_mcrypt.sh",
  #   user => root,
  #   require => File['/tmp/install_mcrypt.sh'],
  #   path => ["/usr/bin/expect","/usr/sbin","/bin","/bin/sh"],
  # }
  #
  # file{ '/etc/php.d/mcrypt.ini':
  #   ensure  => present,
  #   require => Exec['install mcrypt'],
  #   source  => 'puppet:///modules/dkt_mon/mcrypt.ini',
  #   group   => 'root',
  #   owner   => 'root',
  #   mode    => '0755',
  # }

  package {$php_packages:
    ensure  => 'present',
    require => Package[$base_packages],
  }

  package {$base_packages:
    require => File['/data','/data/software','/data/software/php','/data/software/php/etc','/data/software/php/etc/php-fpm.d','/data/software/php/etc/php-fpm.d/php'],
    ensure  => 'present',
  }

  file {['/data','/data/software','/data/software/php','/data/software/php/etc','/data/software/php/etc/php-fpm.d','/data/software/php/etc/php-fpm.d/php']:
    ensure  => directory,
    owner   => 'root',
    group   => 0,
    mode    => '0755',
  }

# change owner and group from root to nginx
  file {['/data/www','/data/www/web-sopo-v2','/data/www/web-sopo-v2/code_backup','/data/www/api-sopo-v2','/data/www/api-sopo-v2/sopo_v2_backend','/data/www/api-sopo-v2/code_backup']:
    ensure  => directory,
    owner   => 'nginx',
    group   => 'nginx',
    mode    => '0755',
  }



  file {'/var/run/php-fpm':
    ensure  => directory,
    require => Package[$php_packages],
    owner   => 'nginx',
    group   => 'nginx',
    mode    => '0755',
  }

  file { ['/applog','/applog/php-fpm','/applog/nginx']:
    ensure  => directory,
    require => Package[$php_packages],
    owner   => 'root',
    group   => 0, # 0 instead of root because OS X uses "wheel".
    mode    => '0755',
  }

  file {'/applog/simplesaml':
    ensure => directory;
  }

  file {'/var/log/simplesaml/':
    ensure  => link,
    require => File['/applog/simplesaml'],
    target  => '/applog/simplesaml/',
  }

  file {'/applog/simplesaml/simplesamlphp.log':
    ensure => present,
    owner  => 'nginx',
    group  => 'nginx',
    mode   => '0644',
  }

  # nginx setting

  file { '/etc/nginx/nginx.conf':
    ensure  => present,
    require => Package[$php_packages],
    source  => 'puppet:///modules/dkt_mon/nginx.conf',
    group   => 'root',
    owner   => 'root',
    mode    => '0755',
  }

  file { '/etc/nginx/conf.d/sopo_v2_api.conf':
    ensure  => present,
    require => Package[$php_packages],
    source  => 'puppet:///modules/dkt_mon/sopo_v2_api.conf',
    group   => 'root',
    owner   => 'root',
    mode    => '0755',
  }

  file { '/etc/nginx/conf.d/sopo_v2_web.conf':
    ensure  => present,
    require => Package[$php_packages],
    source  => 'puppet:///modules/dkt_mon/sopo_v2_web.conf',
    group   => 'root',
    owner   => 'root',
    mode    => '0755',
  }

  exec { 'nginx_service':
    command     => '/usr/bin/systemctl restart nginx',
    subscribe   => File['/etc/nginx/nginx.conf','/etc/nginx/conf.d/sopo_v2_api.conf','/etc/nginx/conf.d/sopo_v2_web.conf'],
    refreshonly => true,
  }

  file { '/etc/php.ini':
    ensure  => present,
    require => Package[$php_packages],
    source  => 'puppet:///modules/dkt_mon/php.ini',
    group   => 'root',
    owner   => 'root',
    mode    => '0755',
  }

  file { '/data/software/php/etc/php-fpm.d/www.conf':
    ensure  => present,
    require => Package[$php_packages],
    source  => 'puppet:///modules/dkt_mon/www.conf',
    group   => 'root',
    owner   => 'root',
    mode    => '0755',
  }

  file { '/etc/php-fpm.conf':
    ensure  => present,
    require => Package[$php_packages],
    source  => 'puppet:///modules/dkt_mon/php-fpm.conf',
    group   => 'root',
    owner   => 'root',
    mode    => '0755',
  }

  file { '/usr/lib/systemd/system/php-fpm.service':
    ensure  => present,
    require => Package[$php_packages],
    source  => 'puppet:///modules/dkt_mon/php-fpm.service',
    group   => 'root',
    owner   => 'root',
    mode    => '0755',
  }

  file {'/data/software/php/etc/php-fpm.conf':
    ensure => link,
    target => '/etc/php-fpm.conf',
  }

  file {'/data/software/php/sbin/':
    ensure => directory,
  }

  file {'/data/software/php/sbin/php-fpm':
    ensure => link,
    target => '/usr/sbin/php-fpm',
  }

  file_line {'add_envpath':
    require => Package[$php_packages],
    path    => '/etc/profile',
    line    => ['PATH=$PATH:/usr/local/php/bin','export PATH'],
  }

  service {'php-fpm':
    ensure => running,
    enable => true,
    hasrestart => true,
    restart   => '/usr/bin/systemctl restart php-fpm.service',
    subscribe => File['/data/software/php/etc/php-fpm.conf'],
  }

  user {'sopodeploy':
    name       => 'sopodeploy',
    require    => File['/data/www','/data/www/web-sopo-v2','/data/www/api-sopo-v2','/data/www/api-sopo-v2/sopo_v2_backend'],
  }

  exec { 'setfacl':
    command     => '/usr/bin/setfacl -R -m u:sopodeploy:rwx /data/www',
    require     => User['sopodeploy'],
  }

  #####myself php env test####
  # file { '/etc/nginx/conf.d/zhonghua.conf':
  #   ensure  => present,
  #   require => Package[$php_packages],
  #   source  => 'puppet:///modules/dkt_mon/zhonghua/zhonghua.conf',
  #   group   => 'root',
  #   owner   => 'root',
  #   mode    => '0755',
  # }
  #
  # file { '/var/www/html/index.php':
  #   ensure  => present,
  #   require => Package[$php_packages],
  #   source  => 'puppet:///modules/dkt_mon/zhonghua/index.php',
  #   group   => 'root',
  #   owner   => 'root',
  #   mode    => '0755',
  # }
  #
  # exec { 'nginx_service_1':
  #   command     => '/usr/bin/systemctl restart nginx',
  #   subscribe   => File['/etc/nginx/conf.d/zhonghua.conf'],
  #   refreshonly => true,
  # }
}

}
