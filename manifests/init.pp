# Class: java7
# This module installs Java 7 on Ubuntu machine
# Sample Usage:
# include java7
class java7 {
	# Update before start
	exec { "apt-update-java":
		command => "sudo apt-get update",
		before  => Exec['purge-openjdk'],
	}

	# Purge openjdk*
	exec {"purge-openjdk":
		command => 'sudo apt-get purge openjdk* -y',
		onlyif  => 'dpkg -l | grep openjdk',
		before  => Package['python-software-properties'],
	}

	# Install python software properties, required for add-apt-repository
	package { "python-software-properties":
		ensure    => installed,
		before    => Exec['webup8team'],
	}

	# Add webup8team ppa repo, Alternatively you can also use apt module and use apt::source
	exec {"webup8team":
		command => 'sudo add-apt-repository ppa:webupd8team/java -y && sudo apt-get update',
		unless  => "egrep -v '^#|^ *$' /etc/apt/sources.list /etc/apt/sources.list.d/* | grep webupd8team/java",
		before  => Package['oracle-java7-installer'],
	}

	# Add response file which will be used to accept Java license
	file { "/tmp/java.accept":
		ensure => present,
		source => 'puppet:///modules/java7/java.accept',
		mode   => '0600',
	}

	# Install Java 7 with silent option 
	# http://askubuntu.com/questions/190582/installing-java-automatically-with-silent-option
	package { "oracle-java7-installer":
		ensure       => installed,
		responsefile => '/tmp/java.accept',
		require      => File['/tmp/java.accept'],
	}
}