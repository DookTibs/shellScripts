#!/usr/bin/expect
spawn ssh vagrant@192.168.50.50
expect "password:"
send "vagrant\n";
interact
