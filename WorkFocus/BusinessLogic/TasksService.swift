import FirebaseFirestore

struct CustomUserTask: Identifiable {
    let id: String
    var name: String
    var isCompleted: Bool
}

class TaskService {
    private let db = Firestore.firestore()
    private let tasksCollection = "tasks" // Firestore collection name

    // Method to add a task
    func addTask(name: String, completion: @escaping (Error?) -> Void) {
        let task = CustomUserTask(id: UUID().uuidString, name: name, isCompleted: false)
        let data: [String: Any] = [
            "name": task.name,
            "isCompleted": task.isCompleted
        ]

        db.collection(tasksCollection).document(task.id).setData(data) { error in
            completion(error)
        }
    }

    // Method to fetch tasks
    func fetchTasks(completion: @escaping ([CustomUserTask]?, Error?) -> Void) {
        db.collection(tasksCollection).getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            let tasks: [CustomUserTask]? = snapshot?.documents.compactMap { document -> CustomUserTask? in
                let data = document.data()
                guard let name = data["name"] as? String,
                      let isCompleted = data["isCompleted"] as? Bool else {
                    return nil
                }
                return CustomUserTask(id: document.documentID, name: name, isCompleted: isCompleted)
            }
            completion(tasks, nil)
        }
    }
}
