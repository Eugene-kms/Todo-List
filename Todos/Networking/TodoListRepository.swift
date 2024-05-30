import UIKit

//curl 'https://todos-9ce97-default-rtdb.europe-west1.firebasedatabase.app/todos.json'

//curl -X POST -d '{ "title": "Groceries", "icon": "avocado", "color": "#4CAF50" }' 'https://todos-9ce97-default-rtdb.europe-west1.firebasedatabase.app/todos.json'

class TodoListRepository {
    
    typealias TodoListResponse = [String: TodoListDTO]
    
    private let todosURl = URL(string: "https://todos-9ce97-default-rtdb.europe-west1.firebasedatabase.app/todos.json")!
    
    func fetchTodoLists() async throws -> [TodoList] {
                
        let request = URLRequest(url: todosURl)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoded = try JSONDecoder().decode(TodoListResponse.self, from: data)
        
        return toDomain(decoded)
    }
    
    func addTodoList(_ todoList: TodoList) async throws -> String {
        var request = URLRequest(url: todosURl)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(todoList.toData)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decode = try JSONDecoder().decode(AddTodoListResponse.self, from: data)
        
        return decode.name
    }
    
    private func toDomain(_ todoListResponse: TodoListResponse) -> [TodoList] {
        
        var result = [TodoList]()
        
        for (_, todoListDTO) in todoListResponse {
            result.append(todoListDTO.toDomain)
        }
        
        return result
    }
}

extension TodoListDTO {
    var toDomain: TodoList {
        TodoList(
            title: title,
            image: icon,
            color: UIColor(hex: color) ?? .clear,
            items: items)
    }
}

extension TodoList {
    var toData: TodoListDTO {
        TodoListDTO(
            color: color.hexString ?? "#FFFFFF",
            icon: image,
            title: title,
            items: items)
    }
}
