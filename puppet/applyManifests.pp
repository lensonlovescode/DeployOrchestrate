# This puppet manifest Applies all yaml manifests to kubernetes minikube

exec {'apply manifests':
  command => 'kubectl apply -f /MinikubeManifests',
  path => ['/usr/bin', '/bin', '/usr/local/bin'],
}
