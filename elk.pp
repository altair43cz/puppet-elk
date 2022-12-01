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
