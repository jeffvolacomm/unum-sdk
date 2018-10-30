#!/usr/bin/env bash
# Copyright 2018 Minim Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Utility for configuring two docker networks for use as the WAN and LAN
# network interfaces for a running `unum` container.

set -eo pipefail

# Usage: ./docker_network.sh <container> <host WAN ifname>
#
# The `host WAN ifname` parameter is the host machine's actual WAN interface
# name. The `container` will be configured so that its WAN interface will be
# bridged onto the host's network with a unique MAC address, as if it were a
# separate physical device.

container_name="$1"
ifname_wan="$2"
phyname=${3:-phy0}

if [[ "$ifname_wan" == "" || "$container_name" == "" ]]; then
    echo "error: must specify both container name and host WAN ifname"
    echo
    echo "Usage: $0 <container> <WAN ifname> [WLAN phy]"
    exit 1
fi

if [[ $(uname -s) == "Linux" ]]; then
    # On Linux, managing `docker` requires superuser privileges, but some
    # setups may use a 'docker' user group instead of root. This checks if the
    # uid of the current user is 0 (ie. root), failing that uses the `docker`
    # command as the final, absolute test.
    if [[ $(id -u) != "0" && \
        $(docker version > /dev/null || echo FAIL) == "FAIL" ]]
    then
        # Fail early and in a controlled manner
        echo "This command requires superuser privileges on Linux!"
        exit 1
    fi
fi

echo "---> determining subnet and gateway for host wan interface: $ifname_wan"
# ip and subnet in the form of 192.168.11.123/24
ipsubnet_host_wan=$(ip -o -f inet addr show | awk '/'"$ifname_wan"'/ { print $4 }')
# subnet in the form of 192.168.11.0/24 only handles mask bit 24
subnet_wan=$(sed -E 's:\.[0-9]+/24:.0/24:' <<< "$ipsubnet_host_wan")
# default gateway in the form of 192.168.11.1
gateway_wan=$(ip route list dev "$ifname_wan" | awk '/^default/ { print $3 }')
echo "---> host wan subnet: $subnet_wan - default gateway: $gateway_wan"


# The docker network names for the lan and wan, named so because Docker
# selects the first network, natural ordered, as the main interface
netname_lan="$container_name-net-b-lan"
netname_wan="$container_name-net-a-wan"

echo "---> lan docker network: $netname_lan - wan: $netname_wan"


# Remove the default bridge network from the container
docker network disconnect bridge "$container_name" > /dev/null 2>&1 || :

docker network disconnect "$netname_wan" "$container_name" > /dev/null 2>&1  || :
docker network disconnect "$netname_lan" "$container_name" > /dev/null 2>&1  || :
docker network rm "$netname_wan" "$netname_lan" > /dev/null 2>&1  || :

# LAN interface
echo "---> creating lan docker network $netname_lan (subnet 192.168.15.0/24)"
docker network create        \
    --driver=bridge          \
    --subnet=192.168.15.0/24 \
    --gateway=192.168.15.254 \
    --opt mode=l2            \
    --opt "com.docker.network.bridge.name=br-$container_name" \
    --aux-address "DefaultGatewayIPv4=192.168.15.1" \
    "$netname_lan"

# WAN interface
# Create a macvlan type network to give the unum container its own
# unique MAC address on the host network.
echo "---> creating wan docker network $netname_wan"
docker network create          \
    --driver=macvlan           \
    --subnet="$subnet_wan"     \
    --gateway="$gateway_wan"   \
    --opt parent="$ifname_wan" \
    "$netname_wan" || \
        (echo "---> unable to create wan network"; exit 1)

docker network connect "$netname_wan" "$container_name"
docker network connect "$netname_lan" "$container_name"

# WLAN interface
# Must assign the phy device to the container's net namespace.
echo "---> assigning $phyname to container net namespace"
pid=$(docker inspect -f '{{.State.Pid}}' "$container_name")
if [[ "$pid" == "" ]]; then
    echo "Unable to find running '$container_name' container!"
    exit 1
fi
mkdir -p /var/run/netns
ln -sf /proc/$pid/ns/net /var/run/netns/$pid
iw phy $phyname set netns $pid
