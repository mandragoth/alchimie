/** 
 * Copyright: Enalye
 * License: Zlib
 * Authors: Enalye
 */
module magia.core.array;

import std.parallelism;
import std.range;
import std.typecons;

/// Liste supprimant la fragmentation tout en gardant les index valides.
final class Array(T, size_t _capacity, bool _useParallelism = false) {
    private size_t _dataTop = 0u;
    private size_t _availableIndexesTop = 0u;
    private size_t _removeTop = 0u;

    private T[_capacity] _dataTable;
    private size_t[_capacity] _availableIndexes;
    private size_t[_capacity] _translationTable;
    private size_t[_capacity] _reverseTranslationTable;
    private size_t[_capacity] _removeTable;

    @property {
        /// Nombre d’éléments contenus
        size_t length() const {
            return _dataTop;
        }

        /// Capacité maximale que peut contenir la liste
        size_t capacity() const {
            return _capacity;
        }

        /// Liste des éléments contenus
        ref T[_capacity] data() {
            return _dataTable;
        }

        /// La liste est-elle vide ?
        bool empty() const {
            return _dataTop == 0;
        }

        /// La liste est-elle pleine ?
        bool full() const {
            return (_dataTop + 1u) == _capacity;
        }
    }

    /// Ajoute un élément à la liste
    size_t push(T value) {
        size_t index;

        if ((_dataTop + 1u) == _capacity) {
            throw new Exception("array overload");
        }

        if (_availableIndexesTop) {
            //Take out the last available index on the list.
            _availableIndexesTop--;
            index = _availableIndexes[_availableIndexesTop];
        } else {
            //Or use a new id.
            index = _dataTop;
        }

        //Add the value to the data stack.
        _dataTable[_dataTop] = value;
        _translationTable[index] = _dataTop;
        _reverseTranslationTable[_dataTop] = index;

        ++_dataTop;

        return index;
    }

    /// Retire un élément de la liste
    void pop(size_t index) {
        size_t valueIndex = _translationTable[index];

        //Push the index on the available indexes stack.
        _availableIndexes[_availableIndexesTop] = index;
        _availableIndexesTop++;

        //Invalidate the index.
        _translationTable[index] = -1;

        //Take the top value on the stack and fill the gap.
        _dataTop--;
        if (valueIndex < _dataTop) {
            size_t userIndex = _reverseTranslationTable[_dataTop];
            _dataTable[valueIndex] = _dataTable[_dataTop];
            _translationTable[userIndex] = valueIndex;
            _reverseTranslationTable[valueIndex] = userIndex;
        }
    }

    /// Vide la liste
    void reset() {
        _dataTop = 0u;
        _availableIndexesTop = 0u;
        _removeTop = 0u;
    }

    /// Marque un élément à supprimer
    void mark(size_t index) {
        _removeTable[_removeTop] = index;
        _removeTop++;
    }

    /// Supprime tous les éléments marqué pour suppression
    void sweep() {
        for (size_t i = 0u; i < _removeTop; i++) {
            pop(_removeTable[i]);
        }
        _removeTop = 0u;
    }

    static if (_useParallelism) {
        /// Itère sur la liste
        int opApply(int delegate(ref T) dlg) {
            int result;

            foreach (i; parallel(iota(_dataTop))) {
                result = dlg(_dataTable[i]);

                if (result)
                    break;
            }

            return result;
        }
    } else {
        /// Ditto
        int opApply(int delegate(ref T) dlg) {
            int result;

            foreach (i; 0u .. _dataTop) {
                result = dlg(_dataTable[i]);

                if (result)
                    break;
            }

            return result;
        }
    }

    /// Ditto
    int opApply(int delegate(const ref T) dlg) const {
        int result;

        foreach (i; 0u .. _dataTop) {
            result = dlg(_dataTable[i]);

            if (result)
                break;
        }

        return result;
    }

    static if (_useParallelism) {
        /// Ditto
        int opApply(int delegate(const size_t, ref T) dlg) {
            int result;

            foreach (i; parallel(iota(_dataTop))) {
                result = dlg(_reverseTranslationTable[i], _dataTable[i]);

                if (result)
                    break;
            }

            return result;
        }
    } else {
        /// Ditto
        int opApply(int delegate(const size_t, ref T) dlg) {
            int result;

            foreach (i; 0u .. _dataTop) {
                result = dlg(_reverseTranslationTable[i], _dataTable[i]);

                if (result)
                    break;
            }

            return result;
        }
    }

    /// Ditto
    int opApply(int delegate(const size_t, const ref T) dlg) const {
        int result;

        foreach (i; 0u .. _dataTop) {
            result = dlg(_reverseTranslationTable[i], _dataTable[i]);

            if (result)
                break;
        }

        return result;
    }

    /// Ditto
    int opApply(int delegate(const Tuple!(const size_t, const T)) dlg) const {
        int result;

        foreach (i; 0u .. _dataTop) {
            result = dlg(tuple!(const size_t, const T)(_reverseTranslationTable[i], _dataTable[i]));

            if (result)
                break;
        }

        return result;
    }

    /// Accède à un élément
    T opIndex(size_t index) {
        return _dataTable[_translationTable[index]];
    }

    /// Ditto
    T opIndexAssign(T value, size_t index) {
        return _dataTable[_translationTable[index]] = value;
    }

    /// L’index est-il valide ?
    bool has(size_t index) {
        if (index > _dataTop)
            return false;
        if (_translationTable[index] == -1)
            return false;
        return true;
    }

    /// Returne le premier élément dans la liste
    T front() {
        assert(_dataTop > 0);
        return _dataTable[0];
    }

    /// Returne le dernier élément dans la liste
    T back() {
        assert(_dataTop > 0);
        return _dataTable[_dataTop - 1];
    }
}
