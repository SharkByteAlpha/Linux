#!/bin/bash

read sambaYN
echo Does this machine need FTP?
read ftpYN
echo Does this machine need SSH?
read sshYN
echo Does this machine need Telnet?
read telnetYN
echo Does this machine need Mail?
read mailYN
echo Does this machine need Printing?
read printYN
echo Does this machine need MySQL?
read dbYN
echo Will this machine be a Web Server?
read httpYN
echo Does this machine need DNS?
read dnsYN
echo Does this machine allow media files?
read mediaFilesYN

clear
unalias -a
printTime "All alias have been removed."

clear
usermod -L root
printTime "Root account has been locked."

clear
chmod 640 .bash_history
printTime "Bash history file permissions set."

clear
chmod 604 /etc/shadow
printTime "Read/Write permissions on shadow have been set."

clear
printTime "Check for any user folders that do not belong to any users."
ls -a /home/ >> Desktop/Script.log

clear
printTime "Check for any files for users that should not be administrators."
ls -a /etc/sudoers.d >> Desktop/Script.log

clear
cp /etc/rc.local ~/Desktop/backups/
echo > /etc/rc.local
echo 'exit 0' >> /etc/rc.local
printTime "Any startup scripts have been removed."

clear
apt-get install ufw -y -qq
ufw enable
ufw deny 1337
printTime "Firewall enabled and port 1337 blocked."

clear
chmod 777 /etc/hosts
cp /etc/hosts ~/Desktop/backups/
echo > /etc/hosts
echo -e "127.0.0.1 localhost\n127.0.1.1 $USER\n::1 ip6-localhost ip6-loopback\nfe00::0 ip6-localnet\nff00::0 ip6-mcastprefix\nff02::1 ip6-allnodes\nff02::2 ip6-allrouters" >> /etc/hosts
chmod 644 /etc/hosts
printTime "HOSTS file has been set to defaults."

clear
chmod 777 /etc/lightdm/lightdm.conf
cp /etc/lightdm/lightdm.conf ~/Desktop/backups/
echo > /etc/lightdm/lightdm.conf
echo -e '[SeatDefaults]\nallow-guest=false\ngreeter-hide-users=true\ngreeter-show-manual-login=true' >> /etc/lightdm/lightdm.conf
chmod 644 /etc/lightdm/lightdm.conf
printTime "LightDM has been secured."

clear
find /bin/ -name "*.sh" -type f -delete
printTime "Scripts in bin have been removed."



clear
if [ $sambaYN == no ]
then
	apt-get purge samba -y -qq
	apt-get purge samba-common -y  -qq
	apt-get purge samba-common-bin -y -qq
	apt-get purge samba4 -y -qq
	clear
	printTime "Samba has been removed."
elif [ $sambaYN == yes ]
then
	echo CREATE SEPARATE PASSWORDS FOR EACH USER
	cp /etc/samba/smb.conf ~/Desktop/backups/
	gedit /etc/samba/smb.conf
else
	echo Response not recognized.
fi
printTime "Samba is complete."

clear
if [ $ftpYN == no ]
then
	ufw deny ftp 
	ufw deny sftp 
	ufw deny saft 
	ufw deny ftps-data 
	ufw deny ftps
	apt-get purge vsftpd -y -qq
	printTime "vsFTPd has been removed. ftp, sftp, saft, ftps-data, and ftps ports have been denied on the firewall."
elif [ $ftpYN == yes ]
then
	ufw allow ftp 
	ufw allow sftp 
	ufw allow saft 
	ufw allow ftps-data 
	ufw allow ftps
	cp /etc/vsftpd/vsftpd.conf ~/Desktop/backups/
	cp /etc/vsftpd.conf ~/Desktop/backups/
	gedit /etc/vsftpd/vsftpd.conf&gedit /etc/vsftpd.conf
	service vsftpd restart
	printTime "ftp, sftp, saft, ftps-data, and ftps ports have been allowed on the firewall. vsFTPd service has been restarted."
else
	echo Response not recognized.
fi
printTime "FTP is complete."


clear
if [ $sshYN == no ]
then
	ufw deny ssh
	apt-get purge openssh-server -y -qq
	printTime "SSH port has been denied on the firewall. Open-SSH has been removed."
elif [ $sshYN == yes ]
then
	ufw allow ssh
	cp /etc/ssh/sshd_config ~/Desktop/backups/	
	grep PermitRootLogin /etc/ssh/sshd_config | grep yes
	if [ $?==0 ]
	then
  	  sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
	  sed -i 's/PermitRootLogin without-password/PermitRootLogin no/g' /etc/ssh/sshd_config

	fi
	grep Protocol /etc/ssh/sshd_config | grep 1
	if [ $?==0 ]
	then
	  sed -i 's/Protocol 2,1/Protocol 2/g' /etc/ssh/sshd_config
	  sed -i 's/Protocol 1,2/Protocol 2/g' /etc/ssh/sshd_config
	fi
	grep X11Forwarding /etc/ssh/sshd_config | grep yes
	if [ $?==0 ]
	then
	  sed -i 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config
	fi
	grep PermitEmptyPasswords /etc/ssh/sshd_config | grep yes
	if [ $?==0 ]
	then
	  sed -i 's/PermitEmptyPasswords yes/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
	fi
	service ssh restart
	printTime "SSH port has been allowed on the firewall. SSH config file has been configured."
else
	echo Response not recognized.
fi
printTime "SSH is complete."

clear
if [ $telnetYN == no ]
then
	ufw deny telnet 
	ufw deny rtelnet 
	ufw deny telnets
	apt-get purge telnet -y -qq
	apt-get purge telnetd -y -qq
	apt-get inetutils-telnetd -y -qq
	apt-get telnetd-ssl -y -qq
	printTime "Telnet port has been denied on the firewall and Telnet has been removed."
elif [ $telnetYN == yes ]
then
	ufw allow telnet 
	ufw allow rtelnet 
	ufw allow telnets
	printTime "Telnet port has been allowed on the firewall."
else
	echo Response not recognized.
fi
printTime "Telnet is complete."



clear
if [ $mailYN == no ]
then
	ufw deny smtp 
	ufw deny pop2 
	ufw deny pop3
	ufw deny imap2 
	ufw deny imaps 
	ufw deny pop3s
	printTime "smtp, pop2, pop3, imap2, imaps, and pop3s ports have been denied on the firewall."
elif [ $mailYN == yes ]
then
	ufw allow smtp 
	ufw allow pop2 
	ufw allow pop3
	ufw allow imap2 
	ufw allow imaps 
	ufw allow pop3s
	printTime "smtp, pop2, pop3, imap2, imaps, and pop3s ports have been allowed on the firewall."
else
	echo Response not recognized.
fi
printTime "Mail is complete."



clear
if [ $printYN == no ]
then
	ufw deny ipp 
	ufw deny printer 
	ufw deny cups
	printTime "ipp, printer, and cups ports have been denied on the firewall."
elif [ $printYN == yes ]
then
	ufw allow ipp 
	ufw allow printer 
	ufw allow cups
	printTime "ipp, printer, and cups ports have been allowed on the firewall."
else
	echo Response not recognized.
fi
printTime "Printing is complete."



clear
if [ $dbYN == no ]
then
	ufw deny ms-sql-s 
	ufw deny ms-sql-m 
	ufw deny mysql 
	ufw deny mysql-proxy
	apt-get purge mysql -y -qq
	apt-get purge mysql-client-core-5.5 -y -qq
	apt-get purge mysql-server -y -qq
	apt-get purge mysql-server-5.5 -y -qq
	apt-get purge mysql-client-5.5 -y -qq
	printTime "ms-sql-s, ms-sql-m, mysql, and mysql-proxy ports have been denied on the firewall. MySQL has been removed."
elif [ $dbYN == yes ]
then
	ufw allow ms-sql-s 
	ufw allow ms-sql-m 
	ufw allow mysql 
	ufw allow mysql-proxy
	cp /etc/my.cnf ~/Desktop/backups/
	cp /etc/mysql/my.cnf ~/Desktop/backups/
	cp /usr/etc/my.cnf ~/Desktop/backups/
	cp ~/.my.cnf ~/Desktop/backups/
	gedit /etc/my.cnf&gedit /etc/mysql/my.cnf&gedit /usr/etc/my.cnf&gedit ~/.my.cnf
	service mysql restart
	printTime "ms-sql-s, ms-sql-m, mysql, and mysql-proxy ports have been allowed on the firewall. MySQL service has been restarted."
else
	echo Response not recognized.
fi
printTime "MySQL is complete."



clear
if [ $httpYN == no ]
then
	ufw deny http
	ufw deny https
	apt-get purge apache2 -y -qq
	rm -r /var/www/*
	printTime "http and https ports have been denied on the firewall. Apache2 has been removed. Web server files have been removed."
elif [ $httpYN == yes ]
then
	ufw allow http 
	ufw allow https
	cp /etc/apache2/apache2.conf ~/Desktop/backups/
	if [ -e /etc/apache2/apache2.conf ]
	then
  	  echo -e '\<Directory \>\n\t AllowOverride None\n\t Order Deny,Allow\n\t Deny from all\n\<Directory \/\>\nUserDir disabled root' >> /etc/apache2/apache2.conf
	fi
	chown -R root:root /etc/apache2

	printTime "http and https ports have been allowed on the firewall. Apache2 config file has been configured. Only root can now access the Apache2 folder."
else
	echo Response not recognized.
fi
printTime "Web Server is complete."



clear
if [ $dnsYN == no ]
then
	ufw deny domain
	apt-get purge bind9 -qq
	printTime "domain port has been denied on the firewall. DNS name binding has been removed."
elif [ $dnsYN == yes ]
then
	ufw allow domain
	printTime "domain port has been allowed on the firewall."
else
	echo Response not recognized.
fi
printTime "DNS is complete."


clear
if [ $mediaFilesYN == no ]
then
	find / -name "*.midi" -type f -delete
	find / -name "*.mid" -type f -delete
	find / -name "*.mod" -type f -delete
	find / -name "*.mp3" -type f -delete
	find / -name "*.mp2" -type f -delete
	find / -name "*.mpa" -type f -delete
	find / -name "*.abs" -type f -delete
	find / -name "*.mpega" -type f -delete
	find / -name "*.au" -type f -delete
	find / -name "*.snd" -type f -delete
	find / -name "*.wav" -type f -delete
	find / -name "*.aiff" -type f -delete
	find / -name "*.aif" -type f -delete
	find / -name "*.sid" -type f -delete
	find / -name "*.flac" -type f -delete
	find / -name "*.ogg" -type f -delete
	clear
	printTime "Audio files removed."

	find / -name "*.mpeg" -type f -delete
	find / -name "*.mpg" -type f -delete
	find / -name "*.mpe" -type f -delete
	find / -name "*.dl" -type f -delete
	find / -name "*.movie" -type f -delete
	find / -name "*.movi" -type f -delete
	find / -name "*.mv" -type f -delete
	find / -name "*.iff" -type f -delete
	find / -name "*.anim5" -type f -delete
	find / -name "*.anim3" -type f -delete
	find / -name "*.anim7" -type f -delete
	find / -name "*.avi" -type f -delete
	find / -name "*.vfw" -type f -delete
	find / -name "*.avx" -type f -delete
	find / -name "*.fli" -type f -delete
	find / -name "*.flc" -type f -delete
	find / -name "*.mov" -type f -delete
	find / -name "*.qt" -type f -delete
	find / -name "*.spl" -type f -delete
	find / -name "*.swf" -type f -delete
	find / -name "*.dcr" -type f -delete
	find / -name "*.dir" -type f -delete
	find / -name "*.dxr" -type f -delete
	find / -name "*.rpm" -type f -delete
	find / -name "*.rm" -type f -delete
	find / -name "*.smi" -type f -delete
	find / -name "*.ra" -type f -delete
	find / -name "*.ram" -type f -delete
	find / -name "*.rv" -type f -delete
	find / -name "*.wmv" -type f -delete
	find / -name "*.asf" -type f -delete
	find / -name "*.asx" -type f -delete
	find / -name "*.wma" -type f -delete
	find / -name "*.wax" -type f -delete
	find / -name "*.wmv" -type f -delete
	find / -name "*.wmx" -type f -delete
	find / -name "*.3gp" -type f -delete
	find / -name "*.mov" -type f -delete
	find / -name "*.mp4" -type f -delete
	find / -name "*.avi" -type f -delete
	find / -name "*.swf" -type f -delete
	find / -name "*.flv" -type f -delete
	find / -name "*.m4v" -type f -delete
	clear
	printTime "Video files removed."
	
	find /home -name "*.tiff" -type f -delete
	find /home -name "*.tif" -type f -delete
	find /home -name "*.rs" -type f -delete
	find /home -name "*.im1" -type f -delete
	find /home -name "*.gif" -type f -delete
	find /home -name "*.jpeg" -type f -delete
	find /home -name "*.jpg" -type f -delete
	find /home -name "*.jpe" -type f -delete
	find /home -name "*.png" -type f -delete
	find /home -name "*.rgb" -type f -delete
	find /home -name "*.xwd" -type f -delete
	find /home -name "*.xpm" -type f -delete
	find /home -name "*.ppm" -type f -delete
	find /home -name "*.pbm" -type f -delete
	find /home -name "*.pgm" -type f -delete
	find /home -name "*.pcx" -type f -delete
	find /home -name "*.ico" -type f -delete
	find /home -name "*.svg" -type f -delete
	find /home -name "*.svgz" -type f -delete
	clear
	printTime "Image files removed."
	
	clear
	printTime "All media files deleted."
else
	echo Response not recognized.
fi
printTime "Media files are complete."
