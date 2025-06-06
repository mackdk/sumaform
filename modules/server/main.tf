variable "images" {
  default = {
    "4.3-released"    = "sles15sp4o"
    "4.3-nightly"     = "sles15sp4o"
    "4.3-pr"          = "sles15sp4o"
    "4.3-beta"        = "sles15sp4o"
    "4.3-build_image" = "sles15sp4o"
    "4.3-paygo"       = "suma-server-43-paygo"
    "4.3-VM-nightly"  = "suma43VM-ign"
    "4.3-VM-released" = "suma43VM-ign"
    # Uyuni non-podman deprecated in September 2024:
    "uyuni-master"    = "opensuse155o"
    "uyuni-released"  = "opensuse155o"
    "uyuni-pr"        = "opensuse155o"
  }
}

locals {
  product_version = var.product_version != null ? var.product_version : var.base_configuration["product_version"]
}

module "server" {
  source = "../host"

  base_configuration            = var.base_configuration
  name                          = var.name
  quantity                      = var.quantity
  use_os_released_updates       = var.use_os_released_updates
  install_salt_bundle           = var.install_salt_bundle
  additional_repos              = var.additional_repos
  additional_repos_only         = var.additional_repos_only
  additional_certs              = var.additional_certs
  additional_packages           = var.additional_packages
  swap_file_size                = var.swap_file_size
  ssh_key_path                  = var.ssh_key_path
  gpg_keys                      = var.gpg_keys
  ipv6                          = var.ipv6
  connect_to_base_network       = true
  connect_to_additional_network = false
  roles                         = var.register_to_server == null ? ["server"] : ["server", "minion"]
  disable_firewall              = var.disable_firewall
  image                         = var.image == "default" ? var.images[local.product_version] : var.image
  provider_settings             = var.provider_settings
  main_disk_size                = var.main_disk_size
  additional_disk_size          = var.repository_disk_size
  second_additional_disk_size   = var.database_disk_size
  volume_provider_settings      = var.volume_provider_settings
  product_version               = var.product_version
  provision                     = var.provision

  grains = {
    cc_username            = var.base_configuration["cc_username"]
    cc_password            = var.base_configuration["cc_password"]
    channels               = var.channels
    wait_for_reposync      = var.wait_for_reposync
    cloned_channels        = var.cloned_channels
    mirror                 = var.base_configuration["mirror"]
    server_mounted_mirror  = var.server_mounted_mirror
    iss_master             = var.iss_master
    iss_slave              = var.iss_slave
    server                 = var.register_to_server != null ? lookup(var.register_to_server, "hostname", null) : null
    auto_connect_to_master = var.auto_register
    susemanager = {
      activation_key = var.activation_key
    }
    download_private_ssl_key        = var.download_private_ssl_key
    smt                             = var.smt
    server_username                 = var.server_username
    server_password                 = var.server_password
    allow_postgres_connections      = var.allow_postgres_connections
    unsafe_postgres                 = var.unsafe_postgres
    postgres_log_min_duration       = var.postgres_log_min_duration
    java_debugging                  = var.java_debugging
    java_hibernate_debugging        = var.java_hibernate_debugging
    java_salt_debugging             = var.java_salt_debugging
    skip_changelog_import           = var.skip_changelog_import
    create_first_user               = var.create_first_user
    scc_access_logging              = var.scc_access_logging
    mgr_sync_autologin              = var.mgr_sync_autologin
    create_sample_channel           = var.create_sample_channel
    create_sample_activation_key    = var.create_sample_activation_key
    create_sample_bootstrap_script  = var.create_sample_bootstrap_script
    publish_private_ssl_key         = var.publish_private_ssl_key
    disable_download_tokens         = var.disable_download_tokens
    disable_auto_bootstrap          = var.disable_auto_bootstrap
    auto_accept                     = var.auto_accept
    monitored                       = var.monitored
    from_email                      = var.from_email
    traceback_email                 = var.traceback_email
    saltapi_tcpdump                 = var.saltapi_tcpdump
    main_disk_size                  = var.main_disk_size
    repository_disk_size            = var.repository_disk_size
    database_disk_size              = var.database_disk_size
    repository_disk_use_cloud_setup = var.repository_disk_use_cloud_setup
    forward_registration            = var.forward_registration
    server_registration_code        = var.server_registration_code
    accept_all_ssl_protocols        = var.accept_all_ssl_protocols
    login_timeout                   = var.login_timeout
    db_configuration                = var.db_configuration
    c3p0_connection_timeout         = var.c3p0_connection_timeout
    c3p0_connection_debug           = var.c3p0_connection_debug
    large_deployment                = var.large_deployment
    beta_enabled                    = var.beta_enabled
    additional_repos                = var.additional_repos
  }
}

output "configuration" {
  value = {
    id              = length(module.server.configuration["ids"]) > 0 ? module.server.configuration["ids"][0] : null
    hostname        = length(module.server.configuration["hostnames"]) > 0 ? module.server.configuration["hostnames"][0] : null
    username        = var.server_username
    password        = var.server_password
  }
}
