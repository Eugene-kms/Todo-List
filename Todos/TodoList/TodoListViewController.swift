import UIKit

//class for all screen(groceries, vacation, home chores)
class TodoListViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var imageBackgroundView: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLbl: UILabel!
    
//  "Add New Item" area
    @IBOutlet private weak var addNewItemView: UIView!
    @IBOutlet private weak var addNewItemSafeAreaView: UIView!
    @IBOutlet private weak var plusBtn: UIButton!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet weak var textFieldLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var addBtn: UIButton!
    @IBOutlet weak var addNewItemSaveAreaViewBottomConstraint: NSLayoutConstraint!
    
    var viewModel: TodoListViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageBackgroundView.setCornerRadius(20)
        
        configure()
        configureTableView()
        configureKeyboard()
        configureAddItemView()
        configureTextField()
        
        setAddNewItemButton(enabled: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presentingViewController?.viewWillAppear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func configureTextField() {
        textField.addTarget(self, action: #selector(didChangeText), for: .editingChanged)
    }
    
    @objc private func didChangeText() {
        setAddNewItemButton(enabled: viewModel.isNewItemValid(textField.text ?? ""))
    }
    
    private func setAddNewItemButton(enabled isEnabled: Bool) {
        addBtn.isUserInteractionEnabled = isEnabled
        addBtn.tintColor = isEnabled ? .accent : UIColor(hex: "#737373")?.withAlphaComponent(0.5)
    }
    
    private func configureAddItemView() {
        addNewItemView.layer.masksToBounds = false
        addNewItemView.layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner]
        
        addNewItemView.layer.cornerRadius = 15
        addNewItemView.layer.shadowColor = UIColor.black.withAlphaComponent(0.25).cgColor
        addNewItemView.layer.shadowOffset = .zero
        addNewItemView.layer.shadowRadius = 18.5
        addNewItemView.layer.shadowPath = UIBezierPath(roundedRect: addNewItemView.bounds, cornerRadius: addNewItemView.layer.cornerRadius).cgPath
        addNewItemView.layer.shadowOpacity = 1
        
        addNewItemSafeAreaView.setCornerRadius(15)
    }
    
    private func configureKeyboard() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let animationCurveRawNumber = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNumber?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        let isKeyboardHidden = endFrame.origin.y >= UIScreen.main.bounds.size.height
        
        //if the keyboard is hidden
        if isKeyboardHidden {
            addNewItemSaveAreaViewBottomConstraint.constant = 0
            textFieldLeftConstraint.constant = 48
        } else {//if the keyboard is presented
            addNewItemSaveAreaViewBottomConstraint.constant = -endFrame.height + view.safeAreaInsets.bottom - 8
            textFieldLeftConstraint.constant = 16
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: animationCurve) {
            self.plusBtn.alpha = isKeyboardHidden ? 1 : 0
            self.addBtn.alpha = isKeyboardHidden ? 0 : 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        let cellName = "TodoListItemCell"
        tableView.register(UINib(nibName: cellName, bundle: nil), forCellReuseIdentifier: cellName)
    }
    
    private func configure() {
        headerView.backgroundColor = viewModel.todoList.color
        iconImageView.image = UIImage(named: viewModel.todoList.image)
        titleLbl.text = viewModel.todoList.title
    }
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func plusBtnTapped(_ sender: Any) {
        textField.becomeFirstResponder()
    }
    
    @IBAction func addBtnTapped(_ sender: Any) {
        guard
            let text = textField.text,
            viewModel.isNewItemValid(text) else { return }
        
        viewModel.addItem(text)
        
        let indexPath = IndexPath(row: viewModel.todoList.items.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        textField.text = ""
        setAddNewItemButton(enabled: false)
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        let sheet = UIAlertController(
            title: "More Actions",
            message: "What do you want to do?",
            preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(
            title: "Edit",
            style: .default,
            handler: { _ in
                self.presentEdit()
            }))
        
        sheet.addAction(UIAlertAction(
            title: "Delete List",
            style: .destructive,
            handler: { [weak self] _ in
                self?.presentDeletePromt()
            }))
        
        sheet.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel))
        
        self.present(sheet, animated: true)
    }
    
    private func presentDeletePromt() {
        let alert = UIAlertController(
            title: "Are you sure?",
            message: "Deleting the app will forever remove all the items and the list itself",
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(
            title: "Delete",
            style: .default,
            handler: { [weak self] _ in
                self?.deleteListAndDismiss()
            }))
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    private func presentEdit() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddListViewController") as! AddListViewController
        
        vc.todoList = viewModel.todoList
        
        vc.didSaveList = { [weak self] todoList in
            self?.updateList(todoList)
        }
        
        self.present(vc, animated: true)
    }
    
    private func updateList(_ todoList: TodoList) {
        
        viewModel.update(with: todoList)
        
        configure()
    }
    
    private func deleteListAndDismiss() {
        viewModel.delete()
        self.dismiss(animated: true)
    }
}

extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.todoList.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListItemCell") as? TodoListItemCell else { return UITableViewCell() }
        
        let item = viewModel.todoList.items[indexPath.row]
        
        cell.configure(with: item.content)
        
        return cell
    }
}

extension TodoListViewController: UIScrollViewDelegate, UITableViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

