
import Foundation
import UIKit

protocol AlertPresenterProtocol: AnyObject {
    var delegate: AlertPresenterDelegate? {get set}
    func show(alertModel: AlertModel)
}
