// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit

import ArcGIS
import WebKit

class ViewController: UIViewController {
    @IBOutlet var webView: WKWebView!
    
    /// The portal containing the desired dashboards.
    let portal = AGSPortal.arcGISOnline(withLoginRequired: true)
    
    /// The credential will be created from the portal credential, if any.
    var credential: URLCredential? {
        guard let userName = portal.credential?.username,
              let password = portal.credential?.password else { return nil }
        return URLCredential(user: userName, password: password, persistence: .forSession)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the portal and fetch/find dashboard items.
        portal.load { [weak self] _ in
            guard let self = self else { return }
            
            // 
            let portalItemsViewController = PortalItemsViewController()
            portalItemsViewController.title = "Select a Dashboard to view..."
            portalItemsViewController.delegate = self
            
            //
            // This will fetch all of the user's Content items, then filter
            // for items of type `.dashboard`.
            //
//            self.portal.user?.fetchContent(completion: { items, _, error in
//                if let error = error {
//                    print("Portal fetch content error: \(error.localizedDescription)")
//                    return
//                }
//
//                // Filter for dashboard items.
//                let dashboards = items?.filter { $0.type == .dashboard }
//
//                // Set up the view controller and display.
//                portalItemsViewController.portalItems = dashboards ?? []
//                let navController = UINavigationController(rootViewController: portalItemsViewController)
//                self.present(navController, animated: true, completion: nil)
//            })
            
            //
            // This will find all items of type `.dashboard` in the portal.
            //
            let portalQueryParameters = AGSPortalQueryParameters(forItemsOf: .dashboard, withSearch: nil)
            self.portal.findItems(with: portalQueryParameters) { queryResultSet, error in
                if let error = error {
                    print("Portal Find Items Error: \(error.localizedDescription)")
                    return
                }

                // Set up the view controller and display.
                portalItemsViewController.portalItems = queryResultSet?.results as? [AGSPortalItem] ?? []
                let navController = UINavigationController(rootViewController: portalItemsViewController)
                self.present(navController, animated: true, completion: nil)
            }
        }
    }
}


extension ViewController: PortalItemsVCDelegate {
    func portalItemsViewController(_ portalItemsViewController: PortalItemsViewController, didSelectItem item: AGSPortalItem) {
        loadWebView(url: dashboardURL(portal: portal, forItem: item))
        print("User selected \(item.title) dashboard.")
    }
    
    func loadWebView(url: URL?) {
        if let url = url, let webView = self.webView {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func dashboardURL(portal: AGSPortal, forItem item: AGSPortalItem) -> URL? {
        // Assemble the dashboard URL.
        var url = URL.init(string: "https://" + (portal.url?.host ?? ""))
        url?.appendPathComponent("apps")
        url?.appendPathComponent("dashboards")
        url?.appendPathComponent(item.itemID)
        return url
    }
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, respondTo challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard (webView.url?.host) != nil else {
            return (.cancelAuthenticationChallenge, nil)
        }
        let authenticationMethod = challenge.protectionSpace.authenticationMethod
        if authenticationMethod == NSURLAuthenticationMethodDefault || authenticationMethod == NSURLAuthenticationMethodHTTPBasic || authenticationMethod == NSURLAuthenticationMethodHTTPDigest {
            // Use the credential created from the Portal credential.
            return (.useCredential, credential)
        } else if authenticationMethod == NSURLAuthenticationMethodServerTrust {
            return (.performDefaultHandling, nil)
        } else {
            return (.cancelAuthenticationChallenge, nil)
        }
    }
}

