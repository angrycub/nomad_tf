location = "East US"
image_id = "/subscriptions/2835f892-3393-4988-bf4b-c169a8b22f1e/resourceGroups/packer/providers/Microsoft.Compute/images/hashistack"
vm_size = "Standard_DS1_v2"
server_count = 3
client_count = 4
retry_join = "provider=azure tag_name=ConsulAutoJoin tag_value=auto-join subscription_id=2835f892-3393-4988-bf4b-c169a8b22f1e tenant_id=TENANT_ID client_id=CLIENT_ID secret_access_key=CLIENT_SECRET"
