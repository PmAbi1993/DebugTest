import SwiftUI

struct NetCaptView: View {
    @State private var responseText = ""
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Network Capture Test")
                    .font(.title)
                    .padding()
                
                Text("Tap buttons to make API calls and see them logged by Debugger")
                    .multilineTextAlignment(.center)
                    .padding()
                
                VStack(spacing: 15) {
                    Button("API Call 1: GET Posts") {
                        makeAPICall(urlString: "https://jsonplaceholder.typicode.com/posts", method: "GET")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("API Call 2: POST User") {
                        makeAPICall(urlString: "https://reqres.in/api/users", method: "POST", body: ["name": "John Doe", "job": "Tester"])
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("API Call 3: GET GitHub Repo") {
                        makeAPICall(urlString: "https://api.github.com/repos/apple/swift", method: "GET")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("API Call 4: GET Random User") {
                        makeAPICall(urlString: "https://randomuser.me/api/", method: "GET")
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("API Call 5: GET HTTPBin") {
                        makeAPICall(urlString: "https://httpbin.org/get", method: "GET")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .disabled(isLoading)
                
                if isLoading {
                    ProgressView("Making API call...")
                }
                
                Text("Response:")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                
                ScrollView {
                    Text(responseText)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .frame(height: 300)
            }
            .padding()
        }
    }
    
    private func makeAPICall(urlString: String, method: String, body: [String: Any]? = nil) {
        guard let url = URL(string: urlString) else { return }
        
        isLoading = true
        responseText = ""
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body, method == "POST" {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.responseText = "Error: \(error.localizedDescription)"
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    self.responseText += "Status: \(httpResponse.statusCode)\n\n"
                }
                
                if let data = data {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        self.responseText += jsonString
                    } else {
                        self.responseText += "Received \(data.count) bytes of data"
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    NetCaptView()
}
