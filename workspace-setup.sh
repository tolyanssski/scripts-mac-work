#!/bin/bash

# на УДАЛЁННОМ сервере
echo 'net.ipv4.ip_unprivileged_port_start=0' | sudo tee /etc/sysctl.d/60-unprivileged-ports.conf
echo 'net.ipv6.ip_unprivileged_port_start=0' | sudo tee -a /etc/sysctl.d/60-unprivileged-ports.conf
sudo sysctl --system
