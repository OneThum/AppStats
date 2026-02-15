// NetworkManager.swift - Network communication
// Copyright © 2026 One Thum Software

import Foundation
#if canImport(Compression)
import Compression
#endif

/// Handles network requests to the AppStats ingestion API
actor NetworkManager {
    
    // MARK: - Properties
    
    private let apiKey: String
    private let baseURL: URL
    private let session: URLSession
    
    private var consecutiveFailures = 0
    private let maxConsecutiveFailures = 10
    private var isInBackoff = false
    private var backoffUntil: Date?
    
    // MARK: - Initialization
    
    init(apiKey: String, baseURL: URL) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        
        // Configure URL session with timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.networkServiceType = .background
        
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Event Sending
    
    /// Send a batch of events to the ingestion API
    func sendEvents(_ events: [Event]) async throws {
        // Check circuit breaker
        if isInBackoff, let until = backoffUntil, Date() < until {
            throw NetworkError.inBackoff
        }
        
        // Reset backoff if time has passed
        if let until = backoffUntil, Date() >= until {
            isInBackoff = false
            backoffUntil = nil
            consecutiveFailures = 0
        }
        
        // Prepare request
        let url = baseURL.appendingPathComponent("/v1/ingest")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "X-AS-Key")
        request.setValue(SDKInfo.version, forHTTPHeaderField: "X-AS-SDK-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("gzip", forHTTPHeaderField: "Content-Encoding")
        
        // Encode events to JSON
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let jsonData = try encoder.encode(events)
        
        // Compress with gzip
        let compressedData = try compressGzip(jsonData)
        request.httpBody = compressedData
        
        // Send request
        do {
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            // Check status code
            switch httpResponse.statusCode {
            case 200...299:
                // Success - reset failure counter
                consecutiveFailures = 0
                
            case 400...499:
                // Client error - don't retry
                consecutiveFailures = 0
                throw NetworkError.clientError(httpResponse.statusCode)
                
            case 500...599:
                // Server error - count as failure
                handleFailure()
                throw NetworkError.serverError(httpResponse.statusCode)
                
            default:
                handleFailure()
                throw NetworkError.unexpectedStatusCode(httpResponse.statusCode)
            }
            
        } catch {
            handleFailure()
            throw error
        }
    }
    
    // MARK: - Private
    
    private func handleFailure() {
        consecutiveFailures += 1
        
        // Trigger circuit breaker after max failures
        if consecutiveFailures >= maxConsecutiveFailures {
            isInBackoff = true
            
            // Exponential backoff: 60s, 120s, 240s, ... up to 1 hour
            let backoffSeconds = min(60 * pow(2.0, Double(consecutiveFailures - maxConsecutiveFailures)), 3600)
            backoffUntil = Date().addingTimeInterval(backoffSeconds)
        }
    }
    
    private func compressGzip(_ data: Data) throws -> Data {
        #if canImport(Compression)
        return try data.withUnsafeBytes { (sourcePtr: UnsafeRawBufferPointer) -> Data in
            let bufferSize = data.count
            var destinationBuffer = Data(count: bufferSize)
            
            let compressedSize = destinationBuffer.withUnsafeMutableBytes { (destPtr: UnsafeMutableRawBufferPointer) -> Int in
                compression_encode_buffer(
                    destPtr.baseAddress!.assumingMemoryBound(to: UInt8.self),
                    bufferSize,
                    sourcePtr.baseAddress!.assumingMemoryBound(to: UInt8.self),
                    data.count,
                    nil,
                    COMPRESSION_ZLIB
                )
            }
            
            guard compressedSize > 0 else {
                throw NetworkError.compressionFailed
            }
            
            return destinationBuffer.prefix(compressedSize)
        }
        #else
        // Fallback: return uncompressed if compression not available
        return data
        #endif
    }
}

// MARK: - Errors

enum NetworkError: Error {
    case invalidResponse
    case clientError(Int)
    case serverError(Int)
    case unexpectedStatusCode(Int)
    case compressionFailed
    case inBackoff
}
