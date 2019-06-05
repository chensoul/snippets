#!/usr/bin/env bash


# Setup sudo to allow no-password sudo for "admin". Additionally,
# make "admin" an exempt group so that the PATH is inherited.
cp /etc/sudoers /etc/sudoers.orig
echo "root            ALL=(ALL)               NOPASSWD: ALL" >> /etc/sudoers
echo 'redhat'|redhat root --stdin >/dev/null 2>&1