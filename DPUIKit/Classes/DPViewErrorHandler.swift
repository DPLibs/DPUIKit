import Foundation
import UIKit

open class DPViewErrorHandler {
    
    // MARK: - Props
    open weak var viewController: UIViewController?
    
    // MARK: - Init
    public init() {}
    
    // MARK: - Methods
    open func showError(_ error: Error?, completions: (() -> Void)? = nil) {
        guard let error = error else { return }
        
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        self.viewController?.present(alert, animated: true, completion: completions)
    }
}
