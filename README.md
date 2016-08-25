# Purpose

Loadtesting LDAP servers by simulating the load during an emergency
alert, where we deliver messages to ~100K unique users very quickly.

# Prerequisites

## ansible

[https://docs.ansible.com/ansible/intro_installation.html]

## EC2 credentials

AWS credentials with the ability to manage EC2 resources can be passed to
ansible in a number of ways. The easiest is to create a file called
`~/.aws/credentials` containing the credentials you want to use.
```
[default]
aws_access_key_id = KEYID
aws_secret_access_key = KEY
```

## SSH keypair

[https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html]

## Base machine image

You can use the standard RHEL AMI corresponding to your region, a base image
you've already built, or install [Packer](https://www.packer.io/) and run
`packer build packer/template.json` to generate a new base image with some
custom configuration baked in.

## Address list

In order to properly simulate the load pattern of an emergency alert,
you should replace `ansible/files/userlist` with a list of approximately
99K valid user addresses and 6K invalid addresses. For the greatest
verisimilitude, this list can be generated from the logs of a recent
emergency alert.

# Setting up your environment

Before you do this, you should review `ansible/group_vars/all.yml`, make
any necessary configuration changes, and ensure the correct region is set
in `ec2.ini`.


```bash
. env-setup.sh
ansible-playbook ansible/provision.yml
ansible-playbook ansible/configure.yml
```

# Running a test

Run `ansible --list-hosts tag_Class_mx_loadtest_client` to discover the name
of the loadtest client, then SSH to it and run `run-loadtest`.

    [ec2-user@ip-10-236-17-11 ~]$ run-loadtest 
    Saving output to /var/tmp/loadtest.g9z9GDOf
    time,messages,data(K),errors,connections,SSL connections
    13:32,17098,93465,1451,1851,0
    time,messages,data(K),errors,connections,SSL connections
    13:32,16672,90883,1467,1869,0
    13:33,17509,95747,1487,1925,0
    13:33,17041,92706,1525,1968,0
    13:34,17010,92840,1423,1904,0
    13:34,16645,91233,1457,1887,0
    13:35,17079,93732,1497,1916,0
    13:35,17294,94453,1495,1919,0
    13:36,16667,91161,1428,1878,0
    13:36,16685,91058,1458,1868,0
    13:37,16927,92222,1421,1797,0
    13:37,16621,90001,1437,1845,0
    13:38,17070,93089,1461,1910,0
    13:38,17103,93055,1486,1923,0
    13:39,17281,94077,1495,2000,0
    13:39,17300,94617,1520,1935,0
    13:40,17026,92900,1541,1945,0
    13:40,17301,93786,1458,1875,0
    13:41,16277,89365,1399,1846,0
    13:41,16494,89782,1448,1894,0

postal has some architectural limitations so we have to run two instances in
order to achieve the proper load. Once the test is finished, you can do
whatever manipulation of the raw data you want. Here's one way:

    [ec2-user@ip-10-236-17-11 ~]$ paste -d, /var/tmp/loadtest.g9z9GDOf/stdout.* | awk -F, '{print $1, $2 + $8}'
    time 0
    13:32 33770
    13:33 34550
    13:34 33655
    13:35 34373
    13:36 33352
    13:37 33548
    13:38 34173
    13:39 34581
    13:40 34327
    13:41 32771

# Cleaning up

```bash
ansible-playbook ansible/deprovision.yml
```
