import SwiftUI

struct ContentView: View {
    @State private var spinningDone = true
    @State private var result = false
    @State private var timer: Timer?
        @State private var interval: TimeInterval = 0.1 // Initial interval of 1 second
    @State private var boxColor = Color.blue
    
    @State private var boxText = ""
    @State private var increment = 0.01
    @State private var showingAlert = false
    @State private var api = "0.0.0.0:0000"
    @State private var username = ""
    let impactMed = UIImpactFeedbackGenerator(style: .heavy)

    var body: some View {
        ZStack{
            Image("Background3")
                .resizable(resizingMode: .stretch)
                .aspectRatio(contentMode: .fill)
                        
            VStack {
                Rectangle()
                    .fill(boxColor)
                    .frame(width: 200, height: 200)
                    .border(Color.brown, width: 5).overlay(
                        Text(boxText)
                            .font(.system(size: 60))
                            .foregroundColor(.black)
                    )
                PowerView(spinningDone: spinningDone, action: startMainTimer, reset: reset, api: api)
                Button(action: {performPostRequest()}, label: {Text("Join Queue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.brown)
                        .cornerRadius(10)})
            }
        }.background(Color.black)
            .alert("Enter bar api", isPresented: $showingAlert) {
                TextField("Enter bar api adres", text: $api)
                TextField("Enter Username", text: $username)
                Button("OK", action: {showingAlert = false})
            }
            .onAppear{
                showingAlert = true;
            }
    }
    func reset(){
        boxText = ""
        interval = 0.1
        increment = 0.01
    }
    func startMainTimer(power: Int) {
        spinningDone = false
        boxText = ""
        Timer.scheduledTimer(withTimeInterval: TimeInterval(power), repeats: false) { timer in
            print(interval)
            interval = 2.0
            Switch()
        }
        startTimer()
        }

    func startTimer() {
        boxText = ""
        Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { timer in
            print(interval)
            increment += 0.001
            interval += increment
            Switch()
        }
        }
    
    func Switch() {
        if(interval >= 2.0 && result == false){
            result = true
            Result()
        }else if(result == false) {
            impactMed.impactOccurred()
            startTimer()
        switch boxColor {
        case Color.blue:
            boxColor = Color.red
        case Color.red:
            boxColor = Color.orange
        case Color.orange:
            boxColor = Color.blue
        default:
            boxColor = Color.blue
        }
        }
        // Perform your Switch() functionality here
        
    }
    
    func Result() {
        fetchData()
        // Perform your Result() functionality here
        print("Result() called")
    }
    
    func fetchData() {
        print("fetching...")
            guard let url = URL(string: "https://" + api + "/WeatherForecast/getresult") else {
                print("Invalid URL")
                return
            }
            
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.waitsForConnectivity = true
            
            let session = URLSession(configuration: sessionConfig, delegate: SSLCertificateDelegate(), delegateQueue: nil)
            
            session.dataTask(with: url) { (data, response, error) in
                guard let data = data else {
                    print("Error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                do {
                    print(data)
                    let decoder = JSONDecoder()
                                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                                    let forecast = try decoder.decode(SpinResult.self, from: data)
                                    DispatchQueue.main.async {
                                        if(forecast.color == ""){
                                            print("do the roar")
                                            fetchData()
                                        }else{
                                            impactMed.impactOccurred()
                                            spinningDone = true
                                            result = false
                                            boxText = forecast.prize
                                            boxColor = Color(forecast.color) }   }
                } catch {
                    print("Error decoding data: \(error.localizedDescription)")
                    fetchData()
                }
            }.resume()
        }
    
    
    func performPostRequest() {
            guard let url = URL(string: "https://" + api + "/WeatherForecast/AddToQueue") else {
                print("Invalid URL")
                return
            }
            
            struct RequestData: Codable {
                let UserName: String
                let DeviceID: String
            }
            
            let userName = username
            let deviceID = UIDevice.current.identifierForVendor?.uuidString ?? ""
            let requestData = RequestData(UserName: userName, DeviceID: deviceID)
            
            do {
                let jsonData = try JSONEncoder().encode(requestData)
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                
                let sessionConfig = URLSessionConfiguration.default
                sessionConfig.waitsForConnectivity = true
                
                let session = URLSession(configuration: sessionConfig, delegate: SSLCertificateDelegate(), delegateQueue: nil)
                
                session.dataTask(with: request) { data, response, error in
                    DispatchQueue.main.async {
                    }
                }.resume()
            } catch {
                print("Error encoding request data: \(error.localizedDescription)")
            }
        }
    
}

struct SpinResult: Codable{
    let color: String
    let prize: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
