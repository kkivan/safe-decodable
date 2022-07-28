import Foundation

@propertyWrapper public struct Safe<T> {
    public var wrappedValue: T? {
        projectedValue.value
    }

    public let projectedValue: Result<T, Error>
    public init(projectedValue: Result<T, Error>) {
        self.projectedValue = projectedValue
    }
}

@propertyWrapper public struct SafeArray<T> {
    public var wrappedValue: [T] {
        projectedValue.compactMap(\.wrappedValue)
    }

    public let projectedValue: [Safe<T>]
    public init(projectedValue: [Safe<T>]) {
        self.projectedValue = projectedValue
    }
}

extension SafeArray: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        self.projectedValue = try [Safe<T>].init(from: decoder)
    }
}

@propertyWrapper public struct SafeDictionary<Key, T> where Key: Hashable & Decodable, T: Decodable {
    public var wrappedValue: [Key: T] {
        projectedValue.compactMapValues(\.wrappedValue)
    }

    public let projectedValue: [Key: Safe<T>]
    public init(projectedValue: [Key: Safe<T>]) {
        self.projectedValue = projectedValue
    }
}

extension SafeDictionary: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        self.projectedValue = try [Key: Safe<T>].init(from: decoder)
    }
}

public extension Safe where T: ErrorCollector {
    func collectErrors() -> [Error] {
        switch projectedValue {
            case .failure(let error): return [error]
            case .success(let value): return value.collectErrors()
        }
    }
}

public protocol ErrorCollector {
    func collectErrors() -> [Error]
}


extension Safe: Decodable where T: Decodable {
    public init(from decoder: Decoder) throws {
        self.projectedValue = .init(catching: { try T.init(from: decoder) })
    }
}

extension Safe: Encodable where T: Encodable {
    public func encode(to encoder: Encoder) throws {
        try wrappedValue?.encode(to: encoder)
    }
}

public extension Result {
    var value: Success? {
        if case let .success(value) = self {
            return value
        }
        return nil
    }

    var error: Error? {
        if case let .failure(error) = self {
            return error
        }
        return nil
    }
}

public extension KeyedDecodingContainer {

    func decode<P>(_: Safe<P>.Type, forKey key: Key) throws -> Safe<P> where P: Decodable {
        if let value = try self.decodeIfPresent(Safe<P>.self, forKey: key) {
            return value
        } else {
            return Safe(projectedValue: .failure(MissingValue<P>(codingPath: codingPath + [key])))
        }
    }
}

struct MissingValue<T>: Error, CustomStringConvertible {
    let codingPath: [CodingKey]

    var description: String {
        "\(Self.self) codingPath: \(codingPath.map(\.stringValue).joined(separator: "."))"
    }
}
