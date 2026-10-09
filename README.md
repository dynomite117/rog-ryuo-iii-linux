# rog-ryuo-iii-linux

Linux driver for the AniMe Matrix on the **ASUS ROG RYUO III** AIO (USB `0b05:1a51`).
Pure Python standard library (no kernel module, no pyusb); Pillow (python-pillow) for images.

## Usage

    ryuo3-matrix info                         # firmware / device
    ryuo3-matrix orient                       # arrow + "UP": pick --rotate so it points up
    ryuo3-matrix text "HI"                    # scrolls automatically if too long
    ryuo3-matrix text "CPU\n54°"              # two centered lines
    ryuo3-matrix text "ROG" --color red
    ryuo3-matrix clock --seconds              # HH over MM, seconds dot on the rim; Ctrl+C to stop
    ryuo3-matrix monitor --show cpu,gpu,clock # temps colored green -> red
    ryuo3-matrix rainbow
    ryuo3-matrix image pic.gif                # images and animated GIFs (uses Pillow)
    ryuo3-matrix image logo.png --crop 290,165,660,535 --remove-bg
                                              # crop a region (X,Y,W,H in source pixels) and
                                              # switch off the background color (auto-detected
                                              # from the corners, or give one: --remove-bg ffffff)
    ryuo3-matrix fill 00ffaa / off

Global options: `--rotate 0|90|180|270`, `--brightness 0-100`; defaults live in
`/etc/ryuo3-matrix.conf`. Only one process can drive the matrix at a time, so stop
the service (`systemctl stop ryuo3-matrix`) before running commands by hand.

## Install

`sudo ./install.sh` installs the tool to `/usr/local/bin`, a udev rule (non-root access
for the logged-in user), the config, and `ryuo3-matrix.service`.

The service shows a picture at boot and again whenever the cooler reconnects (the udev
rule starts it, e.g. after suspend). It expects the picture at
`/usr/local/share/ryuo3-matrix/boot.png`; to change it, replace that file or edit
`ExecStart` in `/etc/systemd/system/ryuo3-matrix.service`, then `systemctl daemon-reload`.
Enable with `systemctl enable ryuo3-matrix`. While a long-running command (clock,
monitor, GIF) holds the matrix, the service can't send and retries every 3 s.

## Protocol

See the docstring at the top of `ryuo3-matrix`. The panel is a round matrix of 255
RGB LEDs in 19 columns (mapped from photos of test patterns); the transport is the
ASUS `0xEC` HID command set plus a 768-byte bulk frame, the same scheme the ROG Z690
motherboard AniMe Matrix uses.
Frames are host-driven: a static image stays after the program exits.

### How the LED map was found

No documentation exists for this panel, so the layout was worked out by sending test
patterns and photographing them:

- [`docs/mapping-photo-1-blocks.jpg`](docs/mapping-photo-1-blocks.jpg): each 48-byte
  frame block in its own color, showing that consecutive LEDs cycle through 4 blocks.
- [`docs/mapping-photo-2-chain.jpg`](docs/mapping-photo-2-chain.jpg): every 8 LEDs of
  the chain in one color (red, green, blue, white). Runs go down each column, starting
  top-right; detecting each LED in this photo gave the column heights.

Tested on firmware `AURO1-S452-0101`. Other firmware or the RYUO III 360 may differ;
`ryuo3-matrix orient` is a quick check.

## License

MIT, see [LICENSE](LICENSE).
