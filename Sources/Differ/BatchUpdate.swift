import Foundation

public struct BatchUpdate {
    public struct MoveStep: Equatable {
        public let from: IndexPath
        public let to: IndexPath
    }

    public let deletions: [IndexPath]
    public let insertions: [IndexPath]
    public let moves: [MoveStep]
    
    public init(
        diff: ExtendedDiff,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 }
        ) {
        (deletions, insertions, moves) = diff.reduce(([IndexPath](), [IndexPath](), [MoveStep]()), { (acc, element) in
            var (deletions, insertions, moves) = acc
            switch element {
            case let .delete(at):
                deletions.append(indexPathTransform([0, at]))
            case let .insert(at):
                insertions.append(indexPathTransform([0, at]))
            case let .move(from, to):
                moves.append(MoveStep(from: indexPathTransform([0, from]), to: indexPathTransform([0, to])))
            }
            return (deletions, insertions, moves.reversed())
        })
    }
}
