import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        showLoadingIndicator()
        questionFactory?.loadData()
      }
    
    // MARK: - QuestionFactoryDelegate

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }

    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }


    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - AlertPresenterDelegate
    func show(alert: UIAlertController) {
        hideLoadingIndicator()
        self.present(alert, animated: true)
    }
    
    // MARK: - Actions
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    
    struct ViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }

    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private let alertPresenter: AlertPresenterProtocol? = nil
    private var statisticService: StatisticService = StatisticServiceImplementation()
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
//    
    // MARK: - Private functions
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        hideLoadingIndicator()
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }

            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            questionFactory?.requestNextQuestion() 
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func hideLoadingIndicator() {
            activityIndicator.isHidden = true
        }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alertModel = AlertModel(title: "Ошибка",
                                    message: message,
                                    buttonText: "Попробовать снова",
                                    buttonAction: { [weak self] in
                                        guard let self = self else { return }
                                        self.currentQuestionIndex = 0
                                        self.correctAnswers = 0
                                        self.questionFactory?.loadData()
                                    }
        )

        alertPresenter?.show(alertModel: alertModel)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        sender.isEnabled = false
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        sender.isEnabled = false
    }
    
    // приватный метод, который и меняет цвет рамки, и вызывает метод перехода
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // код, который мы хотим вызвать через 1 секунду
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            // идём в состояние "Результат квиза"
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let quizCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let formattedAccuracy = String(format: "%.2f%%", statisticService.totalAccuracy * 100)
            let text = """
                Ваш результат: \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(quizCount)
                Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                Средняя точность: \(formattedAccuracy)
                """

            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            
            show(quiz: viewModel)
        }
        
        else {
            currentQuestionIndex += 1
            
            questionFactory?.requestNextQuestion()
            yesButton.isEnabled = true
            noButton.isEnabled = true
            }
    }
}
