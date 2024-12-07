#!/bin/bash -eu

source /opt/logger/logger.sh

log_info "Starting system cleanup"

log_info "Removing SSH keys used for building"
rm -f /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys || log_error "Failed to remove SSH keys"

log_info "Clearing out machine ID"
truncate -s 0 /etc/machine-id || log_error "Failed to clear machine ID"

log_info "Removing contents of /tmp and /var/tmp"
rm -rf /tmp/* /var/tmp/* || log_error "Failed to remove temporary files"

log_info "Truncating logs that have built up during the install"
find /var/log -type f -exec truncate --size=0 {} \; || log_error "Failed to truncate logs"

log_info "Cleaning up bash history"
rm -f /root/.bash_history /home/ubuntu/.bash_history || log_error "Failed to clean up bash history"

log_info "Removing /usr/share/doc contents"
rm -rf /usr/share/doc/* || log_error "Failed to remove /usr/share/doc contents"

log_info "Removing /var/cache contents"
find /var/cache -type f -exec rm -rf {} \; || log_error "Failed to remove /var/cache contents"

log_info "Cleaning up apt cache"
sudo apt-get -y autoremove || log_error "Failed to autoremove apt packages"
sudo apt-get clean || log_error "Failed to clean apt cache."
sudo rm -rf /var/lib/apt/lists/* || log_error "Failed to remove apt lists"

log_info "Forcing a new random seed to be generated"
rm -f /var/lib/systemd/random-seed || log_error "Failed to remove random seed"

log_info "Clearing wget history"
rm -f /root/.wget-hsts || log_error "Failed to clear wget history"

log_info "Clearing bash history environment variable"
export HISTSIZE=0

log_info "System cleanup completed successfully!"
