//
//  ViewController.swift
//  BeeX
//
//  Created by Nour  on 4/4/18.
//  Copyright © 2018 NourAraar. All rights reserved.
//

import UIKit
import Speech
import SwiftSocket
import AVFoundation

class ViewController: AbstractController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var microphoneImageView: UIImageView!
    @IBOutlet weak var tapButton: UIButton!
    @IBOutlet weak var logoBTN: UIButton!
    
    var bombSoundEffect: AVAudioPlayer?
    
    
    var channel:AVAudioNodeBus = 1
    private var listening = false
  //  private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    var commands:[Command] = []
    var selectedCommand:Command?
    var timer:Timer?
    var Stoptimer:Timer?
    @IBOutlet weak var testTextFeild: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commandsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showSettingNavCloseButton = true

        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func settingButtonAction() {
        self.performSegue(withIdentifier: "settingSegue", sender: nil)
    }
    
    
    @objc func tap(){
        
        askMicPermission(completion: { (granted, message) in
            DispatchQueue.main.async {
                if self.audioEngine.isRunning {
                    self.endlistening()
                    if granted {
                        self.stopListening()
                    }
                } else {
                    // Setup the text and start recording
                    
                    self.listening = true
                    //                    self.microphoneImageView.image = UIImage(named: "Microphone Filled")
                    self.logoBTN.isSelected = true
                    self.noteLabel.text = message
                    self.showSettingNavCloseButton = false
                    self.view.isUserInteractionEnabled = false
                    if granted {
                        self.tapButton.isEnabled = false
                    //    self.finalizeListening()
                        self.stopListening()
                        
                        self.startListening()
                        self.StopSpeechTimer()
                    }
                }
            }
        })
    }
    
    
    @IBAction func viewTapped(_ sender: Any) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(tap), object: nil)
        self.perform(#selector(tap), with: nil, afterDelay: 0.5)
        
       
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        tapButton.isEnabled = available
        if available {
            // Prepare to listen
            listening = true
            noteLabel.text = "Tap to listen"
            //viewTapped(tapButton)
        } else {
            noteLabel.text = "Recognition is not available."
        }
    }
    
    // MARK: - Private methods
    
    /**
     Check the status of Speech Recognizer authorization.
     - returns: A message, and if the access is granted.
     */
    private func askMicPermission(completion: @escaping (Bool, String) -> ()) {
        SFSpeechRecognizer.requestAuthorization { status in
            let message: String
            var granted = false
            
            switch status {
            case .authorized:
                message = "Listening..."
                granted = true
                break
                
            case .denied:
                message = "Access to speech recognition is denied by the user."
                break
                
            case .restricted:
                message = "Speech recognition is restricted."
                break
                
            case .notDetermined:
                message = "Speech recognition has not been authorized yet."
                break
            }
            
            completion(granted, message)
        }
    }
    
    /**
     Start listening to audio and try to convert it to text
     */
    private func startListening() {
        
        // Clear existing tasks
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // Start audio session
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
         //   try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            noteLabel.text = "An error occurred when starting audio session."
            return
        }
        
        // Request speech recognition
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
     
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let  speechRec = SFSpeechRecognizer(locale: Locale.init(identifier: AppConfig.langCode))
        speechRec?.delegate = self
        
        
        recognitionTask = speechRec?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                print(result?.bestTranscription.formattedString)
                self.noteLabel.text = result?.bestTranscription.formattedString
                print(result!.isFinal)
                isFinal = result!.isFinal
            }
            
            
            if isFinal {
                
                if let msg = result?.bestTranscription.formattedString{
                    self.finalizeListening()
                    self.invoke(words: msg)
                }else{
                    
                    self.finalizeListening()
                }
            
                //self.stopListening()
                
            }  else if error == nil{
                
                self.restartSpeechTimer()

            }
            
            if error != nil || self.listening == false{
          //      self.playErrorSound()
                
                print(error?.localizedDescription)
//                self.audioEngine.stop()
//                inputNode.removeTap(onBus: self.channel)
//
//                self.recognitionRequest = nil
//                self.recognitionTask = nil
//
//                self.noteLabel.text = "Tap to listen"
             //   self.channel += 1
                self.finalizeListening()
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: channel)
    
            if self.recognitionRequest != nil{
            inputNode.installTap(onBus: self.channel, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
                self.recognitionRequest?.append(buffer)
                }
                
            }
            
    
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            noteLabel.text = "An error occurred starting audio engine"
        }
    }
    
    /**
     Stop listening to audio and speech recognition
     */
    private func stopListening() {
        
        audioEngine.inputNode.removeTap(onBus: channel)
        audioEngine.inputNode.reset()
        self.audioEngine.stop()
        self.recognitionRequest?.endAudio()
        self.recognitionTask?.cancel()
        self.recognitionRequest = nil
        self.recognitionTask = nil
        
        self.tapButton.isEnabled = true
        
        

//        audioEngine.outputNode.removeTap(onBus: channel)
        self.view.isUserInteractionEnabled = true
      
        
        
        /*
         
         [inputNode removeTapOnBus:0];
         [inputNode reset];
         [audioEngine stop];
         [recognitionRequest endAudio];
         [recognitionTask cancel];
         recognitionTask = nil;
         recognitionRequest = nil;
         
         */
    }
    
    
    
     @objc func restartSpeechTimer() {
        timer?.invalidate()
        Stoptimer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (timer) in

            if self.audioEngine.isRunning{
                self.endlistening()
            }
            
            })

    }
    
    
    @objc func StopSpeechTimer() {
        Stoptimer?.invalidate()
        Stoptimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
            
            if self.audioEngine.isRunning{
                self.endlistening()
            }
            
        })
        
    }

    func endlistening(){
        timer?.invalidate()
        Stoptimer?.invalidate()
        self.tapButton.isEnabled = true
        self.listening = false
        self.audioEngine.stop()
        self.audioEngine.inputNode.removeTap(onBus: self.channel)
        self.recognitionRequest?.endAudio()
        //                    self.microphoneImageView.image = UIImage(named: "Microphone")
     //   self.logoBTN.isSelected = false
        self.showSettingNavCloseButton = true
        
    }
    
    
    
    
    func finalizeListening(){
        
        timer?.invalidate()
        Stoptimer?.invalidate()
        self.logoBTN.isSelected = false
        self.audioEngine.stop()
        self.audioEngine.inputNode.removeTap(onBus: self.channel)
        self.recognitionRequest = nil
        self.recognitionTask = nil
        
        self.noteLabel.text = "Tap to listen"
        
    }
    
    
    @IBAction func send(_ sender: UIButton) {
        if let word = testTextFeild.text{
            invoke(words:word)
        }
    }
    
    
    func playOkSound(){
        let path = Bundle.main.path(forResource: "ok.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)

        do {
            bombSoundEffect = try AVAudioPlayer(contentsOf: url)
            bombSoundEffect?.setVolume(50, fadeDuration: 0)
            bombSoundEffect?.play()
        } catch {
            // couldn't load file :(
        }

        
    }
    
    func playErrorSound(){
        let path = Bundle.main.path(forResource: "error.mp3", ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            bombSoundEffect = try AVAudioPlayer(contentsOf: url)
            bombSoundEffect?.setVolume(50, fadeDuration: 0)
            bombSoundEffect?.play()
        } catch {
            // couldn't load file :(
        }
        
        
    }
    
    
    func getWords(word:String)->String{
        let letters = CharacterSet.letters
        var str = ""
        var ok = false
        for c in word.unicodeScalars{
            
            if letters.contains(c){
                ok = true
                str.append(Character(c))
            }else if ok{
                str.append(",")
            }
            
        }
//        if str.length > 0{
//        let endIndex = str.index(str.endIndex, offsetBy: -1)
//        str = str.substring(to: endIndex)
//
//        }
        return str
        
    }
    
    
    func invoke(words:String){
        
        if !words.isEmpty,let id = DataStore.shared.me?.UID{
            self.tapButton.isEnabled = false
            self.showActivityLoader(true)
            
            let wordsarr = getWords(word: words)
    
            let newWords = wordsarr;
            
            ApiManager.shared.invoke(userId: id, words: newWords, completionBlock: { (success, error, result) in
                self.tapButton.isEnabled = true
                self.showActivityLoader(false)
                self.finalizeListening()
                if success{
                    //self.playOkSound()
                    self.commands = result
                    if result.count == 1{
                        self.selectedCommand = result[0]
                        self.telnet(command: self.selectedCommand!)
                    }else if result.count > 1 {
                        self.showCommnadsView()
                        self.tableView.reloadData()
                    }
                }
                
                if error != nil{
                    self.playErrorSound()
                    if let msg = error?.message {
                        self.showMessage(message: msg, type: .error)
                        
                    }
                }
                
            })
            
            
            
        }

    }
    
    func showCommnadsView(){
        self.commandsView.isHidden = false
        self.commandsView.animateIn(mode: .animateInFromBottom, delay: 0.2)
    }
    
    func hideCommandView(){
        self.commandsView.animateIn(mode: .animateOutToBottom, delay: 0.2)
        self.commandsView.isHidden = true
    }
    
    func telnet(command:Command){
        print("start")
        print(command.command)
        if let server = AppConfig.server,let value = AppConfig.port,let port = Int32(value){
        let client = TCPClient(address: server, port: port)
        
        switch client.connect(timeout: 10) {
            
        case .success:
            switch client.send(string: "en:*\r\n" ) {
            
            case .success:
                if let order = command.command{
                switch client.send(string: "set:\(order)\r\n" ) {
                   case .success:
                    print("ok")
                    self.playOkSound()
                    self.showMessage(message: "Done".localized, type: .success)
                    guard let data = client.read(1024*10) else { return }
                    
                    if let response = String(bytes: data, encoding: .utf8) {
                        print(response)
                    }
                    case .failure(let error):
                        self.playErrorSound()
                        self.showMessage(message: error.localizedDescription, type: .error)
                    }
                }
                
                
                
                guard let data = client.read(1024*10) else { return }
                
                if let response = String(bytes: data, encoding: .utf8) {
                    print(response)
                }
            case .failure(let error):
                self.playErrorSound()
                self.showMessage(message: error.localizedDescription, type: .error)
            }
            case .failure(let error):
                self.playErrorSound()
                self.showMessage(message: error.localizedDescription, type: .error)
            }
        }else{
            self.playErrorSound()
            self.showMessage(message: "make sure to enter server and port in the setting", type: .error)
            
        }
        
    }
    
    
    private func sendRequest(string: String, using client: TCPClient) -> String? {
        
        
        switch client.send(string: string) {
        case .success:
            return readResponse(from: client)
        case .failure(let error):
            self.playErrorSound()
           print(error)
            return nil
        }
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10) else { return nil }
        
        return String(bytes: response, encoding: .utf8)
    }
    
    
    
    @IBAction func cancel(_ sender: UIButton) {
        hideCommandView()
    }
    
}


extension ViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commands.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text  = self.commands[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCommand = self.commands[indexPath.row]
        hideCommandView()
        telnet(command: selectedCommand!)
    }
}

