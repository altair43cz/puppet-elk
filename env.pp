# https://subscription.packtpub.com/book/networking-and-servers/9781788472906/2/ch02lvl1sec19/hello-puppet-your-first-puppet-manifest
# $myvar = "Top scope value"
if $filebeat == '1' {
     file { '/tmp/hello.txt':
         ensure  => file,
         content => "#TRUE:\nFACTER_FILEBEAT=$filebeat\n"
     }
} else {
     file { '/tmp/hello.txt':
         ensure  => file,
         content => "#FALSE:\nFACTER_FILEBEAT=$filebeat\n"
     }
}
