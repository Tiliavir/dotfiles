#!/usr/bin/env bash

nmcli connection show --active
nmcli connection delete pvpn-killswitch
nmcli connection delete pvpn-ipv6leak-protection
