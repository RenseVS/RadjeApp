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
            }
        }.background(Color.black)
            .alert("Enter bar api", isPresented: $showingAlert) {
                TextField("Enter bar api adres", text: $api)
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
                                            boxText = "2🍺"
                                            boxColor = Color(forecast.color) }   }
                } catch {
                    print("Error decoding data: \(error.localizedDescription)")
                }
            }.resume()
        }
    
}

struct SpinResult: Codable{
    let color: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
