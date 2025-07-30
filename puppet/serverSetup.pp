# This puppet manifest:
#  1. updates the server
#  2. Installs and runs nginx
#  3. Installs and runs Docker
#  4. Adds the current user to the docker group
#  5. Ensures Minikube is installed
#  6. Ensures Minikube is running with one control node and one worker node

exec { 'update':
  command  => 'apt update',
  provider => 'shell'
}

package { 'nginx':
  ensure  => 'installed',
  require => Exec['update']
}

service {'nginx':
  ensure => running,
  enable => true,
  require => Package['nginx']
}

package {'docker-ce':
  ensure => 'installed',
  require => Service['nginx']
}

exec { 'add user to docker group':
  command => 'usermod -aG docker $SUDO_USER',
  unless => 'id -nG $SUDO_USER | grep -q "docker"',
  path => ['/usr/bin', '/bin', '/usr/local/bin']
}

service {'docker':
  ensure => running,
  enable => true,
  require => Package['docker-ce']
}

exec {'install minikube':
  command => 'curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && install minikube-linux-amd64 /usr/local/bin/minikube',
  unless => 'which minikube',
  path => ['/usr/bin', '/bin', '/usr/local/bin']
}


exec {'install kubectl':
  command => 'curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl &&
             install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl',
  unless => 'which kubectl',
  path => ['/usr/bin', '/bin', '/usr/local/bin'],
}

exec {'start cluster':
  command => 'su -l $SUDO_USER -c "minikube start"',
  unless => 'minikube status | grep -q Running',
  path => ['/usr/bin', '/bin', '/usr/local/bin'],
}
