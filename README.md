# monitoring-mock

`monitoring-mock` is a super simple system for testing new monitoring concepts.

This allows you to simulate a hierarchical network e.g. datacenters, hosts and services.
A simulated outage affect all systems below the broken one.

## Installation

    $ git clone https://github.com/mariussturm/monitoring-mock.git
    $ cd monitoring-mock
    $ bundle install

## Configuration
Configure your nework.

    $ vi etc/mock.yaml

Define a `type` for every entry.

### Sample configuration

    ---
      /green:
        type: datacenter
      /green/web1:
        type: host
      /green/web1/http:
        type: service
      /green/mail1:
        type: host
      /green/mail1/smtp:
        type: service
      /blue:
        type: datacenter
      /blue/web2:
        type: host
      /blue/web2/smtp:
        type: service

## Start the mock

    $ ruby mm.rb

Or use your rack server of choice

    $ ruby mm.rb -s thin

## Dashboard
You can get an overview of your simulated network under

    http://localhost:4567/dashboard

Press the `Ok` or `Critical` button to toggle the state of an entry

## Use the mock
Every mock entry can be checked via HTTP. The mock delivers a JSON string
as result.

    $ curl http://localhost:4567/green
    {"status":0,"output":"Service OK","options":{"type":"datacenter"}}

    $ curl http://localhost:4567/green/web1
    {"status":2,"output":"Service is broken","options":{"type":"host"}}

