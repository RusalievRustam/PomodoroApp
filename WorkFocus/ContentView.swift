//
//  ContentView.swift
//  WorkFocus
//
//  Created by Rustam Rusaliev on 19/12/24.
//

import SwiftUI
import FirebaseFirestore

struct ContentView: View {
    private var timer = WorkFocusTimer(workInSeconds: 5, breakInSeconds: 5)

    @State private var displayWarning = false
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        TabView {
            // Первый экран с таймером
            TimerView(timer: timer, displayWarning: $displayWarning, scenePhase: scenePhase)
                .tabItem {
                    Label("Timer", systemImage: "clock")
                }

            // Экран задач
            TaskScreen()
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet")
                }
        }
        .backgroundStyle() // Используем общий фон для TabView
    }
}

// Модификатор для общего фона
struct BackgroundStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RadialGradient(
                    gradient: Gradient(colors: [Color("Light"), Color("Dark")]),
                    center: .center,
                    startRadius: 5,
                    endRadius: 500
                )
            )
            .ignoresSafeArea()
    }
}

// Расширение для удобного применения модификатора
extension View {
    func backgroundStyle() -> some View {
        self.modifier(BackgroundStyle())
    }
}

// Экран таймера (с добавлением общего фона)
struct TimerView: View {
    var timer: WorkFocusTimer
    @Binding var displayWarning: Bool
    var scenePhase: ScenePhase

    var body: some View {
        VStack {
            CircleTimer(fraction: timer.fractionPassed, primaryText: timer.secondsLeftString, secondaryText: timer.mode.rawValue)

            HStack {
                if timer.state == .idle && timer.mode == .pause {
                    CircleButton(icon: "forward.fill") {
                        timer.skip()
                    }
                }
                if timer.state == .idle {
                    CircleButton(icon: "play.fill") {
                        timer.start()
                    }
                }
                if timer.state == .paused {
                    CircleButton(icon: "play.fill") {
                        timer.resume()
                    }
                }
                if timer.state == .running {
                    CircleButton(icon: "pause.fill") {
                        timer.pause()
                    }
                }
                if timer.state == .running || timer.state == .paused {
                    CircleButton(icon: "stop.fill") {
                        timer.reset()
                    }
                }
            }
            if displayWarning {
                NotificationsDisabled()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundStyle() // Применяем фон
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                WorkFocusNotification.checkAuthorization { authorized in
                    displayWarning = !authorized
                }
            }
        }
    }
}

// Переименованный тип задачи
struct UserTask: Identifiable {
    let id = UUID() // Уникальный идентификатор задачи
    var name: String
    var isCompleted: Bool
}

struct FirestoreManager {
    private let db = Firestore.firestore()

    // Метод для добавления задачи в Firestore
    func addTask(name: String, isCompleted: Bool) {
        let taskData: [String: Any] = [
            "name": name,
            "isCompleted": isCompleted
        ]

        // Сохраняем в коллекцию "tasks"
        db.collection("tasks").addDocument(data: taskData) { error in
            if let error = error {
                print("Error adding task: \(error.localizedDescription)")
            } else {
                print("Task added successfully!")
            }
        }
    }
    
    // Метод для обновления задачи по имени
    func updateTask(name: String, isCompleted: Bool) {
        db.collection("tasks").whereField("name", isEqualTo: name).getDocuments { snapshot, error in
            if let error = error {
                print("Error finding task: \(error.localizedDescription)")
            } else if let snapshot = snapshot, !snapshot.isEmpty {
                // Предполагаем, что имя уникально и берём первый документ
                if let document = snapshot.documents.first {
                    document.reference.updateData([
                        "isCompleted": isCompleted
                    ]) { error in
                        if let error = error {
                            print("Error updating task: \(error.localizedDescription)")
                        } else {
                            print("Task updated successfully!")
                        }
                    }
                }
            } else {
                print("Task with name '\(name)' not found.")
            }
        }
    }
    
    func deleteTask(taskId: String) {
        db.collection("tasks").document(taskId).delete { error in
            if let error = error {
                print("Error deleting task: \(error.localizedDescription)")
            } else {
                print("Task deleted successfully!")
            }
        }
    }
}

// Экран для управления задачами (с добавлением общего фона)
struct TaskScreen: View {
    @State private var newTaskName: String = ""
    @State private var tasks: [UserTask] = [] // Используем новый тип UserTask

    var body: some View {
        VStack(spacing: 20) {
            // Заголовок
            Text("Tasks")
                .font(.largeTitle)
                .bold()

            // Поле для ввода новой задачи
            HStack {
                TextField("Enter task name", text: $newTaskName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .cornerRadius(8) // Округляем углы поля ввода

                Button(action: {
                    FirestoreManager().addTask(name: newTaskName, isCompleted: false)
                    addTask()
                }) {
                    Text("Add")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8) // Округляем углы кнопки
                }
                .disabled(newTaskName.isEmpty) // Кнопка недоступна, если поле ввода пустое
            }
            .padding()

            // Список задач
            List {
                ForEach($tasks) { $task in
                    HStack {
                        // Чекбокс для отметки выполнения
                        Button(action: {
                            task.isCompleted.toggle()
                            FirestoreManager().updateTask(name: task.name, isCompleted: task.isCompleted)
                        }) {
                            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(task.isCompleted ? .green : .gray)
                        }
                        .buttonStyle(BorderlessButtonStyle()) // Убирает ненужные выделения кнопки

                        // Название задачи
                        Text(task.name)
                            .strikethrough(task.isCompleted) // Зачёркивает текст, если задача выполнена
                            .foregroundColor(task.isCompleted ? .gray : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Кнопка удаления
                        Button(action: {
                            deleteTask(task: task)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle()) // Убирает ненужные выделения кнопки
                    }
                }
                .onDelete(perform: deleteTaskAtOffsets) // Позволяет удалять задачи свайпом
            }
            .listStyle(PlainListStyle()) // Используем плоский стиль для списка
            .padding() // Убираем стандартные отступы
            .background(Color.white) // Устанавливаем белый фон для списка
            .cornerRadius(10) // Округляем углы списка
            .shadow(radius: 5) // Добавляем тень к списку
        }
        .padding()
        .backgroundStyle() // Применяем фон
    }

    // Добавление задачи
    private func addTask() {
        let newTask = UserTask(name: newTaskName, isCompleted: false)
        tasks.append(newTask)
        newTaskName = "" // Очищаем поле ввода
    }

    // Удаление задачи через кнопку
    private func deleteTask(task: UserTask) {
        tasks.removeAll { $0.id == task.id }
    }

    // Удаление задачи через свайп
    private func deleteTaskAtOffsets(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}
