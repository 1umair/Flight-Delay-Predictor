

import Foundation

class NetworkEngine {
    class func setRequest(serviceURL: URL, httpMethod: String) -> URLRequest {
        print("\n---------API CALLED-----\n", serviceURL)
        var request = URLRequest(url: serviceURL)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = httpMethod
        return request
    }

    class func callGetAPI(api: String, adminRequired: Bool, completionBlock: @escaping (Data?, Int?, Error?) -> Void) {
        /*let baseURL = Bundle.main.object(forInfoDictionaryKey: "ConfigURL") as? String ?? ""
        guard let url = URL(string: baseURL + "/" + api) else {
            print("Error: cannot create URL")
            return
        }*/
        guard let url = URL(string: api) else {
            print("Error: cannot create URL")
            return
        }
        let request = setRequest(serviceURL: url, httpMethod: "GET")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let HTTPResponse = response as? HTTPURLResponse {
                let statusCode = HTTPResponse.statusCode
                if let data = data {
                    print("\n--------API Response-----\n", api)
                    print(String(data: data, encoding: .utf8) ?? "")
                    completionBlock(data, statusCode, error)
                }
            }
        }
        task.resume()
    }

    class func callPostAPI(api: String, adminRequired: Bool, parameters: [String: Any], completionBlock: @escaping (Data?, Int?, Error?) -> Void) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        /*let baseURL = Bundle.main.object(forInfoDictionaryKey: "ConfigURL") as? String ?? ""
        guard let serviceURL = URL(string: baseURL + "/" + api) else {
            print("Error: cannot create URL")
            return
        }*/
        guard let url = URL(string: api) else {
            print("Error: cannot create URL")
            return
        }
        var request = setRequest(serviceURL: url, httpMethod: "POST")
        do {
            let postBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = postBody
            let task = session.dataTask(with: request) { data, response, error in
                if let HTTPResponse = response as? HTTPURLResponse {
                    let statusCode = HTTPResponse.statusCode
                    if let data = data {
                        completionBlock(data, statusCode, error)
                        print("\n--------API Response-----\n", api)
                        print(String(data: data, encoding: .utf8) ?? "")
                    }
                }
            }
            task.resume()
        } catch {
            print(error)
        }
    }
}
