import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
    
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    
    private var alertPresenter: AlertPresenterProtocol?
        private var presenter: MovieQuizPresenter!

        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }

        // MARK: - Lifecycle
        override func viewDidLoad() {
            
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.cornerRadius = 20
            imageView.layer.borderColor = UIColor.ypBlack.cgColor
            imageView.backgroundColor = UIColor.ypWhite

            alertPresenter = AlertPresenter(delegate: self)

            showLoadingIndicator()
            presenter = MovieQuizPresenter(viewController: self)

            super.viewDidLoad()
        }

        func didReceiveNextQuestion(question: QuizQuestion?) {
            presenter.didReceiveNextQuestion(question: question)
        }

        func show(alert: UIAlertController) {
            hideLoadingIndicator()
            self.present(alert, animated: true)
        }

        func showLoadingIndicator() {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }

        func showNetworkError(message: String) {
            hideLoadingIndicator()
            let alertModel = AlertModel(title: "Ошибка",
                                        message: message,
                                        buttonText: "Попробовать снова",
                                        buttonAction: { [weak self] in
                                            guard let self = self else { return }
                                            presenter.resetQuestionIndex()
                                            presenter.resetCorrectAnswers()
                                            self.presenter.restartGame()
                                        }
            )

            alertPresenter?.show(alertModel: alertModel)
        }

        func show(quiz step: QuizStepViewModel) {
            hideLoadingIndicator()
            imageView.image = step.image
            imageView.layer.borderColor = UIColor.ypBlack.cgColor
            questionLabel.text = step.question
            counterLabel.text = step.questionNumber
        }

        func show(quiz result: QuizResultsViewModel) {
            let alertModel = AlertModel(
                        title: result.title,
                        message: result.text,
                        buttonText: result.buttonText,
                        buttonAction: { [weak self] in
                            guard let self = self else { return }
                            presenter.resetQuestionIndex()
                            presenter.resetCorrectAnswers()
                            self.presenter.restartGame()
                        }
                    )
            hideLoadingIndicator()
            alertPresenter?.show(alertModel: alertModel)
        }

        func hideLoadingIndicator() {
            activityIndicator.isHidden = true
        }

        func highlightImageBorder(isCorrectAnswer: Bool) {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        }

        @IBAction private func yesButtonClicked(_ sender: Any) {
            presenter.yesButtonClicked()
        }

        @IBAction private func noButtonClicked(_ sender: Any) {

            presenter.noButtonClicked()
        }
    }
