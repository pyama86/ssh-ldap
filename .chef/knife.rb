cookbook_path ["cookbooks", "vendor/cookbooks"]
role_path     "roles"
data_bag_path "data_bags"
encrypted_data_bag_secret "data_bag_key"
ssl_verify_mode  :verify_peer
local_mode true
