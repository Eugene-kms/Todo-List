import UIKit

class TodoListCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    func configure(with todoList: TodoList) {
        iconImageView.image = UIImage(named: todoList.image)
        titleLbl.text = "\(todoList.title) (\(todoList.items.count))"
    }
    
}
