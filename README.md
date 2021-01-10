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
In this paper, we just talk about how to manage Kubernetes by using Rancher.  
II.	Install Rancher  
We will discuss about how to install Rancher on a Single Node using Docker. Personally, I think this is the easiest and fastest for installing Rancher.  
1.	CPU and Memory Requirements  
These requirements apply to host with a single-node installation of Rancher.  
 
With Rancher 2.4.0++, some requirements are changed.  
 
2.	Install Rancher  
Option A: Default Rancher-generated Self-signed Certificate  
If you are installing Rancher in a development or testing environment where identity verification isn’t a concern, install Rancher using the self-signed certificate that it generates. This installation option omits the hassle of generating a certificate yourself.  
With Rancher v2.5, privileged access is required.  
docker run -d --restart=unless-stopped \  
  -p 80:80 -p 443:443 \  
  --privileged \  
  rancher/rancher:latest  
Option B: Bring your own certificate, Self-signed  
We can  
III.	Configuration Rancher 
![Alt text](images/Pic01.PNG?raw=true "Title")
![Alt text](images/Pic02.PNG?raw=true "Title")
![Alt text](images/Pic03.PNG?raw=true "Title")
![Alt text](images/Pic04.PNG?raw=true "Title")
IV. Prometheus  
![Alt text](images/Pic005.PNG?raw=true "Title")
