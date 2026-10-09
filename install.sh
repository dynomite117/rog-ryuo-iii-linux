#!/bin/sh
# Install ryuo3-matrix system-wide. Run as root.
set -e
cd "$(dirname "$0")"
install -m 755 ryuo3-matrix /usr/local/bin/ryuo3-matrix
install -m 644 60-ryuo3-matrix.rules /etc/udev/rules.d/60-ryuo3-matrix.rules
[ -e /etc/ryuo3-matrix.conf ] || install -m 644 ryuo3-matrix.conf /etc/ryuo3-matrix.conf
install -m 644 ryuo3-matrix.service /etc/systemd/system/ryuo3-matrix.service
udevadm control --reload-rules
udevadm trigger --attr-match=idVendor=0b05 --attr-match=idProduct=1a51 || true
systemctl daemon-reload
echo "Installed. Start at boot with: systemctl enable --now ryuo3-matrix"
