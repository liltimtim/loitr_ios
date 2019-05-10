//
//  BouncyWindowView.swift
//  Loitr
//
//  Created by Timothy Dillman on 5/4/19.
//  Copyright © 2019 Timothy Dillman. All rights reserved.
//
//  Provides a view with a button that expands and contracts the view in an animated way.

import UIKit

class BouncyView: UIView {
    
    private var heightConstraint: NSLayoutConstraint!
    
    private var isOpen: Bool = false {
        didSet {
            animate(opened: isOpen)
        }
    }
    
    private var openButton: UIButton!
    
    private var closeButton: UIButton!
    
    private lazy var openViewController: MapOverviewViewController = {
        return MapOverviewViewController()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc private func open() {
        isOpen = !isOpen
    }
    
    @objc private func close() {
        isOpen = !isOpen
    }
    
    private func setupUI() {
        // initial state is closed
        heightConstraint = heightAnchor.constraint(equalToConstant: 65)
        heightConstraint.isActive = true
        
        openButton = UIButton()
        addSubview(openButton)
        openButton.translatesAutoresizingMaskIntoConstraints = false
        openButton.setTitle("Options", for: .normal)
        openButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        openButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        openButton.setTitleColor(UIColor.gray, for: .normal)
        openButton.addTarget(self, action: #selector(open), for: .touchUpInside)
        
        closeButton = UIButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(closeButton)
        closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        closeButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(UIColor.gray, for: .normal)
        closeButton.isHidden = true
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        backgroundColor = .white
        
        layer.cornerRadius = 20
        clipsToBounds = true
    }
    
    /**
     Do not call directly, allow the did set method to call this
    */
    private func animate(opened: Bool) {
        if opened {
            openButton.isHidden = !openButton.isHidden
            closeButton.isHidden = !closeButton.isHidden
            layoutIfNeeded()
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                self.heightConstraint.constant = (self.superview?.bounds.height ?? 300) / 2
                self.layoutIfNeeded()
            }, completion: nil)
        } else {
            openButton.isHidden = !openButton.isHidden
            closeButton.isHidden = !closeButton.isHidden
            layoutIfNeeded()
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                self.heightConstraint.constant = 65
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }
}
