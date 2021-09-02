### Backup Workflow
1. Begin edit install-dependencies.sh
   - edit password for email postfix
2. Run script install-dependencies.sh
3. Config rclone manual
   - rclone config
4. Edit script backup for app1.
5. Copy script backup-app1.sh to /usr/bin/
6. Run script backup-app1.sh for to backup app1.
7. If need backup app2, repeat step 4-6.
8. Done!

### Note rclone
- location config : /root/.config/rclone/rclone.conf
- rclone config create gdrive drive scope drive config_is_local false