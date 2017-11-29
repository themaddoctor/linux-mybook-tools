# linux-mybook-tools
tools for opening some encrypted WD My Book drives in linux

These tools are only useful for external drives with one of these chips on the USB-SATA bridge card:
    JMS538S,
    SW6316,
    INIC1607E,
    OXUF943SE.
These tools are specifically for mounting encrypted drives. This allows the drive to be used in linux, for example
to recover the files on it, but does not decrypt the disk for use on Windows. If you prefer to make a decrypted disk
image, see the ReallyMine project (link below).

If you would like to help in development in a simple way, please submit your keyblock (and password, if any).
Keyblocks can be uploaded as zipped binary files or by pasting the output of &quot;hexdump -C&quot; into a comment.

Users with MyPassport drives should look at this first:
http://blog.acelaboratory.com/pc-3000-hdd-how-to-solder-a-sata-adapter-to-the-usb-western-digital-drive.html

Users with MyBook Live drives should go here:
http://n-dimensional.de/blog/2012/05/01/wd-mybook-live-data-rescue

Please do not contact me about password recovery unless you can show proof of ownership for the drive.

If you follow the tutorial, but are still unable to open your drive, first check that you made no typos. Most mistakes
users make are typographical errors. If you believe that you made no such mistakes, and need further assistance, submit
a dump of the first 2MB of the drive, the keyblock (if found), and the password (if used). DO NOT send screenshots or videos.

Windows is not supported.

Mac is supported only to the extent that some scripts and commands in the tutorial can be used in the Mac Terminal app,
but mounting is not possible. Decryption is possible with a C program if you have Xcode for compiling and sufficient
room for disk images.

Try ReallyMine for creating decrypted disk images on Mac, Windows, and linux. https://github.com/andlabs/reallymine
ReallyMine is not my project. It has its own forum, if you need to ask about it.

If you find my email online, please be advised that I ignore all messages to that address. The only way to get
help is through this site. TY
