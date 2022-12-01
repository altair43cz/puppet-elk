# https://forge.puppet.com/modules/puppet/elastic_stack
include elastic_stack::repo
package { 'default-jdk': ensure => 'installed' }
package { 'elasticsearch': ensure => 'installed' }
service { 'elasticsearch': ensure => 'running' }
package { 'kibana': ensure => 'installed' }
service { 'kibana': ensure => 'running' }
package { 'logstash': ensure => 'installed' }
service { 'logstash': ensure => 'running' }
file { '/etc/logstash/conf.d/02-beats-input.conf': 
         content => 'input { beats { port => 5044 } }' }

file { '/etc/logstash/conf.d/30-elasticsearch-output.conf':
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
        }' }
