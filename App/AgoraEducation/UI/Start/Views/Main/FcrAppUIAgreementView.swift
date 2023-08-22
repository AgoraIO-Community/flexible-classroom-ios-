//
//  FcrAppUIAgreementView.swift
//  FlexibleClassroom
//
//  Created by DoubleCircle on 2022/6/11.
//  Copyright © 2022 Agora. All rights reserved.
//

import AgoraUIBaseViews
import UIKit

class FcrAppUIAgreementView: UIView,
                             AgoraUIContentContainer {
    private(set) lazy var checkButton = UIButton(type: .custom)
    private(set) lazy var agreeButton = UIButton(type: .custom)
    private(set) lazy var disagreeButton = UIButton(type: .custom)
    private lazy var checkLabel = UILabel(frame: .zero)
    
    var isAgreed: Bool = false {
        didSet {
            agree(isAgreed)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        initViewFrame()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func agree(_ isAgreed: Bool) {
        let image = isAgreed ? UIImage(named: "checkBox_checked") : UIImage(named: "checkBox_unchecked")
        checkButton.setImage(image,
                             for: .normal)
        
        agreeButton.isEnabled = isAgreed
        agreeButton.backgroundColor = isAgreed ? UIColor(hex: 0x357BF6) : UIColor(hex: 0xC0D6FF)
    }
    
    func initViews() {
        addSubview(checkButton)
        addSubview(checkLabel)
        addSubview(agreeButton)
        addSubview(disagreeButton)
        
        agreeButton.isUserInteractionEnabled = true
        disagreeButton.isUserInteractionEnabled = true
    }
    
    func initViewFrame() {
        var checkLabelWidth: CGFloat = 0
        
        if let width = checkLabel.text?.agora_size(font: checkLabel.font).width {
            checkLabelWidth = width
        }
        
        let isPad = (UIDevice.current.agora_is_pad)
        let offset: CGFloat = 5
        let checkButtonWidth: CGFloat = isPad ? 14 : 12
        
        checkButton.mas_makeConstraints { make in
            make?.top.equalTo()(31)
            make?.height.width().equalTo()(checkButtonWidth)
            make?.centerX.equalTo()(-(checkButtonWidth + offset + checkLabelWidth) / 2)
        }
        
        checkLabel.mas_makeConstraints { make in
            make?.left.equalTo()(checkButton.mas_right)?.offset()(offset)
            make?.centerY.equalTo()(checkButton)
        }

        disagreeButton.mas_makeConstraints { make in
            make?.left.equalTo()(20)
            make?.right.equalTo()(-20)
            make?.height.equalTo()(34)
            make?.bottom.equalTo()(-34)
        }
        
        agreeButton.mas_makeConstraints { make in
            make?.left.equalTo()(20)
            make?.right.equalTo()(-20)
            make?.height.equalTo()(34)
            make?.bottom.equalTo()(disagreeButton.mas_top)?.offset()(-4)
        }
    }
    
    func updateViewProperties() {
        backgroundColor = UIColor(hex: 0xFFFFFFF,
                                  transparency: 0.5)
        
        checkLabel.text = "Service_check_content".localized()
        checkLabel.textColor = UIColor(hex: 0x7D8798)
        checkLabel.font = .systemFont(ofSize: 10)
        
        agreeButton.setTitle("Service_agree".localized(),
                             for: .normal)
        agreeButton.setTitleColor(.white,
                                  for: .normal)
        agreeButton.backgroundColor = UIColor(hex: 0xC0D6FF)
        
        agreeButton.titleLabel?.font = .systemFont(ofSize: 14)
        agreeButton.layer.cornerRadius = 17
        
        disagreeButton.setTitle("Service_disagree".localized(),
                                for: .normal)
        
        disagreeButton.setTitleColor(UIColor(hex: 0x8A8A9A),
                                     for: .normal)
        
        disagreeButton.backgroundColor = .clear
        
        disagreeButton.titleLabel?.font = .systemFont(ofSize: 12)
        
        agree(isAgreed)
    }
}
