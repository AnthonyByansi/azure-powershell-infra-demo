### Use-Case Scenario: Deploying a Scalable Web Application Infrastructure on Azure  

**Scenario:**  
You are tasked with building a scalable, secure web application infrastructure for a fictional company, *Contoso Web Services*. The infrastructure should include:  

1. **Networking:**  
   - A virtual network (VNet) with subnets for web, application, and database tiers.  
   - A network security group (NSG) for securing each subnet.  

2. **Compute:**  
   - Two virtual machines (VMs) for the web tier, behind a load balancer.  
   - One VM for the application tier.  

3. **Storage:**  
   - A storage account for application data.  

4. **Database:**  
   - An Azure SQL database for data storage.  

5. **Monitoring:**  
   - Set up monitoring with Azure Monitor and Log Analytics.  

6. **Security:**  
   - Role-Based Access Control (RBAC) for managing resource access.  

---

### Repository Structure   

```
azure-powershell-infra/
├── README.md
├── scripts/
│   ├── 01-create-resource-group.ps1
│   ├── 02-setup-networking.ps1
│   ├── 03-deploy-virtual-machines.ps1
│   ├── 04-configure-storage.ps1
│   ├── 05-deploy-sql-database.ps1
│   ├── 06-setup-monitoring.ps1
│   └── 07-cleanup-resources.ps1
├── templates/
│   ├── vm-parameters.json
│   └── sql-database-parameters.json
├── diagrams/
│   └── infrastructure-diagram.png
├── docs/
│   ├── setup-instructions.md
│   └── troubleshooting.md
└── .gitignore
```

---

### Script Details  

1. **`01-create-resource-group.ps1`**  
   - Creates a resource group.  
   ```powershell
   New-AzResourceGroup -Name "ContosoWebAppRG" -Location "EastUS"
   ```  

2. **`02-setup-networking.ps1`**  
   - Creates a virtual network, subnets, and NSGs.  

3. **`03-deploy-virtual-machines.ps1`**  
   - Deploys web and application VMs, configures load balancing for the web tier.  

4. **`04-configure-storage.ps1`**  
   - Sets up a storage account and blob container.  

5. **`05-deploy-sql-database.ps1`**  
   - Provisions an Azure SQL Database and configures its firewall rules.  

6. **`06-setup-monitoring.ps1`**  
   - Configures Azure Monitor and links Log Analytics to resources.  

7. **`07-cleanup-resources.ps1`**  
   - Deletes all resources to clean up the subscription.  
