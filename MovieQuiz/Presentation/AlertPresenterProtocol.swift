//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by Для учёбы   on 07/05/2024.
//

import Foundation
import UIKit


protocol AlertPresenterProtocol: AnyObject {
    var delegate: AlertPresenterDelegate? {get set}
    func show(alertModel: AlertModel)
}
