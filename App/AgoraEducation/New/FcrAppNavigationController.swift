//
//  FcrAppNavigationController.swift
//
//
//  Created by CavanSu on 2018/6/29.
//  Copyright © 2018 CavanSu. All rights reserved.
//

import UIKit

protocol FcrAppNavigationControllerDelegate: NSObjectProtocol {
    func navigation(_ navigation: FcrAppNavigationController,
                    didBackButtonPressed from: UIViewController,
                    to: UIViewController?)
}

extension FcrAppNavigationControllerDelegate {
    func navigation(_ navigation: FcrAppNavigationController,
                    didBackButtonPressed from: UIViewController,
                    to: UIViewController?) {}
}

extension UINavigationBar {
    static var height: CGFloat {
        return 44
    }
}

class FcrAppNavigationController: UINavigationController {
    var backButton: UIButton? {
        didSet {
            if let old = oldValue {
                old.removeFromSuperview()
            }
            
            guard let button = backButton else {
                navigationItem.setHidesBackButton(false,
                                                  animated: false)
                return
            }
            
            setupBackButton(button)
        }
    }
    
    var rightButton: UIButton? {
        didSet {
            if let old = oldValue {
                old.removeFromSuperview()
            }
            
            guard let button = rightButton else {
                return
            }
            
            setupRightButton(button)
        }
    }
    
    var statusBarStyle: UIStatusBarStyle = .default
    
    weak var csDelegate: FcrAppNavigationControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .fullScreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func pushViewController(_ viewController: UIViewController,
                                     animated: Bool) {
        if let backButton = backButton {
            viewController.navigationItem.setHidesBackButton(true,
                                                             animated: false)
            backButton.isHidden = false
        }
        
        if let titleCenter = navigationItem.titleView?.center {
            updateBackButtonCenterY(y: titleCenter.y)
        }
        
        super.pushViewController(viewController,
                                 animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let from = children.last
        let toIndex = children.count - 2
        var to: UIViewController?
        
        if toIndex >= 0 {
            to = children[toIndex]
        } else {
            to = nil
        }
        
        if let fromVC = from {
            csDelegate?.navigation(self,
                                   didBackButtonPressed: fromVC,
                                   to: to)
        }
        
        super.popViewController(animated: animated)
        return to
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
}

extension FcrAppNavigationController {
    func setupBarClearColor() {
        navigationBar.setBackgroundImage(UIImage(),
                                         for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
    }
    
    func setupBarOthersColor(color: UIColor) {
        navigationBar.isTranslucent = false
        navigationBar.barTintColor = color
        navigationBar.backgroundColor = color
    }
    
    func setupTitleFontSize(fontSize: UIFont) {
        if var attributes = self.navigationBar.titleTextAttributes {
            attributes[NSAttributedString.Key.font] = fontSize
            navigationBar.titleTextAttributes = attributes
        } else {
            navigationBar.titleTextAttributes = [NSAttributedString.Key.font: fontSize]
        }
    }
    
    func setupTitleFontColor(color: UIColor) {
        if var attributes = self.navigationBar.titleTextAttributes {
            attributes[NSAttributedString.Key.foregroundColor] = color
            navigationBar.titleTextAttributes = attributes
        } else {
            navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: color]
        }
    }
    
    func setupTintColor(color: UIColor) {
        navigationBar.tintColor = color
    }
}

private extension FcrAppNavigationController {
    func setupBackButton(_ button: UIButton) {
        if let top = self.topViewController {
            top.navigationItem.setHidesBackButton(true,
                                                  animated: false)
        }
        
        let barHeight = self.navigationBar.bounds.height
        
        let w = button.bounds.width
        let h = button.bounds.height > barHeight ? barHeight : button.bounds.height
        
        let x = button.frame.origin.x
        let y = (barHeight - h) * 0.5
        button.frame = CGRect(x: x,
                              y: y,
                              width: w,
                              height: h)
        button.addTarget(self,
                         action: #selector(popBack),
                         for: .touchUpInside)
        navigationBar.addSubview(button)
    }
    
    func setupRightButton(_ button: UIButton) {
        let barHeight = navigationBar.bounds.height
        let barWidth = navigationBar.bounds.width
        
        let w = button.bounds.width
        let h = button.bounds.height > barHeight ? barHeight : button.bounds.height
        
        let x = barWidth - w - CGFloat(15)
        let y = (barHeight - h) * 0.5
        button.frame = CGRect(x: x,
                              y: y,
                              width: w,
                              height: h)
        
        navigationBar.addSubview(button)
    }
    
    func updateBackButtonCenterY(y: CGFloat) {
        guard let backButton = backButton else {
            return
        }
        var backButtonCenter = backButton.center
        backButtonCenter.y = y
        backButton.center = backButtonCenter
    }
    
    @objc func popBack() {
        if let vc = viewControllers.last {
            vc.navigationController?.popViewController(animated: true)
        }
    }
}
