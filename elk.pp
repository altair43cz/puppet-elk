# https://forge.puppet.com/modules/puppet/elastic_stack
include elastic_stack::repo
package { 'default-jdk': ensure => 'installed' }
package { 'elasticsearch': ensure => 'installed' }
service { 'elasticsearch': ensure => 'running' }
package { 'kibana': ensure => 'installed' }
service { 'kibana': ensure => 'running' }
package { 'logstash': ensure => 'installed' }
service { 'logstash': ensure => 'running' }

file { '/etc/logstash/conf.d/10-syslog-elasticsearch.conf':
         content => '#
         input { file { path => "/var/log/apache/access.log" } }
         filter { grok { match => { "message" => "%{COMBINEDAPACHELOG}" } }
             date { match => [ "timestamp" , "dd/MMM/yyyy:HH:mm:ss Z" ] }
             geoip { source => "clientip" } }
         output { elasticsearch { hosts => ["localhost:9200"] } }' }
