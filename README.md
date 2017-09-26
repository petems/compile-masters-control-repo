# compile-masters-control-repo

A Control repo to set up Compile masters and a proxy for Demos.

See https://github.com/petems/pe-compile-masters-demo for more info

## Roles

`role::com_server` Compile Master

`role::load_balancer` A server for load balancing (haproxy)

`role::mom_server` The Master of Masters
