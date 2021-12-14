//
//  DPTabBarController.swift
//  DPUIKit
//
//  Created by Дмитрий Поляков on 03.09.2021.
//

import Foundation
import UIKit

open class DPTabBarController: UITabBarController, DPViewProtocol {
    
    // MARK: - Props
    open var items: [DPTabBarItem] = []
    
    // MARK: - Methods
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupComponents()
    }
    
    open var selectedItem: DPTabBarItem? {
        get {
            guard self.items.indices.contains(self.selectedIndex) else { return nil }
            return self.items[self.selectedIndex]
        }
        set {
            guard let index = self.items.firstIndex(where: { $0.tag == newValue?.tag }) else { return }
            self.selectedIndex = index
        }
    }
    
    // MARK: - DPViewProtocol
    open func setupComponents() {}
    
    open func updateComponents() {}
    
    open func setHidden(_ hidden: Bool, animated: Bool) {}
    
    @objc
    open func tapButtonAction(_ button: UIButton) {}
    
    @objc
    open func tapGestureAction(_ gesture: UITapGestureRecognizer) {}
    
}