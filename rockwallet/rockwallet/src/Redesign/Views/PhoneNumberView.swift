// 
//  PhoneNumberView.swift
//  breadwallet
//
//  Created by Kenan Mamedoff on 20/03/2023.
//  Copyright © 2023 RockWallet, LLC. All rights reserved.
//
//  See the LICENSE file at the project root for license information.
//

import UIKit

struct PhoneNumberConfiguration: Configurable {
}

struct PhoneNumberViewModel: ViewModel {
    var areaCode: TextFieldModel?
    var phoneNumber: TextFieldModel?
}

class PhoneNumberView: FEView<PhoneNumberConfiguration, PhoneNumberViewModel> {
    var didPresentPicker: (() -> Void)?
    var didChangePhoneNumber: ((String?) -> Void)?
    
    private lazy var areaCodeTextfield: FETextField = {
        let view = FETextField()
        return view
    }()
    
    private lazy var phoneNumberTextField: FETextField = {
        let view = FETextField()
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        
        content.addSubview(phoneNumberTextField)
        content.addSubview(areaCodeTextfield)
        
        areaCodeTextfield.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.bottom.equalToSuperview().priority(.low)
            make.width.equalToSuperview().multipliedBy(0.3)
        }
        
        phoneNumberTextField.snp.makeConstraints { make in
            make.top.bottom.equalTo(areaCodeTextfield)
            make.trailing.equalToSuperview()
            make.leading.equalTo(areaCodeTextfield.snp.trailing).inset(Margins.minimum.rawValue)
        }
        
        phoneNumberTextField.finishedEditing = { [weak self] field in
            self?.didChangePhoneNumber?(field.text)
        }
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(triggerPresentPicker)))
    }
    
    override func configure(with config: PhoneNumberConfiguration?) {
        super.configure(with: config)
        
        var areaCodePreset = Presets.TextField.primary
        areaCodePreset.backgroundConfiguration?.border?.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        areaCodeTextfield.configure(with: areaCodePreset)
        
        var phoneNumberPreset = Presets.TextField.primary
        phoneNumberPreset.keyboardType = .numberPad
        phoneNumberPreset.backgroundConfiguration?.border?.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        phoneNumberTextField.configure(with: phoneNumberPreset)
    }
    
    override func setup(with viewModel: PhoneNumberViewModel?) {
        super.setup(with: viewModel)
        
        var areaCode = viewModel?.areaCode
        areaCode?.isUserInteractionEnabled = false
        
        areaCodeTextfield.setup(with: areaCode)
        phoneNumberTextField.setup(with: viewModel?.phoneNumber)
    }
    
    @objc private func triggerPresentPicker() {
        didPresentPicker?()
    }
}
