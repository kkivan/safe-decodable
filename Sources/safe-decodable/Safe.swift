struct MissingValue<T>: Error {}

@propertyWrapper public struct Safe<T> {
    public var wrappedValue: T? {
        projectedValue.value
    }

    public let projectedValue: Result<T, Error>
    public init(projectedValue: Result<T, Error>) {
        self.projectedValue = projectedValue
    }
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
            return Safe(projectedValue: .failure(MissingValue<P>()))
        }
    }
}
