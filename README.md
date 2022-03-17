# DevSummit2022Dashboard

Small sample app to select and view dashboards from an ArcGIS portal.

The code has two ways to find dashboard items: filtering for items of type `dashboard` in the list of "My Content" items and querying the portal for items of type `dashboard`.

The code will assemble the dashboard URL based on the portal and dashboard item selected and attempt to display it in a `WKWebView` using the credentials supplied to the portal.  Any additional credentials or authentication required is not handled, nor are navigation links in the dashboard itself.
