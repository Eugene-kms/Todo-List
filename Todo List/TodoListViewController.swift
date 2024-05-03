import UIKit

struct TodoList {
    let title: String
    let image: UIImage
    let color: UIColor
    let items: [String]
}

//class for all screen(groceries, vacation, home chores)
class TodoListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
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
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        let cellName = "TodoListItemCell"
        tableView.register(UINib(nibName: cellName, bundle: nil), forCellReuseIdentifier: cellName)
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

extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        todoList.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListItemCell") as? TodoListItemCell else { return UITableViewCell() }
        
        let item = todoList.items[indexPath.row]
        
        cell.configure(with: item)
        
        return cell
    }
}
