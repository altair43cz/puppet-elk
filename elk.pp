# https://forge.puppet.com/modules/puppet/elastic_stack
include elastic_stack::repo
package { 'default-jdk': ensure => 'installed' }
package { 'elasticsearch': ensure => 'installed', require => Package['default-jdk'] }
service { 'elasticsearch': ensure => 'running', require => Package['elasticsearch'] }
package { 'kibana': ensure => 'installed' }
service { 'kibana': ensure => 'running', require => Package['kibana'] }
package { 'logstash': ensure => 'installed' }
service { 'logstash': ensure => 'running', require => Package['logstash'] }
package { 'mongodb-org': ensure => 'installed' }
package { 'filebeat': ensure => 'installed' }
if $filebeat == '1' {
    service { 'mongod': ensure => 'running', require => Package['mongodb-org'] } 
    service { 'filebeat': ensure => 'running', require => Package['filebeat'] } 
}

file { '/etc/logstash/conf.d/02-beats-input.conf': 
    require => Package['logstash'],
    content => 'input { beats { port => 5044 } }'
}

file {'/etc/logstash/conf.d/20-elasticsearch-syslog.conf':
    require => Package['logstash'],
    content => 'filter {
        mutate {
            add_field => {
                "[event][kind]" => "event"
                "[event][category]" => "host"
                "[event][type]" => ["info"]
                "[event][dataset]" => "system.syslog"
            }
          }
        }',
}

file {'/etc/logstash/conf.d/25-elasticsearch-error.conf':
    require => Package['logstash'],
    content => 'filter {
           if "error" in [message] {
               mutate { add_tag => "error_tag" }
           }
       }'
}

file { '/etc/logstash/conf.d/30-elasticsearch-output.conf':
    require => Package['logstash'],
    content => 'output {
          if [@metadata][pipeline] {
            elasticsearch {
            hosts => ["localhost:9200"]
            manage_template => false
            index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
            pipeline => "%{[@metadata][pipeline]}"
            }
          } else {
            elasticsearch {
            hosts => ["localhost:9200"]
            manage_template => false
            index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
            }
          }
        }' 
}

file_line { 'enable logs input':
    require => Package['filebeat'],
    path => '/etc/filebeat/filebeat.yml',
    ensure => 'present',
    match => '^  enabled: false',
    line => '  enabled: true'
}

file_line { 'disable elasticsearch output':
    require => Package['filebeat'],
    path => '/etc/filebeat/filebeat.yml',
    ensure => 'present',
    match => 'output.elasticsearch:',
    line => '# output.elasticsearch:'
}
file_line { 'disable elasticsearch out-port':
    require => Package['filebeat'],
    path => '/etc/filebeat/filebeat.yml',
    ensure => 'present',
    match => 'hosts: \["localhost:9200"\]',
    line => '# hosts: ["localhost:9200"]'
}

file_line { 'enable logstash output':
    require => Package['filebeat'],
    path => '/etc/filebeat/filebeat.yml',
    ensure => 'present',
    match => '#output.logstash:',
    line => 'output.logstash:'
}

file_line { 'enable logstash out-port':
    require => Package['filebeat'],
    path => '/etc/filebeat/filebeat.yml',
    ensure => 'present',
    match => '#hosts: \["localhost:5044"\]',
    line => '  hosts: ["localhost:5044"]'
}

file_line { 'append ilm policy':
    require => Package['filebeat'],
    path => '/etc/filebeat/filebeat.yml',
    ensure => 'present',
    line => 'setup.ilm.overwrite: true'
}
