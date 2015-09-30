#!/system/bin/sh

if [ ! $# -eq 1 ]; then
    echo "please use SCurrentTest.sh 1 => enter airplane"
    echo "please use SCurrentTest.sh 0 => leave airplane"
    exit 0
fi

if [ "$1" == "1" ]; then
    # Issue Airplane mode command
    # ----------------------------------------------------------------------
    setprop sys.settings_system_version $(($(getprop sys.settings_system_version) + 1))
    sqlite3 /data/data/com.android.providers.settings/databases/settings.db "update system set value=1 where name='airplane_mode_on';"
    am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true
    sync
    sleep 3
    # ----------------------------------------------------------------------
    # Check Wifi Off
    # ----------------------------------------------------------------------
    is_wifi_on=`busybox lsmod | busybox grep wlan`

    if busybox test "$is_wifi_on"; then
        svc wifi disable
        sleep 3

        check_wifi_on=`busybox lsmod | busybox grep wlan`
        if busybox test "$check_wifi_on"; then
            svc wifi disable
            sleep 3

            recheck_wifi_on=`busybox lsmod | busybox grep wlan`
            if busybox test "$recheck_wifi_on"; then
                echo "wifi off fail"
                exit
            fi
         fi
     fi
    # ----------------------------------------------------------------------

    # Check BT Off
    # ----------------------------------------------------------------------
    is_bt_on=`/system/xbin/bttest is_enabled | busybox grep "= 1"`

    if busybox test "$is_bt_on"; then
        /system/xbin/bttest disable > /dev/null
        sleep 1
        check_is_bt_on=`/system/xbin/bttest is_enabled | busybox grep "= 1"`

        if busybox test "$check_is_bt_on"; then
            /system/xbin/bttest disable > /dev/null
            sleep 1
            recheck_is_bt_on=`/system/xbin/bttest is_enabled | busybox grep "= 1"`
            if busybox test "$recheck_is_bt_on"; then
                echo "bt off fail"
                exit
            fi
        fi
    fi

    # ----------------------------------------------------------------------

    # Check Modem Off
    # ----------------------------------------------------------------------
    cnt=0
    while [ $cnt -lt 7 ]; do
        cnt=$(($cnt + 1));
        phone_mode=`serial_client -c at+cfun? | grep "+CFUN: 0"`
        if [ ! "$phone_mode" == "" ]; then
            break;
        fi
        sleep 3
    done

    if [ $cnt -eq 7 ]; then
        setprop sys.settings_system_version $(($(getprop sys.settings_system_version) + 1))
        sqlite3 /data/data/com.android.providers.settings/databases/settings.db "update system set value=1 where name='airplane_mode_on';"
        am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true
        sync
        sleep 3
        cnt=0
        while [ $cnt -lt 7 ]; do
            cnt=$(($cnt + 1));
            phone_mode=`serial_client -c at+cfun? | grep "+CFUN: 0"`
            if [ ! "$phone_mode" == "" ]; then
                break;
            fi
            sleep 3
        done
        if [ $cnt -eq 7 ]; then
            serial_client -c at+cfun=0
            phone_mode=`serial_client -c at+cfun? | grep "+CFUN: 0"`
            if [ "$phone_mode" == "" ]; then
                echo "phone off fail";
                exit 3;
            fi
        fi
    fi
    # ----------------------------------------------------------------------

    sleep 1
    echo "OK"
fi

if [ "$1" == "0" ]; then
    # Issue Airplane mode command
    # ----------------------------------------------------------------------
    setprop sys.settings_system_version $(($(getprop sys.settings_system_version) + 1))
    sqlite3 /data/data/com.android.providers.settings/databases/settings.db "update system set value=0 where name='airplane_mode_on';"
    am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false
    sync
    sleep 3
    # ----------------------------------------------------------------------

    # Check Modem on
    # ----------------------------------------------------------------------
    cnt=0
    while [ $cnt -lt 7 ]; do
        cnt=$(($cnt + 1));
        phone_mode=`serial_client -c at+cfun? | grep "+CFUN: 1"`
        if [ ! "$phone_mode" == "" ]; then
            break;
        fi
        sleep 3
    done

    if [ $cnt -eq 7 ]; then
        setprop sys.settings_system_version $(($(getprop sys.settings_system_version) + 1))
        sqlite3 /data/data/com.android.providers.settings/databases/settings.db "update system set value=0 where name='airplane_mode_on';"
        am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false
        sync
        sleep 3
        cnt=0
        while [ $cnt -lt 7 ]; do
            cnt=$(($cnt + 1));
            phone_mode=`serial_client -c at+cfun? | grep "+CFUN: 1"`
            if [ ! "$phone_mode" == "" ]; then
                break;
            fi
            sleep 3
        done
        if [ $cnt -eq 7 ]; then
            serial_client -c at+cfun=1
            phone_mode=`serial_client -c at+cfun? | grep "+CFUN: 1"`
            if [ "$phone_mode" == "" ]; then
                echo "phone on fail";
                exit 3;
            fi
        fi
    fi
    # ----------------------------------------------------------------------

    sleep 1
    echo "OK"
fi

