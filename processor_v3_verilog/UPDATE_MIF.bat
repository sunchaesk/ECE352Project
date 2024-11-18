cls
echo off
echo --------------------
echo Updating MIF file...
echo --------------------
quartus_cdb --update_mif multicycle.qpf
echo --------------------------
echo Re-assembling bitstream...
echo --------------------------
quartus_asm multicycle.qpf
echo --------------------------
echo Downloading bitstream...
echo --------------------------
quartus_pgm -c usb-blaster -m jtag multicycle.cdf
echo -----------------------------------------
echo Done. Press key to close...
echo -----------------------------------------
pause