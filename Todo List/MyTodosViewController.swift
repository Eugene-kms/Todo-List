import UIKit

class MyTodosViewController: UIViewController {
    
    var lists: [TodoList] = []
    
    @IBOutlet weak var tableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lists = myTodoLists()
        configureTableView()
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        let cellName = "TodoListCell"
        tableView.register(UINib(nibName: cellName, bundle: nil), forCellReuseIdentifier: cellName)
        tableView.rowHeight = 44
    }
    
    func present(with todoList: TodoList) {
        let todoListViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TodoListViewController") as! TodoListViewController
        
        todoListViewController.todoList = todoList
        
        present(todoListViewController, animated: true)
    }
    
    private func myTodoLists() -> [TodoList] {
        var lists = [TodoList]()
        
        lists.append(TodoList(
            title: "Croseries",
            image: .avocado,
            color: .greenTodo,
            items: groceriesItems()))
        
        lists.append(TodoList(
            title: "Vacation",
            image: .vacation,
            color: .redTodo,
            items: vacationItems()))
        
        lists.append(TodoList(
            title: "House Chores",
            image: .chores,
            color: .blueTodo,
            items: choresItems()))
        
        return lists
        
    }
    
    private func groceriesItems() -> [String] {
        var items = [String]()
        
        items.append("Whole wheat bread")
        items.append("Almond milk")
        items.append("Cage-free eggs")
        items.append("Fresh spinach")
        items.append("Greek yogurt")
        items.append("Quinoa")
        items.append("Avocados")
        items.append("Cherry tomatoes")
        items.append("Organic chicken breast")
        items.append("Ground turmeric")
        items.append("Almonds")
        items.append("Dark chocolate")
        
        return items
    }
    
    private func vacationItems() -> [String] {
        var list = [String]()
        
        list.append("Check weather")
        list.append("Accommodation")
        list.append("Daily Plan")
        list.append("Passport and visa requirements")
        list.append("Arrange pet care")
        list.append("Exchange currency")
        list.append("Confirm airport transfers")
        list.append("Flight tickets")
        list.append("Restaurant reservations")
        
        return list
    }
    
    private func choresItems() -> [String] {
        var list = [String]()
        
        list.append("Vacuum the living room")
        list.append("Mop kitchen floors")
        list.append("Clean windows in the dining area")
        list.append("Dust all surfaces")
        list.append("Organize the garage")
        
        return list
    }
}

extension MyTodosViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListCell") as? TodoListCell else { return UITableViewCell() }
        
        let todoList = lists[indexPath.row]
        
        cell.configure(with: todoList)
        cell.selectionStyle = .none
        
        return cell
    }
}

extension MyTodosViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todoList = lists[indexPath.row]
        present(with: todoList)
    }
}
