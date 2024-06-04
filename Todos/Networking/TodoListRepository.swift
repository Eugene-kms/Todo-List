import UIKit

class TodoListRepository {
    
    typealias TodoListResponse = [String: TodoListDTO]
    
    private lazy var todosUrl = baseUrl.appending(path: "todos.json")
    
    private let baseUrl = URL(string:  "https://todos-9ce97-default-rtdb.europe-west1.firebasedatabase.app/")!
    
    func fetchTodoLists() async throws -> [TodoList] {
                
        let request = URLRequest(url: todosUrl)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoded = try JSONDecoder().decode(TodoListResponse.self, from: data)
        
        return toDomain(decoded)
    }
    
    func addTodoList(_ todoList: TodoList) async throws -> String {
        var request = URLRequest(url: todosUrl)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(todoList.toData)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decode = try JSONDecoder().decode(DatabasePOSTResponse.self, from: data)
        
        return decode.name
    }
    
    func updateTodoList(_ todoList: TodoList) async throws {
        let payloadDictionary: [String: String] = [
            "color": todoList.color.hexStringOrWhite,
            "title": todoList.title,
            "icon": todoList.image]
        
        var request = URLRequest(url: baseUrl
            .appending(path: "todos")
            .appending(path: todoList.id)
            .appending(path: ".json"))
        
        request.httpMethod = "PATCH"
        request.httpBody = try JSONSerialization.data(withJSONObject: payloadDictionary)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(TodoListDTO.self, from: data)
        
        print("Successfully updated list with id \(todoList.id) \(decoded)")
    }
    
    func deleteTodoList(with id: String) async throws {
        var request = URLRequest(url: baseUrl
            .appending(path: "todos")
            .appending(path: id)
            .appending(path: ".json"))
        
        request.httpMethod = "DELETE"
        
        let _ = try await URLSession.shared.data(for: request)
        
        print("Successfully deleted list with id \(id)")
    }
    
//   curl -X POST -d '{ "content": "Buy things", "createDate": "1717081695" }' 'https://todos-9ce97-default-rtdb.europe-west1.firebasedatabase.app/todos/-NzA-bAGuYEjb_HV3NYG/items.json'
    func addItem(to todoList: TodoList, item: String) async throws {
        var request = URLRequest(
            url: baseUrl
                .appending(path: "todos")
                .appending(path: todoList.id)
                .appending(path: "items")
                .appending(path: ".json"))
        
        let item = TodoListDTO.Item(
            content: item,
            createDate: Date())
        
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(item)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(DatabasePOSTResponse.self, from: data)
        
        print("Successfully added an item \(decoded.name)")
    }
    
    private func toDomain(_ todoListResponse: TodoListResponse) -> [TodoList] {
        
        var result = [TodoList]()
        
        for (id, todoListDTO) in todoListResponse {
            result.append(todoListDTO.toDomain(id: id))
        }
        
        return result
    }
}

extension TodoListDTO {
    func toDomain(id: String) -> TodoList {
        TodoList(
            id: id,
            title: title,
            image: icon,
            color: UIColor(hex: color) ?? .clear,
            items: items.toDomain)
    }
}

extension TodoList {
    var toData: TodoListDTO {
        TodoListDTO(
            color: color.hexStringOrWhite,
            icon: image,
            title: title,
            items: items.toData)
    }
}

extension Dictionary where Key == String, Value == TodoListDTO.Item {
    var toDomain: [TodoListItem] {
        var todoListItems = [TodoListItem]()
        for (key, item) in self {
            let todoListItem = TodoListItem(id: key, content: item.content, createDate: item.createDate)
            todoListItems.append(todoListItem)
        }
        
        return todoListItems
            .sorted(by: { $0.createDate < $1.createDate })
    }
}

extension Array where Element == TodoListItem {
    var toData: [String: TodoListDTO.Item] {
        var dict = [String: TodoListDTO.Item]()
        
        for item in self {
            dict[item.id] = TodoListDTO.Item(
                content: item.content,
                createDate: item.createDate)
        }
        
        return dict
    }
}


//curl 'https://todos-9ce97-default-rtdb.europe-west1.firebasedatabase.app/todos.json'

//curl -X POST -d '{ "title": "Groceries", "icon": "avocado", "color": "#4CAF50" }' 'https://todos-9ce97-default-rtdb.europe-west1.firebasedatabase.app/todos.json'

//curl -X PATCH -d '{ "title": "Summer Vacation", "icon": "avocado", "color": "#4CAF50" }' 'https://todos-9ce97-default-rtdb.europe-west1.firebasedatabase.app/todos/vacation.json'

//curl -X DELETE 'https://todos-9ce97-default-rtdb.europe-west1.firebasedatabase.app/todos/7F02D56B-AB46-4EE3-938C-7E400B3FDC19.json'

//curl -X POST -d '{ "content": "Buy things", "createDate": 1717081695 }' 'https://todos-9ce97-default-rtdb.europe-west1.firebasedatabase.app/todos/-NzA-bAGuYEjb_HV3NYG/items.json'
