//
//  DPPageViewController.swift
//  
//
//  Created by Дмитрий Поляков on 08.10.2021.
//

import Foundation
import UIKit

public protocol DPPageViewControllerOutput: AnyObject {
    func didSelectPage(_ controller: DPPageViewController, at index: Int)
    func didSetPages(_ controller: DPPageViewController, pages: [UIViewController])
    func didPageLimitReached(_ controller: DPPageViewController, for direction: UIPageViewController.NavigationDirection, fromSwipe: Bool)
}

public extension DPPageViewControllerOutput {
    func didSelectPage(_ controller: DPPageViewController, at index: Int) {}
    func didSetPages(_ controller: DPPageViewController, pages: [UIViewController]) {}
    func didPageLimitReached(_ controller: DPPageViewController, for direction: UIPageViewController.NavigationDirection, fromSwipe: Bool) {}
}

open class DPPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    // MARK: - Props
    open weak var output: DPPageViewControllerOutput?
    
    open var pages: [UIViewController] = [] {
        didSet {
            self.output?.didSetPages(self, pages: self.pages)
            self.showPage(at: self._currentPageIndex)
        }
    }
    
    public var swipeIsEnabled: Bool = true {
        didSet {
            self._swipeIsEnabledDidSet()
        }
    }

    public var currentPageIndex: Int {
        self._currentPageIndex
    }

    private var _currentPageIndex: Int = 0
    
    // MARK: - Init
    public override init(
        transitionStyle style: UIPageViewController.TransitionStyle,
        navigationOrientation: UIPageViewController.NavigationOrientation,
        options: [UIPageViewController.OptionsKey: Any]? = nil
    ) {
        super.init(transitionStyle: style, navigationOrientation: navigationOrientation, options: options)
        
        self.setupComponets()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setupComponets()
    }
    
    // MARK: - Methods
    open func setupComponets() {
        self.delegate = self
    }

    open func appendToSuperview(_ superview: UIView?, parentViewController parent: UIViewController?) {
        guard let superview = superview else { return }
        
        self.view.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(self.view)
        
        NSLayoutConstraint.activate([
            self.view.topAnchor.constraint(equalTo: superview.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            self.view.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        ])
        
        parent?.addChild(self)

        self._swipeIsEnabledDidSet()
        self.showPage(at: self._currentPageIndex)
    }

    open func showPage(at index: Int) {
        guard self.pages.indices.contains(index) else { return }

        let controller = self.pages[index]
        let direction: UIPageViewController.NavigationDirection = index >= self._currentPageIndex ? .forward : .reverse
        self._currentPageIndex = index

        self.setViewControllers([controller], direction: direction, animated: true, completion: { [weak self] completed in
            guard let self = self, completed else { return }
            
            self.output?.didSelectPage(self, at: self._currentPageIndex)
        })
    }

    open func showPageReverse() {
        let index = self._currentPageIndex - 1
        
        guard self.pages.indices.contains(index) else {
            self.output?.didPageLimitReached(self, for: .reverse, fromSwipe: false)
            return
        }
        
        self.showPage(at: index)
    }

    open func showPageForward() {
        let index = self._currentPageIndex + 1
        
        guard self.pages.indices.contains(index) else {
            self.output?.didPageLimitReached(self, for: .forward, fromSwipe: false)
            return
        }
        
        self.showPage(at: index)
    }

    open func removePages(atRange range: Range<Int>) {
        self.pages.removeSubrange(range)
        guard !self.pages.isEmpty else { return }
        
        let index = self.pages.indices.contains(self._currentPageIndex) ? self._currentPageIndex : self.pages.count
        self.showPage(at: index)
    }
    
    // MARK: - Private
    private func _swipeIsEnabledDidSet() {
        self.dataSource = self.swipeIsEnabled ? self : nil
    }
    
    // MARK: - UIPageViewControllerDelegate
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard let index = self.pages.firstIndex(where: { $0 == pageViewController.viewControllers?.first }) else { return }
        self._currentPageIndex = index
        
        self.output?.didSelectPage(self, at: index)
    }
    
    // MARK: - UIPageViewControllerDataSource
    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = self.pages.firstIndex(where: { $0 == viewController }), self.pages.indices.contains(index - 1) else {
            self.output?.didPageLimitReached(self, for: .reverse, fromSwipe: true)
            return nil
        }
        
        return self.pages[index - 1]
    }

    public func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = self.pages.firstIndex(where: { $0 == viewController }), self.pages.indices.contains(index + 1) else {
            self.output?.didPageLimitReached(self, for: .forward, fromSwipe: true)
            return nil
        }
        
        return self.pages[index + 1]
    }
    
}