//
//  Copyright © 2018 wczekalski. All rights reserved.

#if !os(watchOS)
import Foundation

public struct NestedBatchUpdate {
    public let itemDeletions: [IndexPath]
    public let itemInsertions: [IndexPath]
    public let itemMoves: [(from: IndexPath, to: IndexPath)]
    public let sectionDeletions: IndexSet
    public let sectionInsertions: IndexSet
    public let sectionMoves: [(from: Int, to: Int)]

    public init(
        diff: NestedExtendedDiff,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 },
        sectionTransform: (Int) -> Int = { $0 }
        ) {
        var itemDeletions: [IndexPath] = []
        var itemInsertions: [IndexPath] = []
        var itemMoves: [(IndexPath, IndexPath)] = []
        var sectionDeletions: IndexSet = []
        var sectionInsertions: IndexSet = []
        var sectionMoves: [(from: Int, to: Int)] = []

        diff.forEach { element in
            switch element {
            case let .deleteElement(at, section):
                itemDeletions.append(indexPathTransform([section, at]))
            case let .insertElement(at, section):
                itemInsertions.append(indexPathTransform([section, at]))
            case let .moveElement(from, to):
                itemMoves.append((indexPathTransform([from.section, from.item]), indexPathTransform([to.section, to.item])))
            case let .deleteSection(at):
                sectionDeletions.insert(sectionTransform(at))
            case let .insertSection(at):
                sectionInsertions.insert(sectionTransform(at))
            case let .moveSection(moveFrom, moveTo):
                sectionMoves.append((sectionTransform(moveFrom), sectionTransform(moveTo)))
            }
        }

        self.itemInsertions = itemInsertions
        self.itemDeletions = itemDeletions
        self.itemMoves = itemMoves
        self.sectionMoves = sectionMoves
        self.sectionInsertions = sectionInsertions
        self.sectionDeletions = sectionDeletions
    }
}

#endif

