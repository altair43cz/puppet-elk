# https://forge.puppet.com/modules/puppet/elastic_stack
include elastic_stack::repo
package { 'default-jdk': ensure => 'installed' }
