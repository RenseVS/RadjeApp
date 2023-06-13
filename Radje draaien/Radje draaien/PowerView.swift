import SwiftUI
import CoreMotion

struct PowerView: View {
    var spinningDone: Bool
    let action: (Int) -> Void
    let reset: () -> Void
    var api: String
    @State private var MeasureMovement = false
    @State private var isMovingDownward = false
    @State private var text = "Make a spinning motion"
    private let motionManager = CMMotionManager()
    
    var body: some View {
        VStack{
            if(MeasureMovement == true){
                Text(text)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.brown)
                    .cornerRadius(10)
                    .onAppear {
                        motion2()
                    }
            }
            else if(spinningDone == true && MeasureMovement == false){
                Button(action: {
                            MeasureMovement = true
                    reset()
                        }) {
                            Text("Tap to start")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.brown)
                                .cornerRadius(10)
                        }
            }
            else if (spinningDone == false && MeasureMovement == false){
                Text("Spinning....")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.brown)
                    .cornerRadius(10)
            }
        }
    }
    
    func startDeviceMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else {
            print("Device motion is not available")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = 0.1  // Update interval in seconds
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { motion, error in
            if let motion = motion {
                let gravity = motion.gravity
                // Check if the device is moving downward
                if gravity.x < -0.8 || gravity.x > 0.8 {
                    stopDeviceMotionUpdates()
                    MeasureMovement = false
                    fetchData(power: 1)
                    action(Int.random(in: 60...100))
                }
            }
        }
    }
    
    func motion2(){
        text = "Make a spinning motion"
        motionManager.accelerometerUpdateInterval = 0.1 // Update interval in seconds
        motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
            guard let accelerometerData = data else {
                // Error occurred or data is unavailable
                return
            }
            
            let acceleration = accelerometerData.acceleration
            let magnitude = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2))

            if(magnitude > 4 && magnitude < 8){
                text = "Spin harder!"
            }
            if magnitude > 8{
                print("Speed")
                print(Int(magnitude))
                stopDeviceMotionUpdates()
                MeasureMovement = false
                fetchData(power: Int(magnitude))
                action(Int(magnitude))
            }
        }
    }
    
    func stopDeviceMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
        motionManager.stopAccelerometerUpdates()
    }
    
    func fetchData(power: Int) {
            guard let url = URL(string: "https://" + api + "/WeatherForecast/" + String(power)) else {
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
                    DispatchQueue.main.async {
                    }
                } catch {
                    print("Error decoding data: \(error.localizedDescription)")
                }
            }.resume()
        }
    }

class SSLCertificateDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
}
