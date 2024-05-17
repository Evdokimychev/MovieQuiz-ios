//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Для учёбы   on 07/05/2024.
//

import Foundation
import UIKit

final class AlertPresenter: AlertPresenterProtocol {

    weak var delegate: AlertPresenterDelegate?

    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)

        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default,
            handler: { _ in
            alertModel.buttonAction?()
            })

        alert.addAction(action)
        delegate?.show(alert: alert)
    }
    
    init(delegate: AlertPresenterDelegate?) {
        self.delegate = delegate
    }
}
