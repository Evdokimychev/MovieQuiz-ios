//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Для учёбы   on 07/05/2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    var buttonAction: (()->Void)?
}