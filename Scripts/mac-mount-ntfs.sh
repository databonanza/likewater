brew install ntfs-3g
sudo mkdir /Volumes/NTFS
DISK=$(diskutil list\
	| egrep '(Microsoft|NTFS)'\
	| awk '/disk/{print $NF}')
sudo umount /dev/${DISK}
sudo /usr/local/bin/ntfs-3g /dev/${DISK} /Volumes/NTFS -olocal -oallow_other

