# https://subscription.packtpub.com/book/networking-and-servers/9781788472906/2/ch02lvl1sec19/hello-puppet-your-first-puppet-manifest
file { '/tmp/hello.txt':
  ensure  => file,
  content => "hello, world\n",
}
