terraform {
  required_providers {
    solacebroker = {
      source  = "SolaceProducts/solacebroker"
      version = "1.2.0"
    }
  }
}

provider "solacebroker" {
  url                   = "https://mr-connection-5yfaxcu981x.messaging.solace.cloud:943"
  username              = "mission-control-manager"
  password              = "enojbnkpr12t7gh28mst1queqh"
  insecure_skip_verify  = true
}

# Since VPN already exists (solace-demo), we reference it
locals {
  msg_vpn_name = "solace-demo"
}

# 1️⃣ Client user
resource "solacebroker_msg_vpn_client_username" "user_app1" {
  msg_vpn_name   = local.msg_vpn_name
  client_username = "horse_app_user_cloud"
  password        = "pass123"
}

# 2️⃣ Queues
resource "solacebroker_msg_vpn_queue" "queue_orders" {
  msg_vpn_name    = local.msg_vpn_name
  queue_name      = "Q.ORDERS"
  access_type     = "exclusive"
  ingress_enabled = true
  egress_enabled  = true
}

resource "solacebroker_msg_vpn_queue" "queue_listings" {
  msg_vpn_name    = local.msg_vpn_name
  queue_name      = "Q.LISTINGS"
  access_type     = "exclusive"
  ingress_enabled = true
  egress_enabled  = true
}

resource "solacebroker_msg_vpn_queue" "queue_testdrives" {
  msg_vpn_name    = local.msg_vpn_name
  queue_name      = "Q.TESTDRIVES"
  access_type     = "exclusive"
  ingress_enabled = true
  egress_enabled  = true
}

# 3️⃣ Subscriptions
resource "solacebroker_msg_vpn_queue_subscription" "sub_orders" {
  msg_vpn_name       = local.msg_vpn_name
  queue_name         = solacebroker_msg_vpn_queue.queue_orders.queue_name
  subscription_topic = "orders/#"
}

resource "solacebroker_msg_vpn_queue_subscription" "sub_listings" {
  msg_vpn_name       = local.msg_vpn_name
  queue_name         = solacebroker_msg_vpn_queue.queue_listings.queue_name
  subscription_topic = "listings/#"
}

resource "solacebroker_msg_vpn_queue_subscription" "sub_testdrives" {
  msg_vpn_name       = local.msg_vpn_name
  queue_name         = solacebroker_msg_vpn_queue.queue_testdrives.queue_name
  subscription_topic = "testdrives/#"
}

