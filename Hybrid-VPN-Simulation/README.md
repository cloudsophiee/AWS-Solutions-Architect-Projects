
## Hybrid VPN Simulation
built a simulated hybrid architecture in AWS where one VPC represented my corporate data center and another VPC represented AWS. I used OpenVPN to establish two VPN tunnels between them for redundancy. I configured routing so private networks could securely talk to each other over VPN. I tested failover and confirmed traffic rerouted if one VPN tunnel went down.

### Prerequisites For this project
*Basic AWS Knowledge
- Create a VPC
- Launch EC2 instances
- Work with security groups
- Understand route tables
- Basic Linux Skills
- SSH into EC2 instances
- Run Linux commands
- Install packages (e.g. yum, apt)
- Basic Networking Concepts
- What CIDR blocks are
- Private vs. public IPs
- Concept of routing tables
- Concept of VPNs:
  - Tunnels
  - Encryption

### What You’ll Learn By The End of this project
- Hybrid Cloud Networking Concepts
- VPN Fundamentals
- Routing & Traffic Engineering
- Security Best Practices

### Step 1
### Create a vpc (I will be creating 2 vpc one for On-Prem and the other for aws)

### VPC 1.
- Name your on-VPC: vpc-onprem
- IPv4 CIDR block: 190.160.100.0/16
- every other thing in default and create vpc

### Create Subnet
- Go to VPC → Subnets → Create subnet
- VPC: select ```vpc-onprem```
- Subnet name: subnet-onprem
- AZ: Choose any preferred az ```us-east-1a```
- Subnet IPv4 CIDR:```190.160.0.0/20```
- Click Create subnet

### Create Internet Gateway
- Go to VPC → Internet Gateways → Create internet gateway
- Name: igw-onprem
- Click Create internet gateway
- Select your new IGW → Actions → Attach to VPC → - choose vpc-onprem

### Route Tables
- create Route Table
- Go to VPC → Route Tables
- Find the route table you createsd, and attach it to the on-onprem
- Select → Routes → Edit routes
- Add:
- Destination: 0.0.0.0/0
- Target: select ```internet gateway``` and select the internet gatway you created for on-prem vpc 
- click Save

### VPC 2.
Repeat the same process and select a suitable VPC CIDR and subnet CIDR 
- Name: remote-vpc
- CIDR: 190.160.0.0/16
- create

### Subnet
- Name: subnet-aws
- CIDR: 190.160.0.0/20

### Internet Gateway
- Name: remote-igw
- save
- Attach to vpc-aws

### Route Table
- Add route:
- Destination: 0.0.0.0/0
- Target: igw-aws

### Step 2.
### Create  security group
- Security group name: onprem-sg
- VPC: selet your onprem vpc

### inbound rules 
- Type: ssh
- source : for demo purposes choose ```0.0.0.0/0``` add
- Type: Custom UDP
- Range: 0 - 6
- Source: 0.0.0.0/0

### Lunch Ec2 instance
- lunch instance
- Amazon Machine Image (AMI): Amazon Linux 2 (preferred for this project)
- Instance type: t2 micro
- Select your preferred type for a key pair or create new one
- Network Edit
- Attach your onprem vpc
- Auto-assign public IP: Enable
- select your onprem security group an lunch instance

### Repeat this process for second instance (aws instance)
- Note: use the same .key pair for the both instance
### Common mistakes to avoid when setting up EC2 instances
- ensure your security group inbound rule allows traffic from any where ```(eg: type: all traffic : source: 0.0.0.0./0)``
- enable Auto-assign Public IP during instance creation, which leaves the instance unreachable from the internet.
- ### step 3: 
- iam policy permisshion to access resources in both AZ ```iam-policy``` 
- ### Step 5
- ssh to your instance
- in your terminal ```cd to Download``` 
- navigate to your .pem file and change Execution permission ```chmod 700 (your .pem file name) and click enter``` now ssh
- ssh -i <.pemfile> ec2-user@<instance public ip>
- ### Repeat this same process for aws instance
- !(instance)[image/instance.png]

- ### Step 4 — Install OpenVPN
- on  your terminal use this command to install open vpn 
- sudo zypper refresh
- sudo zypper update
- sudo zypper install openvpn easy-rsa
- ### Step 5. Generate CA and Certificates
Pick ONE server to be your Certificate Authority (CA) (typically your AWS side). 
### step 6. Initialize EasyRSA
On the server (AWS VPN EC2):
```bash
cd ~
mkdir easy-rsa
cp -r /usr/share/easy-rsa/* easy-rsa/
cd easy-rsa
./easyrsa/init-pki
```

### step 7. Build the CA
./easyrsa build-ca nopass:(Enter a name for your CA when prompted, e.g. AWS-CA)
- ### step 8. Generate Server Keypair
./easyrsa gen-req <enter your server name> nopass 
- ./easyrsa sign server server
- #### step 9.Generate Client Keypair
On the same server:
- ./easyrsa gen-req client1 nopass
- ./easyrsa sign client client1
- Copy Certificates
- #### step 10.Configure OpenVPN Server
On your AWS VPN EC2:
Create the config file:
- sudo nano /etc/openvpn/server.conf a
- copy and paste <nano-file>
- ### Create Redundant Tunnel
- sudo cp /etc/openvpn/server.conf /etc/openvpn/server2.conf
sudo nano /etc/openvpn/server2.conf
- Change:port 1195
server 10.9.0.0 255.255.255.0
- Now you have two tunnels for redundancy:

UDP 1194 → network 10.8.0.0/24

UDP 1195 → network 10.9.0.0/24
- ### Place Certificates
Copy certs:
sudo cp ~/easy-rsa/pki/ca.crt /etc/openvpn/
sudo cp ~/easy-rsa/pki/issued/server.crt /etc/openvpn/
sudo cp ~/easy-rsa/pki/private/server.key /etc/openvpn/
- ### Enable IP Forwarding
Make it persistent: sudo bash -c "echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf"
- ### Start OpenVPN
Start both services:
sudo systemctl start openvpn@server
sudo systemctl start openvpn@server2
- Enable them to auto-start:
sudo systemctl enable openvpn@server
sudo systemctl enable openvpn@server2
- ### Check status:
sudo systemctl status openvpn@server
sudo systemctl status openvpn@server2
- ### Configure OpenVPN Client
On your on-prem EC2, create: nano ~/client1.ovpn
- ### Copy Client Files
- From AWS VPN EC2 → On-Prem EC2:
```bash
scp -i your-key.pem ec2-user@<AWS_PUBLIC_IP>:~/easy-rsa/pki/ca.crt .
```
```bash
scp -i your-key.pem ec2-user@<AWS_PUBLIC_IP>:~/easy-rsa/pki/issued/client1.crt .
```

```bash
scp -i your-key.pem ec2-user@<AWS_PUBLIC_IP>:~/easy-rsa/pki/private/client
```
(Place them alongside your .ovpn file on the on-prem EC2.)

### Start OpenVPN Client
On on-prem EC2: sudo openvpn --config client1.ovpn

output: Initialization Sequence Completed

### Adjust Routing
➤ On AWS EC2
Add a route:sudo ip route add 192.168.100.0/24 dev tun0
- If using the second tunnel, replace tun0 with tun1.
 - On On-Prem EC2
- Add route to AWS: sudo ip route add 10.10.0.0/16 dev tun0
### final step: Test Hybrid Connectivity
From on-prem EC2: ping 10.10.1.10
From AWS EC2: ping 192.168.100.10
### Test Failover
On AWS: sudo systemctl stop openvpn@server
- Client should reconnect on UDP 1195 automatically (if configured).










