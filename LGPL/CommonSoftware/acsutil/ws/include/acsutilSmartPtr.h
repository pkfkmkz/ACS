#ifndef ACSUTIL_SMARTPTR_H
#define ACSUTIL_SMARTPTR_H
#include <memory>

namespace acsutil {
    template <typename T>
    using SmartPtr = std::shared_ptr<T>;

    template <typename T>
    static SmartPtr<T> make_shared(T* ptr, void (*deleter)(T*, ...) = nullptr) {
        if (deleter)
            return SmartPtr<T>(ptr, deleter);
        return SmartPtr<T>(ptr);
    }
}

template <typename T, typename U>
inline bool operator==(acsutil::SmartPtr<T>& lhs, U* rhs) {
    return lhs.get() == rhs;
}

template <typename T, typename U>
inline bool operator==(U* rhs, acsutil::SmartPtr<T>& lhs) {
    return lhs == rhs;
}

template <typename T, typename U>
inline bool operator!=(acsutil::SmartPtr<T>& lhs, U* rhs) {
    return !(lhs == rhs);
}

template <typename T, typename U>
inline bool operator!=(U* rhs, acsutil::SmartPtr<T>& lhs) {
    return !(lhs == rhs);
}

#endif  /* ACSUTIL_SMARTPTR_H */
