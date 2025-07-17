### Multitier Architecture
### *Step 1. Create a vpc
- Go to VPC from  your Management console click create VPC.
- Name Your VPC: Eg (demovpc)
- Cider Block leave ipv4 uncheck
- Give it a ```192.168.0.0/16``` CIDR block and leave everything else as default. Click create

### Step 2. Create a subnet
- To create your subnets go to Subnets on the left hand side of the VPC service and click on it
- Add your VPC ID to where it asks 
- Assign it a name letting you know what it is your first public subnet
- Put it in any availability zone and give it a CIDR of ```192.168.1.0/24```
- Add a second subnet and name it Private Subnet 1 or something to let you know it is your first private subnet
- Put it in the same availability zone as the first subnet you made and give it a CIDR of ```192.168.2.0/24```
- Add a third subnet and assign a name letting you know it is the second private subnet you will be making
- Put it in the same availability zone as your first public subnet and give it a CIDR of ```192.168.3.0/24```
- Add a fourth and final subnet and give it a name letting you know it is the third private subnet
- Put it in a different availability zone from the rest of your subnets and give it a CIDR of 192.168.4.0/24
- Create

### Set up for route tables 
- Allocate an Elastic IP address by going to Elastic IPs on the left hand side and click “Allocate Elastic IP address
- Everything should be good as default but make sure that you are in the same region you have been creating everything in and then press “Allocate”. 
### create an internet gateway and attach your VPC
- Go to Internet Gateways on the left hand side and click“Create Internet Gateway”
- Give your internet gateway a name 
- create internet gateway
- Once it is created attach it to your VPC by clicking “Attach to a VPC
### Create a NAT Gateway 
- on the left hand side and then click “Create NAT Gateway”
- Give it a name 
- Click the drop down for Elastic IPs and click the one you created previously
- Click “Create NAT gateway
### Create Route table
- on the left hand side Route Tables” 
- Click “Create route table”
- Give it a name letting you know this is the public route table for your lab
- Assign your VPC to it and click “Create route table
- Make a second route table naming it something to let you know that this is the private route table. for your lab and assign your VPC to it.
- Now associate your subnets with their respective route table
- Click on the public route table and click on “Subnet association” next to “Details”
- Click on “Edit subnet associations
- Click on your public subnet and then click “Save associations”
- Now add a route to our public route table to get access to the internet gateway
- Click on “Routes” next to “Details” and click “Edit routes”
- Add a new route having a destination: ```0.0.0.0/0 ``. target: internet gateway``` and click “Save changes”
- ### Repeat This process: for the your private private route table.
- Click on all three of your private subnets and save the associations
- Add rout table destination: ```0.0.0.0/0``` 
- target: internet gateway
- Save changes
### Create sercurity group
- click security group
- Give it a name and description letting you know it is for a bastion host
- Assign your VPC to it
- Give it three inbound rules, one for SSH using your IP and one for HTTP using ```0.0.0.0/0 ```as well as https using ```0.0.0.0/0```
- security group

- Create 2nd security group
- Give it a name:(webserverdg)
- give description related to the name
- inbound rules: allow traffic from anywhere
ssh: ```0.0.0.0/0```, http: ```0.0.0.0/0```, https: ```0.0.0.0/0```.
- create security group

- Create 3rd security group
- security group name: (Appserversg)
- Assign your VPC to it
- Give it an inbound rule for`` All ICMP -IPv4 with a source of your``` ``webserverSG:(2nd security name)``  and another inbound rule for ```SSH with a source of your ``` ```hostsg: first security group``` 
- create

- create the 4th security group
- name: (mydatabasesg)
- Assign your VPC to it
- Give it two inbound rules both for MYSQL/Aurora and give one of them a source of your```appserverSG: (second security group name)```and the other one a source of your       ```hostSG(your first security name)```
- create 








