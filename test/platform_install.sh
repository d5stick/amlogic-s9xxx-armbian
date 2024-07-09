DIR=/usr/lib/linux-u-boot-vendor-mangopi-m28k
write_uboot_platform () 
{ 
    local logging_prelude="";
    [[ $(type -t run_host_command_logged) == function ]] && logging_prelude="run_host_command_logged";
    if [[ -f $1/rksd_loader.img ]]; then
        ${logging_prelude} dd if=$1/rksd_loader.img of=$2 seek=64 conv=notrunc status=none;
    else
        if [[ -f $1/u-boot.itb ]]; then
            ${logging_prelude} dd if=$1/idbloader.img of=$2 seek=64 conv=notrunc status=none;
            ${logging_prelude} dd if=$1/u-boot.itb of=$2 seek=16384 conv=notrunc status=none;
        else
            if [[ -f $1/uboot.img ]]; then
                ${logging_prelude} dd if=$1/idbloader.bin of=$2 seek=64 conv=notrunc status=none;
                ${logging_prelude} dd if=$1/uboot.img of=$2 seek=16384 conv=notrunc status=none;
                ${logging_prelude} dd if=$1/trust.bin of=$2 seek=24576 conv=notrunc status=none;
            else
                echo "Unsupported u-boot processing configuration!";
                exit 1;
            fi;
        fi;
    fi
}
write_uboot_platform_mtd () 
{ 
    if [[ -f $1/rkspi_loader.img ]]; then
        dd if=$1/rkspi_loader.img of=$2 conv=notrunc status=none > /dev/null 2>&1;
    else
        echo "SPI u-boot image not found!";
        exit 1;
    fi
}
setup_write_uboot_platform () 
{ 
    if grep -q "ubootpart" /proc/cmdline; then
        local tmp=$(cat /proc/cmdline);
        tmp="${tmp##*ubootpart=}";
        tmp="${tmp%% *}";
        [[ -n $tmp ]] && local part=$(findfs PARTUUID=$tmp 2> /dev/null);
        [[ -n $part ]] && local dev=$(lsblk -n -o PKNAME $part 2> /dev/null);
        [[ -n $dev ]] && DEVICE="/dev/$dev";
    fi
}
