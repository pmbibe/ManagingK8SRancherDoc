# RKE    
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
**Option A: Default Rancher-generated Self-signed Certificate**
If you are installing Rancher in a development or testing environment where identity verification isn’t a concern, install Rancher using the self-signed certificate that it generates. This installation option omits the hassle of generating a certificate yourself.  
**docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher:v2.4-head-linux-amd64**  
**Option B: Bring your own certificate, Self-signed**  
	In development or testing environments where your team will access your Rancher server, create a self-signed certificate for use with your install so that your team can verify they are connecting to your instance of Rancher.  
	After creating your certificate, run the Docker command below to install Rancher.   
 ![Alt text](images/Pic008.PNG?raw=true "Title")  
**docker run -d --restart=unless-stopped \  
  -p 80:80 -p 443:443 \  
  -v /<CERT_DIRECTORY>/<FULL_CHAIN.pem>:/etc/rancher/ssl/cert.pem \  
  -v /<CERT_DIRECTORY>/<PRIVATE_KEY.pem>:/etc/rancher/ssl/key.pem \  
  -v /<CERT_DIRECTORY>/<CA_CERTS.pem>:/etc/rancher/ssl/cacerts.pem \  
  rancher/rancher:v2.4-head-linux-amd64**  
**Option C: Bring your own Certificate, Signed by a Recognized CA**  
In production environments where you are exposing an app publicly, use a certificate signed by a recognized CA so that your user base does not encounter security warnings.  
Note: Use the --no-cacerts as argument to the container to disable the default CA certificate generated by Rancher.  
![Alt text](images/Pic009.PNG?raw=true "Title")  
**docker run -d --restart=unless-stopped \  
  -p 80:80 -p 443:443 \  
  -v /<CERT_DIRECTORY>/<FULL_CHAIN.pem>:/etc/rancher/ssl/cert.pem \  
  -v /<CERT_DIRECTORY>/<PRIVATE_KEY.pem>:/etc/rancher/ssl/key.pem \  
        rancher/rancher:v2.4-head-linux-amd64 \  
  --no-cacerts**  
**Option D: Let’s Encrypt Certificate**  
	In production environments, you also have the option of using Let’s Encrypt certificates. You can bind the hostname to the IP address by creating an A record in DNS  
**docker run -d --restart=unless-stopped \  
  -p 80:80 -p 443:443 \  
  --privileged \  
  rancher/rancher:v2.4-head-linux-amd64 \  
  --acme-domain <YOUR.DNS.NAME>**  
With YOUR.DNS.NAME is your domain name    
3.	Login and Import Cluster  
After you log in, you will make some one-time configurations such as: changing a password for the default admin account, setting the Rancher Server URL which can be your server’s IP address.  
In order to import the exist Cluster, choose Add Cluster. It will give you a command which you have to run if for importing your Cluster into Rancher.  
Then you can see your Cluster on Rancher.  
![Alt text](images/Pic01.PNG?raw=true "Title")  
 Click to your Cluster Name, you will see the Dashboard of your Cluster. It illustrates the information which your cluster, include: CPU, Memory, Pods, …  
![Alt text](images/Pic02.PNG?raw=true "Title")  
Further, it demonstrates some metrics such as: Cluster, Etcd, Kubernetes Components and Events of your Cluster  
![Alt text](images/Pic03.PNG?raw=true "Title")   
Instead of typing kubectl get node -o wide, you can see Node’s information of your Cluster here  
![Alt text](images/Pic04.PNG?raw=true "Title")  
III.	 Install Prometheus  
Prometheus provides a time series of your data. You can configure these services to collect logs at either the cluster level or the project level.  
In other words, Prometheus lets you view metrics from your different Rancher and Kubernetes object. Using timestamps, Prometheus lets you query and view these metrics in easy-to-read graphs and visuals, either through the Rancher UI or Grafana, which is an analytics viewing platform deployed along with Prometheus.  
By viewing data that Prometheus scrapes from you cluster control plane, nodes, and deployment, you can stay on top of everything happening in your cluster. You can then use these analytics to better run your organization: stop system emergencies before they start, develop maintenance strategies, restore crashed servers, etc.  
Using Prometheus, you can monitor Rancher at both the cluster level and project level. For each cluster and project that is enabled for monitoring, Rancher deploys a Prometheus server.  
- Clustering monitoring allows you to view health of your Kubernetes cluster. Prometheus collects metrics from the cluster components below, which you can view in graphs and charts.  
    - Kubernetes control plane  
    - Etcd database  
    - All nodes  
- Project monitoring allows you to view the state of pods running in a given project. Prometheus collects metrics from the project’s deployed HTTP and TCP/UDP workloads.  
As an administrator or cluster owner, you can configure Rancher to deploy Prometheus to monitor your Kubernetes cluster.  
Note: Make sure that you are allowing traffic on port 9796 for each of your nodes because Prometheus will scrape metrics from here.  
1.	Resource consumption  
When enabling cluster monitoring, you need to ensure your worker nodes and Prometheus pod have enough resources. The tables below provides a guide of how much resource consumption will be used. In larger deployments, it is strongly advised that the monitoring infrastructure be placed on dedicated nodes in the cluster.  
The table is the resource consumption of the Prometheus pod, which is based on the number of all the nodes in the cluster. The count of nodes includes the worker, control plane and etcd nodes. When enabling cluster level monitoring, you should adjust the CPU and Memory limits and reservation. 1 CPU = 1000 Milli CPU.  
![Alt text](images/Pic010.PNG?raw=true "Title")  
Additional pod resource requirement for cluster level monitoring.  
![Alt text](images/Pic011.PNG?raw=true "Title")  
Besides the Prometheus pod, there are components that are deployed that require additional resources on the worker nodes.  
![Alt text](images/Pic014.PNG?raw=true "Title")  
With Project-level Monitoring Resource Requirements as the table showed below:  
![Alt text](images/Pic012.PNG?raw=true "Title")
2.	Prometheus Configuration  
The table given below shows basic configuration of Prometheus:  
![Alt text](images/Pic013.PNG?raw=true "Title")  
After applying Prometheus, you wait for some minutes. When it completed, you can access Grafana via Rancher Proxy. The default username and password for the Granafa instance will be admin/admin. However, Grafana dashboards are served via the Rancher authentication proxy, so only user who currently authenticated into the Rancher server have access to Grafana dashboard.  
![Alt text](images/Pic005.PNG?raw=true "Title")
