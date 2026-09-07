locals {
  environment = "training"
  location    = var.location

  app_names = {
    storefront   = "ca-storefront-training"
    web_bff      = "ca-web-bff-training"
    catalog      = "ca-catalog-training"
    cart         = "ca-cart-training"
    order        = "ca-order-training"
    inventory    = "ca-inventory-training"
    payment      = "ca-payment-training"
    notification = "ca-notification-training"
  }
}
