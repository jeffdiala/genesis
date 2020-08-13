create variable file for your project that running on kubenetes with configuration bellow

```bash
touch terraform.tfvars
```
content :

```python
gcp_project_name = "company-project-env"
gcp_project_region = "us-west1"
cluster_count = 1
cluster_name = "cluster-project-dev"
linux_admin_username = "changeMe"
linux_admin_password = "changeMe"
```

don't forget to create 'secrets' directory and populate it with service account secrets. 