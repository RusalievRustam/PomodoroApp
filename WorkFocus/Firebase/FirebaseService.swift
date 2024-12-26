import Firebase
import FirebaseFirestore

struct Task: Codable, Identifiable {
    var id: String
    var title: String
    var isCompleted: Bool
}

class FirebaseService {
    private let db = Firestore.firestore()
    
    func addTask(_ task: Task, completion: @escaping (Error?) -> Void) {
        db.collection("tasks").document(task.id).setData([
            "id": task.id,
            "title": task.title,
            "isCompleted": task.isCompleted
        ]) { error in
            completion(error)
        }
    }
    
    func fetchTasks(completion: @escaping ([Task]?, Error?) -> Void) {
        db.collection("tasks").getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            let tasks = snapshot?.documents.compactMap { document -> Task? in
                let data = document.data()
                return Task(
                    id: data["id"] as? String ?? "",
                    title: data["title"] as? String ?? "",
                    isCompleted: data["isCompleted"] as? Bool ?? false
                )
            }
            
            completion(tasks, nil)
        }
    }
}
