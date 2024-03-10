//
//  TeamMember.swift
//  TeamWorkOrganiztion
//
//  Created by User on 2023-11-10.
//

import Foundation
import UIKit

/// Represents a Model for any Organization Team Member profile.
struct TeamMember: Codable {
    var userId: String?
    var dateCreated: Date?
    
    
    /// Coding keys to specify custom keys for decoding/encoding.
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case dateCreated = "date_created"
    }
    
    
    /// Initializes a team member from decoder.
    /// - Parameter decoder: The decoder used to read data from.
    /// - Throws: An error during the decoding process.
    init(from decoder: Decoder) throws {
        let container        = try decoder.container(keyedBy: CodingKeys.self)
        self.userId          = try container.decodeIfPresent(String.self, forKey: .userId)
        self.dateCreated     = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
    }
}
