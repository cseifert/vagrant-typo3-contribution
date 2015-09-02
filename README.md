# Vagrant configuration for TYPO3 contribution
The repository contains configurations for Vagrant to setup up a development environment for contributing to TYPO3 CMS. After the installation a ready-to-use cloned git repository is available in /var/www/TYPO3.CMS and synchronized with the www folder of the package. Single steps described in https://wiki.typo3.org/Contribution_Walkthrough_Environment_Setup are taken by the vagrantfile for you. You only have to configure your settings.

## Installed software within the VM
The environment comes with:
  - Ubuntu 14
  - nginx
  - PHP 5.5 (PHP-FPM)
  - MariaDB
  - Composer, NPM, Bower, Grunt, GraphicsMagick
  - MailCatcher
  - phpMyAdmin

## Installation
To run the Vagrant file you first have to install [VirtualBox](https://www.virtualbox.org/) and [Vagrant](https://www.vagrantup.com/). Furthermore, you need to install a vagrant plugin by
```sh
$ vagrant plugin install vagrant-hostmanager 
```
After cloning or downloading this repository into a folder of your choice, you should edit the file "vagrantfile". The following variables should be adapted to your real account:
```sh
gerrit_username = "YOUR_TYPO3_ACCOUNT_NAME"
gerrit_name = "YOUR FIRSTNAME AND LASTNAME"
gerrit_email = "YOUR EMAIL"
```

Now, you can copy your private and public ssh key into the folder "ssh-keys". They will automatically be uploaded to the vagrants home ssh folder during installation. Nevertheless you can add the ssh key later or generate a new one by ssh-keygen. If you like to learn more about the account settings or the ssh key requirements, you can read the [Contribution Walkthrough Environment Setup Wiki](https://wiki.typo3.org/Contribution_Walkthrough_Environment_Setup).
At last, please open your prompt, switch to the downloaded folder and start the installation by
```sh
$ vagrant up
```
## Usage
After successfull installation, the following URLs should be available:
  - http://typo3cms/ (unless you didn't change the server_name variable)
  - http://typo3cms:1080/ (MailCatcher)
  - http://typo3cms/phpmyadmin/ (PhpMyAdmin)

### VM IP
Unless you didn't change the server_ip variable, the VM is available under 192.168.10.10.
### SSH access
You can log into the machine by SSH. The account is called "vagrant" and has the password "vagrant".
### MariaDB
The admin user is named "root" and has the password "root".

## Notes
The Vagrant configuration was tested on Windows with VirtualBox. Other OS or VMWare has not been tried so far.

## Feedback
This repository and the vagrant file is very new and I welcome your feedback for optimization. Just give me a note if it helped you or if there are problems you discovered. The configuration was tested on Windows.