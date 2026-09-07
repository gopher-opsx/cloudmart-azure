# Target Architecture

Only Storefront is public. Web BFF, Catalog, Cart, and Order use internal ingress. Inventory, Payment, and Notification are event workers with no application ingress. Data/messaging services are Azure managed services.
