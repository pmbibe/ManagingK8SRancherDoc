Rancher with Kubernetes  
I.	Overview Rancher  
II.	Install Rancher  
III.	Configuration Rancher  
IV.	Prometheus     
I.	Overview Rancher  
 Rancher is open source software that combines everything an organization needs to adopt and run containers in production. Built on Kubernetes, Rancher makes it easy for DevOps teams to test, deploy and manage their applications.    
 Rancher was originally built to work with multiple orchestrators, and it included its own orchestrator called “Cattle”. With the rise of Kubernetes clusters in the marketplace, Rancher 2.x exclusively deploys and manages Kubernetes clusters running anywhere, on any provider  
 One Rancher server installation can manage thousands of Kubernetes clusters and thousands of nodes form the same user interface.  
 Rancher adds significant value on top of Kubernetes, first by centralizing authentication and role-based access control (RBAC) for all of the clusters, giving global admins the ability to control cluster access from one location.  
 It then enables detailed monitoring and alerting for clusters and their resources, ships logs to external providers, and integrates directly with Helm via the Application Catalog. If you have an external CI/CD system, you can plug it into Rancher, but if you don’t, Rancher even includes a pipeline engine to help you automatically deploy and upgrade workloads.
 Rancher is a complete container management platform for Kubernetes, giving you the tools to successfully run Kubernetes anywhere.  
 In this paper, we just talk about how to manage Kubernetes by using Rancher, which is installed on a Single Node using Docker, its version 2.4.  
II.	Install Rancher  
1.	CPU and Memory Requirements  
These requirements apply to host with a single-node installation of Rancher.  
![Alt text](images/Pic006.PNG?raw=true "Title")  
With Rancher 2.4.0++, some requirements are changed.  
![Alt text](images/Pic007.PNG?raw=true "Title")  
2.	Install Rancher  
Option A: Default Rancher-generated Self-signed Certificate  
If you are installing Rancher in a development or testing environment where identity verification isn’t a concern, install Rancher using the self-signed certificate that it generates. This installation option omits the hassle of generating a certificate yourself.  
**docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher:v2.4-head-linux-amd64**  
Option B: Bring your own certificate, Self-signed  
We can  
III.	Configuration Rancher 
![Alt text](images/Pic01.PNG?raw=true "Title")
![Alt text](images/Pic02.PNG?raw=true "Title")
![Alt text](images/Pic03.PNG?raw=true "Title")
![Alt text](images/Pic04.PNG?raw=true "Title")
IV. Prometheus  
![Alt text](images/Pic005.PNG?raw=true "Title")
