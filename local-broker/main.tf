terraform {
  required_providers {
    solacebroker = {
      source  = "SolaceProducts/solacebroker"
      version = "1.2.0"
    }
  }
}

provider "solacebroker" {
  url                   = "http://localhost:8080"
  username              = "admin"
  password              = "admin"
  insecure_skip_verify  = true
}

# Create a Message VPN
resource "solacebroker_msg_vpn" "vpn_demo" {
  msg_vpn_name                 = "vpn_horse_demo"
  enabled                       = true
  authentication_basic_enabled  = true
}

# Create client users
resource "solacebroker_msg_vpn_client_username" "user_app1" {
  msg_vpn_name   = solacebroker_msg_vpn.vpn_demo.msg_vpn_name
  client_username = "horse_app_user"
  password        = "pass123"
}

# Create queues
resource "solacebroker_msg_vpn_queue" "queue_orders" {
  msg_vpn_name    = solacebroker_msg_vpn.vpn_demo.msg_vpn_name
  queue_name      = "Q.ORDERS"
  access_type     = "exclusive"
  ingress_enabled = true
  egress_enabled  = true
}

resource "solacebroker_msg_vpn_queue" "queue_listings" {
  msg_vpn_name    = solacebroker_msg_vpn.vpn_demo.msg_vpn_name
  queue_name      = "Q.LISTINGS"
  access_type     = "exclusive"
  ingress_enabled = true
  egress_enabled  = true
}

resource "solacebroker_msg_vpn_queue" "queue_testdrives" {
  msg_vpn_name    = solacebroker_msg_vpn.vpn_demo.msg_vpn_name
  queue_name      = "Q.TESTDRIVES"
  access_type     = "exclusive"
  ingress_enabled = true
  egress_enabled  = true
}

# Create queue subscriptions
resource "solacebroker_msg_vpn_queue_subscription" "sub_orders" {
  msg_vpn_name       = solacebroker_msg_vpn.vpn_demo.msg_vpn_name
  queue_name         = solacebroker_msg_vpn_queue.queue_orders.queue_name
  subscription_topic = "orders/#"
}

resource "solacebroker_msg_vpn_queue_subscription" "sub_listings" {
  msg_vpn_name       = solacebroker_msg_vpn.vpn_demo.msg_vpn_name
  queue_name         = solacebroker_msg_vpn_queue.queue_listings.queue_name
  subscription_topic = "listings/#"
}

resource "solacebroker_msg_vpn_queue_subscription" "sub_testdrives" {
  msg_vpn_name       = solacebroker_msg_vpn.vpn_demo.msg_vpn_name
  queue_name         = solacebroker_msg_vpn_queue.queue_testdrives.queue_name
  subscription_topic = "testdrives/#"
}

