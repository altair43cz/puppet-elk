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
         input { file { path => "/var/log/syslog" } }
         filter { grok { match => { "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} \[%{DATA}\] %{DATA} %{WORD:type} \"userText\":\"%{DATA:userText}\",\"prduction\":%{NUMBER:prduction:int},\"version\":%{NUMBER:version:int},\"bool\":%{DATA:bool},\{\"geoPoint\":\{\"location\":\"%{DATA:location}\",\"ip\":\"%{IP:ip}\",\"latitude\":%{BASE10NUM:latitude},\"longitude\":%{BASE10NUM:longitude},(\"optionalField\":%{BASE10NUM:optionalField},)?\}\}" }
                add_field => [ "read_es", "%{@timestamp}" ] }
            date { match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ] }
            mutate { remove_field => [ "message" ]
                remove_field => [ "syslog_timestamp" ]
                convert => ["bool","boolean"]
                rename => { "ip" => "[geoPoint][ip]" }
                rename => { "latitude" => "[geoPoint][latitude]" }
                rename => { "longitude" => "[geoPoint][longitude]" }
                rename => { "location" => "[geoPoint][location]" } }
         output { elasticsearch { hosts => ["localhost:9200"] } }' }
