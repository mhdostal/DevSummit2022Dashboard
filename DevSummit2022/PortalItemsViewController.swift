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

protocol PortalItemsVCDelegate: AnyObject {
    func portalItemsViewController(_ portalItemsViewController: PortalItemsViewController, didSelectItem item: AGSPortalItem)
}

/// A simple table view controller to display portal items.
class PortalItemsViewController: UITableViewController {
    var portalItems: [AGSPortalItem] = []
    
    weak var delegate: PortalItemsVCDelegate?
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "basicCell")
        cell.textLabel?.text = portalItems[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.portalItemsViewController(self, didSelectItem: portalItems[indexPath.row])
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return portalItems.count
    }
}
