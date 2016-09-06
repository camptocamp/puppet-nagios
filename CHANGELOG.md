## 2016-09-06 - Release 1.0.31

Fix read-write dir creation

## 2016-08-17 - Release 1.0.30

Remove dependency on apache_c2c
Use standard paths for command_file

## 2016-02-03 - Release 1.0.29

Move lock_file definition to params.pp

## 2016-01-04 - Release 1.0.28

Add rw dir in /var/log/nagios for nagios 4

## 2015-12-07 - Release 1.0.27

Fix convergence on Debian 6

## 2015-12-07 - Release 1.0.26

Fix convergence on RedHat 7

## 2015-12-04 - Release 1.0.25

Fix convergence on RedHat 7

## 2015-09-30 - Release 1.0.24

Stop managing files created by nagios

## 2015-08-21 - Release 1.0.23

Use docker for acceptance tests

## 2015-07-24 - Release 1.0.22

Also collect nagios::host on nrpe server
Fix bug in remote host
Fix typo in nsca host definition

## 2015-07-24 - Release 1.0.21

Export nagios::host instead of nagios_host

## 2015-07-23 - Release 1.0.20

Realize file exported resources locally, too

## 2015-07-21 - Release 1.0.19

Use only one nagios_host resource
and realize it locally

## 2015-07-21 - Release 1.0.18

Rename active nagios_host resources
to avoid alias conflict when using Puppet 4

## 2015-07-20 - Release 1.0.17

Use namevar instead of alias for Package[nagios] on Debian
to fix Puppet 4 support.

## 2015-07-16 - Release 1.0.16

Remove nagios_alias from local resource

## 2015-07-15 - Release 1.0.15

Forgot to remove file context for RHEL7 too

## 2015-07-15 - Release 1.0.14

Remove SELinux type for a directory, already managed by RHEL policy.

## 2015-07-13 - Release 1.0.13

Fix a scope issue with generic-command template

## 2015-06-26 - Release 1.0.12

Fix strict_variables activation with rspec-puppet 2.2

## 2015-05-28 - Release 1.0.11

Add beaker_spec_helper to Gemfile

## 2015-05-26 - Release 1.0.10

Use random application order in nodeset

## 2015-05-26 - Release 1.0.9

add utopic & vivid nodesets

## 2015-05-25 - Release 1.0.8

Don't allow failure on Puppet 4

## 2015-05-13 - Release 1.0.7

Add puppet-lint-file_source_rights-check gem

## 2015-05-12 - Release 1.0.6

Don't pin beaker

## 2015-04-27 - Release 1.0.5

Add nodeset ubuntu-12.04-x86_64-openstack

## 2015-04-17 - Release 1.0.4

- Fetch fixtures from puppet forge

## 2015-04-15 - Release 1.0.3

- Use file() function instead of fileserver (way faster)

## 2015-04-03 - Release 1.0.2

- Confine rspec pinning to ruby 1.8

## 2015-03-24 - Release 1.0.1

- Various fixes

## 2015-01-19 - Release 1.0.0

- Initial Forge release
