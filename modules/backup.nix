{ inputs, ... }:

{
  flake.nixosModules.backup = { config, pkgs, lib, ... }: {
    
    # 1. Decrypt secrets
    sops.secrets.backup_password = { };
    sops.secrets.rclone_conf = { };

    # 2. Restic Configuration
    services.restic.backups = {
      # --- Local Backup (HDD) ---
      localbackup = {
        initialize = true;

        # Where to save the backup
        repository = "/mnt/spin/backup/restic-repo";

        # File containing the repository password
        passwordFile = config.sops.secrets.backup_password.path;

        # What to backup
        paths = [ "/home/maw" "/mnt/stuff/Jobb PC" ];

        # Exclude heavy/unnecessary folders
        exclude = [
          "/home/maw/.cache"
          "/home/maw/.local/share/Steam"
          "/home/maw/Downloads"
          "/home/maw/.cargo" # Rust build artifacts
          "*.qcow2" # VM images
          "*.iso"
        ];

        # Schedule (Systemd Timer format)
        timerConfig = {
          OnCalendar = "05:30";
          Persistent = true;
        };

        # Maintenance (Pruning old snapshots)
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 6"
        ];
      };

      # --- Cloud Backup (Google Drive via Rclone) ---
      remotebackup = {
        initialize = true;

        # Use rclone as the backend.
        # Syntax: rclone:<remote-name-in-conf>:<folder-path>
        repository = "rclone:gdrive:nixos-backup";

        # Point to the rclone config file (decrypted by sops)
        rcloneConfigFile = config.sops.secrets.rclone_conf.path;
        passwordFile = config.sops.secrets.backup_password.path;

        paths = [ "/home/maw" "/mnt/stuff/Jobb PC" ];
        exclude = [
          "/home/maw/.cache"
          "/home/maw/.local/share/Steam"
          "/home/maw/Downloads"
          "/home/maw/.cargo"
          "*.qcow2"
          "*.iso"
          # You might want to exclude more large files for cloud to save bandwidth
          "/home/maw/Videos"
        ];
        
        timerConfig = {
          OnCalendar = "05:00";
          # Run at 2 AM
          Persistent = true;
        };
        
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
        ];
      };
    };

    # Ensure restic is installed for manual restores
    environment.systemPackages = [ pkgs.restic ];
  };
}
