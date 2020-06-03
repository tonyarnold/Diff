#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: - NSTableView

extension NSTableView {

    /// Animates rows which changed between oldData and newData using custom `isEqual`.
    ///
    /// - Parameters:
    ///   - oldData:            Data which reflects the previous state of `NSTableView`
    ///   - newData:            Data which reflects the current state of `NSTableView`
    ///   - isEqual:            A function comparing two elements of `T`
    ///   - deletionAnimation:  Animation type for deletions
    ///   - insertionAnimation: Animation type for insertions
    ///   - rowIndexTransform:  Closure which transforms a zero-based row to the desired index
    public func animateRowChanges<T: Collection>(
        oldData: T,
        newData: T,
        isEqual: EqualityChecker<T>,
        deletionAnimation: NSTableView.AnimationOptions = [],
        insertionAnimation: NSTableView.AnimationOptions = [],
        rowIndexTransform: (Int) -> Int = { $0 }
    ) {
        apply(
            oldData.extendedDiff(newData, isEqual: isEqual).patch(from: oldData, to: newData),
            deletionAnimation: deletionAnimation,
            insertionAnimation: insertionAnimation,
            rowIndexTransform: rowIndexTransform
        )
    }

    /// Animates rows which changed between oldData and newData.
    ///
    /// - Parameters:
    ///   - oldData:            Data which reflects the previous state of `NSTableView`
    ///   - newData:            Data which reflects the current state of `NSTableView`
    ///   - deletionAnimation:  Animation type for deletions
    ///   - insertionAnimation: Animation type for insertions
    ///   - rowIndexTransform:  Closure which transforms a zero-based row to the desired index
    public func animateRowChanges<T: Collection>(
        oldData: T,
        newData: T,
        deletionAnimation: NSTableView.AnimationOptions = [],
        insertionAnimation: NSTableView.AnimationOptions = [],
        rowIndexTransform: (Int) -> Int = { $0 }
    ) where T.Element: Equatable {
        apply(
            extendedPatch(from: oldData, to: newData),
            deletionAnimation: deletionAnimation,
            insertionAnimation: insertionAnimation,
            rowIndexTransform: rowIndexTransform
        )
    }

    /// Animates a series of patches in a single beginUpdates/endUpdates batch.
    /// - Parameters:
    ///   - patches: A series of patches to apply
    ///   - deletionAnimation: Animation type for deletions
    ///   - insertionAnimation: Animation type for insertions
    ///   - rowIndexTransform: Closure which transforms a zero-based row to the desired index
    public func apply<T>(
        _ patches: [ExtendedPatch<T>],
        deletionAnimation: NSTableView.AnimationOptions = [],
        insertionAnimation: NSTableView.AnimationOptions = [],
        rowIndexTransform: (Int) -> Int = { $0 }
    ) {
        beginUpdates()
        for patch in patches {
            switch patch {
            case .insertion(index: let index, element: _):
                insertRows(at: .init(integer: rowIndexTransform(index)), withAnimation: insertionAnimation)
            case .deletion(index: let index):
                removeRows(at: .init(integer: rowIndexTransform(index)), withAnimation: deletionAnimation)
            case .move(from: let from, to: let to):
                moveRow(at: rowIndexTransform(from), to: rowIndexTransform(to))
            }
        }
        endUpdates()
    }

    // MARK: Deprecated

    /// Animates rows which changed between oldData and newData.
    ///
    /// - Parameters:
    ///   - oldData:            Data which reflects the previous state of `NSTableView`
    ///   - newData:            Data which reflects the current state of `NSTableView`
    ///   - isEqual:            A function comparing two elements of `T`
    ///   - deletionAnimation:  Animation type for deletions
    ///   - insertionAnimation: Animation type for insertions
    ///   - indexPathTransform: Closure which transforms zero-based `IndexPath` to desired `IndexPath`. Only the `.item` is used, not the `.section`.
    @available(*, deprecated, message: "Use `animateRowChanges(…rowIndexTransform:)`instead. Deprecated because indexPaths are not used in `NSTableView` rows, just Integer row indices.")
    public func animateRowChanges<T: Collection>(
        oldData: T,
        newData: T,
        isEqual: EqualityChecker<T>,
        deletionAnimation: NSTableView.AnimationOptions = [],
        insertionAnimation: NSTableView.AnimationOptions = [],
        indexPathTransform: (IndexPath) -> IndexPath
    ) {
        animateRowChanges(
            oldData: oldData,
            newData: newData,
            isEqual: isEqual,
            deletionAnimation: deletionAnimation,
            insertionAnimation: insertionAnimation,
            rowIndexTransform: { indexPathTransform(.init(item: $0, section: 0)).item }
        )
    }

    /// Animates rows which changed between oldData and newData.
    ///
    /// - Parameters:
    ///   - oldData:            Data which reflects the previous state of `NSTableView`
    ///   - newData:            Data which reflects the current state of `NSTableView`
    ///   - deletionAnimation:  Animation type for deletions
    ///   - insertionAnimation: Animation type for insertions
    ///   - indexPathTransform: Closure which transforms zero-based `IndexPath` to desired `IndexPath`. Only the `.item` is used, not the `.section`.
    @available(*, deprecated, message: "Use `animateRowChanges(…rowIndexTransform:)`instead. Deprecated because indexPaths are not used in `NSTableView` rows, just Integer row indices.")
    public func animateRowChanges<T: Collection>(
        oldData: T,
        newData: T,
        deletionAnimation: NSTableView.AnimationOptions = [],
        insertionAnimation: NSTableView.AnimationOptions = [],
        indexPathTransform: (IndexPath) -> IndexPath
    ) where T.Element: Equatable {
        animateRowChanges(
            oldData: oldData,
            newData: newData,
            deletionAnimation: deletionAnimation,
            insertionAnimation: insertionAnimation,
            rowIndexTransform: { indexPathTransform(.init(item: $0, section: 0)).item }
        )
    }

    @available(*, deprecated, message: "Use `apply(_ patches: …)` based on `ExtendedPatch` instead. Deprecated because it has errors animating multiple moves.")
    public func apply(
        _ diff: ExtendedDiff,
        deletionAnimation: NSTableView.AnimationOptions = [],
        insertionAnimation: NSTableView.AnimationOptions = [],
        indexPathTransform: (IndexPath) -> IndexPath = { $0 }
    ) {
        let update = BatchUpdate(diff: diff, indexPathTransform: indexPathTransform)

        beginUpdates()
        removeRows(at: IndexSet(update.deletions.map { $0.item }), withAnimation: deletionAnimation)
        insertRows(at: IndexSet(update.insertions.map { $0.item }), withAnimation: insertionAnimation)
        update.moves.forEach { moveRow(at: $0.from.item, to: $0.to.item) }
        endUpdates()
    }
}

// MARK: - NSCollectionView

@available(macOS 10.11, *)
public extension NSCollectionView {
    /// Animates items which changed between oldData and newData.
    ///
    /// - Parameters:
    ///   - oldData:            Data which reflects the previous state of `UICollectionView`
    ///   - newData:            Data which reflects the current state of `UICollectionView`
    ///   - indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    ///   - completion:         Closure to be executed when the animation completes
    func animateItemChanges<T: Collection>(
        oldData: T,
        newData: T,
        indexPathTransform: @escaping (IndexPath) -> IndexPath = { $0 },
        completion: ((Bool) -> Void)? = nil
        ) where T.Element: Equatable {
        let diff = oldData.extendedDiff(newData)
        apply(diff, completion: completion, indexPathTransform: indexPathTransform)
    }

    /// Animates items which changed between oldData and newData.
    ///
    /// - Parameters:
    ///   - oldData:            Data which reflects the previous state of `UICollectionView`
    ///   - newData:            Data which reflects the current state of `UICollectionView`
    ///   - isEqual:            A function comparing two elements of `T`
    ///   - indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    ///   - completion:         Closure to be executed when the animation completes
    func animateItemChanges<T: Collection>(
        oldData: T,
        newData: T,
        isEqual: EqualityChecker<T>,
        indexPathTransform: @escaping (IndexPath) -> IndexPath = { $0 },
        completion: ((Bool) -> Swift.Void)? = nil
        ) {
        let diff = oldData.extendedDiff(newData, isEqual: isEqual)
        apply(diff, completion: completion, indexPathTransform: indexPathTransform)
    }

    func apply(
        _ diff: ExtendedDiff,
        completion: ((Bool) -> Swift.Void)? = nil,
        indexPathTransform: @escaping (IndexPath) -> IndexPath = { $0 }
        ) {
        self.animator()
        .performBatchUpdates({
            let update = BatchUpdate(diff: diff, indexPathTransform: indexPathTransform)
            self.deleteItems(at: Set(update.deletions))
            self.insertItems(at: Set(update.insertions))
            update.moves.forEach { self.moveItem(at: $0.from, to: $0.to) }
        }, completionHandler: completion)
    }

    /// Animates items and sections which changed between oldData and newData.
    ///
    /// - Parameters:
    ///   - oldData:            Data which reflects the previous state of `UICollectionView`
    ///   - newData:            Data which reflects the current state of `UICollectionView`
    ///   - indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    ///   - sectionTransform:   Closure which transforms zero-based section(`Int`) into desired section(`Int`)
    ///   - completion:         Closure to be executed when the animation completes
    func animateItemAndSectionChanges<T: Collection>(
        oldData: T,
        newData: T,
        indexPathTransform: @escaping (IndexPath) -> IndexPath = { $0 },
        sectionTransform: @escaping (Int) -> Int = { $0 },
        completion: ((Bool) -> Swift.Void)? = nil
        )
        where T.Element: Collection,
        T.Element: Equatable,
        T.Element.Element: Equatable {
            self.apply(
                oldData.nestedExtendedDiff(to: newData),
                indexPathTransform: indexPathTransform,
                sectionTransform: sectionTransform,
                completion: completion
            )
    }

    /// Animates items and sections which changed between oldData and newData.
    ///
    /// - Parameters:
    ///   - oldData:            Data which reflects the previous state of `UICollectionView`
    ///   - newData:            Data which reflects the current state of `UICollectionView`
    ///   - isEqualElement:     A function comparing two items (elements of `T.Element`)
    ///   - indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    ///   - sectionTransform:   Closure which transforms zero-based section(`Int`) into desired section(`Int`)
    ///   - completion:         Closure to be executed when the animation completes
    func animateItemAndSectionChanges<T: Collection>(
        oldData: T,
        newData: T,
        isEqualElement: NestedElementEqualityChecker<T>,
        indexPathTransform: @escaping (IndexPath) -> IndexPath = { $0 },
        sectionTransform: @escaping (Int) -> Int = { $0 },
        completion: ((Bool) -> Swift.Void)? = nil
        )
        where T.Element: Collection,
        T.Element: Equatable {
            self.apply(
                oldData.nestedExtendedDiff(
                    to: newData,
                    isEqualElement: isEqualElement
                ),
                indexPathTransform: indexPathTransform,
                sectionTransform: sectionTransform,
                completion: completion
            )
    }

    /// Animates items and sections which changed between oldData and newData.
    ///
    /// - Parameters:
    ///   - oldData:            Data which reflects the previous state of `UICollectionView`
    ///   - newData:            Data which reflects the current state of `UICollectionView`
    ///   - isEqualSection:     A function comparing two sections (elements of `T`)
    ///   - indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    ///   - sectionTransform:   Closure which transforms zero-based section(`Int`) into desired section(`Int`)
    ///   - completion:         Closure to be executed when the animation completes
    func animateItemAndSectionChanges<T: Collection>(
        oldData: T,
        newData: T,
        isEqualSection: EqualityChecker<T>,
        indexPathTransform: @escaping (IndexPath) -> IndexPath = { $0 },
        sectionTransform: @escaping (Int) -> Int = { $0 },
        completion: ((Bool) -> Swift.Void)? = nil
        )
        where T.Element: Collection,
        T.Element.Element: Equatable {
            self.apply(
                oldData.nestedExtendedDiff(
                    to: newData,
                    isEqualSection: isEqualSection
                ),
                indexPathTransform: indexPathTransform,
                sectionTransform: sectionTransform,
                completion: completion
            )
    }

    /// Animates items and sections which changed between oldData and newData.
    ///
    /// - Parameters:
    ///   - oldData:            Data which reflects the previous state of `UICollectionView`
    ///   - newData:            Data which reflects the current state of `UICollectionView`
    ///   - isEqualSection:     A function comparing two sections (elements of `T`)
    ///   - isEqualElement:     A function comparing two items (elements of `T.Element`)
    ///   - indexPathTransform: Closure which transforms zero-based `IndexPath` to desired  `IndexPath`
    ///   - sectionTransform:   Closure which transforms zero-based section(`Int`) into desired section(`Int`)
    ///   - completion:         Closure to be executed when the animation completes
    func animateItemAndSectionChanges<T: Collection>(
        oldData: T,
        newData: T,
        isEqualSection: EqualityChecker<T>,
        isEqualElement: NestedElementEqualityChecker<T>,
        indexPathTransform: @escaping (IndexPath) -> IndexPath = { $0 },
        sectionTransform: @escaping (Int) -> Int = { $0 },
        completion: ((Bool) -> Swift.Void)? = nil
        )
        where T.Element: Collection {
            self.apply(
                oldData.nestedExtendedDiff(
                    to: newData,
                    isEqualSection: isEqualSection,
                    isEqualElement: isEqualElement
                ),
                indexPathTransform: indexPathTransform,
                sectionTransform: sectionTransform,
                completion: completion
            )
    }

    func apply(
        _ diff: NestedExtendedDiff,
        indexPathTransform: @escaping (IndexPath) -> IndexPath = { $0 },
        sectionTransform: @escaping (Int) -> Int = { $0 },
        completion: ((Bool) -> Void)? = nil
        ) {
        self.animator()
        .performBatchUpdates({
            let update = NestedBatchUpdate(diff: diff, indexPathTransform: indexPathTransform, sectionTransform: sectionTransform)
            self.insertSections(update.sectionInsertions)
            self.deleteSections(update.sectionDeletions)
            update.sectionMoves.forEach { self.moveSection($0.from, toSection: $0.to) }
            self.deleteItems(at: Set(update.itemDeletions))
            self.insertItems(at: Set(update.itemInsertions))
            update.itemMoves.forEach { self.moveItem(at: $0.from, to: $0.to) }
        }, completionHandler: completion)
    }
}

#endif
