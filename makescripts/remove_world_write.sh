#!/bin/bash
# Remove write permissions for world-writable files
find / -type f -writable -exec chmod o-w {} \;
