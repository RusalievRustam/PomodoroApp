//
//  TaskModel.swift
//  WorkFocus
//
//  Created by Rustam Rusaliev on 20/12/24.
//

import Foundation

struct WorkFocusTask: Codable, Identifiable {
    var id: Int
    var title: String
    var isComplete: Bool
}
