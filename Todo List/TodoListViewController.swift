import UIKit

struct TodoList {
    let title: String
    let image: UIImage
    let color: UIColor
}

//class for all screen(groceries, vacation, home chores)
class TodoListViewController: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var imageBackgroundView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    var todoList: TodoList!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageBackgroundView.layer.cornerRadius = 20
        imageBackgroundView.layer.masksToBounds = true
        
        configure()
    }
    
    func configure() {
        headerView.backgroundColor = todoList.color
        iconImageView.image = todoList.image
        titleLbl.text = todoList.title
    }
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true)
    }
}
