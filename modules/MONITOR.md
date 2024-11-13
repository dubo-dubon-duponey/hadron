# Monitoring

## State of affairs

### Discovery

There is currently no discovery mechanism.
Instead, configure manually in prometheus config using mDNS names.
These are resolving with coreDNS (when they are broadcast as workstations).
On the target nodes, expose containers inside an ad-hoc bridge network publishing the metrics port,
and just use the short docker name.

Problems:
- containers in multiple networks cannot pass options to the second one (eg: publish)
(because of Docker) - so, local DNS servers are addressed by ip
- there is no discovery per-se
- there is no protection of any kind (no auth, no TLS) for the /metrics endpoints
- internal TLS needs a working PKI anyhow

Solutions:
- ghosttunnel + pki for security
- http based mDNS resolver close to the endpoint

### Dashboards

They all suck.
It is pretty awful - they are all broken or outdated.

## Future

Get the containers inside an internal network.
Run a router that exposes these endpoints behind HTTPs with mTLS.

Rebuild / review all dashboards.

Loki and Promtails to suck up logs, and surface them into Grafana.

Look into https://github.com/hikhvar/mqtt2prometheus to funnel-in MQTT info from iOT stuff.
Alternatively, Grafana can get these directly.

Run Rudderstack for analytics.

Get tracing up and running.
