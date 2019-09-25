# encoding: utf-8
#

grub_superusers = input(
  'grub_superusers',
  description: 'superusers for grub boot ( array )',
  value: ['root']
)
grub_user_boot_files = input(
 'grub_user_boot_files',
 description: 'grub boot config files',
 value: ['/boot/grub2/user.cfg']
)
grub_main_cfg = input(
 'grub_main_cfg',
 description: 'main grub boot config file',
 value: '/boot/grub2/grub.cfg'
)

control "V-71961" do
  title "Systems with a Basic Input/Output System (BIOS) must require
authentication upon booting into single-user and maintenance modes."
  desc  "If the system does not require valid root authentication before it
boots into single-user or maintenance mode, anyone who invokes single-user or
maintenance mode is granted privileged access to all files on the system. GRUB
2 is the default boot loader for RHEL 7 and is designed to require a password
to boot into single-user mode or make modifications to the boot menu."
  impact 0.7
  tag "gtitle": "SRG-OS-000080-GPOS-00048"
  tag "gid": "V-71961"
  tag "rid": "SV-86585r4_rule"
  tag "stig_id": "RHEL-07-010480"
  tag "cci": ["CCI-000213"]
  tag "documentable": false
  tag "nist": ["AC-3", "Rev_4"]
  tag "subsystems": ['grub']
  tag "check": "For systems that use UEFI, this is Not Applicable.

Check to see if an encrypted root password is set. On systems that use a BIOS,
use the following command:

# grep -i ^password_pbkdf2 /boot/grub2/grub.cfg

password_pbkdf2 [superusers-account] [password-hash]

If the root password entry does not begin with \"password_pbkdf2\", this is a
finding.

If the \"superusers-account\" is not set to \"root\", this is a finding."
  tag "fix": "Configure the system to encrypt the boot password for root.

Generate an encrypted grub2 password for root with the following command:

Note: The hash generated is an example.

# grub2-mkpasswd-pbkdf2

Enter Password:
Reenter Password:
PBKDF2 hash of your password is
grub.pbkdf2.sha512.10000.F3A7CFAA5A51EED123BE8238C23B25B2A6909AFC9812F0D45

Edit \"/etc/grub.d/40_custom\" and add the following lines below the comments:

# vi /etc/grub.d/40_custom

set superusers=\"root\"

password_pbkdf2 root {hash from grub2-mkpasswd-pbkdf2 command}

Generate a new \"grub.conf\" file with the new password with the following
commands:

# grub2-mkconfig --output=/tmp/grub2.cfg
# mv /tmp/grub2.cfg /boot/grub2/grub.cfg
"
  tag "fix_id": "F-78313r2_fix"
  describe file(grub_main_cfg) do
    its('content') { should match %r{^\s*password_pbkdf2\s+root } }
  end

  grub_user_boot_files.each do |user_cfg_file|
    next if !file(user_cfg_file).exist?
    describe.one do
      grub_superusers.each do |user|
        describe file(user_cfg_file) do
          its('content') { should match %r{^\s*password_pbkdf2\s+#{user} } }
        end
      end
    end
  end
end
