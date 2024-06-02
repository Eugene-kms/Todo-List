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
        let decode = try JSONDecoder().decode(AddTodoListResponse.self, from: data)
        
        return decode.name
    }
    
    func updateTodoList(_ todoList: TodoList) async throws {
        let payloadDictionary: [String: String] = [
            "color": todoList.color.hexStringOrWhite,
            "title": todoList.title,
            "icon": todoList.image]
        
        var request = URLRequest(url: baseUrl
            .appending(path: "todos")
            .appending(path: todoList.id))
        
        request.httpMethod = "PATCH"
        request.httpBody = try JSONSerialization.data(withJSONObject: payloadDictionary)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(TodoListDTO.self, from: data)
        
        print("Successfully updated list with id \(todoList.id) \(decoded)")
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
            items: items)
    }
}

extension TodoList {
    var toData: TodoListDTO {
        TodoListDTO(
            color: color.hexStringOrWhite,
            icon: image,
            title: title,
            items: items)
    }
}


//curl 'https://todos-9ce97-default-rtdb.europe-west1.firebasedatabase.app/todos.json'

//curl -X POST -d '{ "title": "Groceries", "icon": "avocado", "color": "#4CAF50" }' 'https://todos-9ce97-default-rtdb.europe-west1.firebasedatabase.app/todos.json'

//curl -X PATCH -d '{ "title": "Summer Vacation", "icon": "avocado", "color": "#4CAF50" }' 'https://todos-9ce97-default-rtdb.europe-west1.firebasedatabase.app/todos/vacation.json'
