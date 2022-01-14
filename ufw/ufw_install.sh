#!/bin/bash
sudo apt-get update -y
sudo apt-get install ufw
sudo systemctl enable ufw
sudo systemctl start ufw
