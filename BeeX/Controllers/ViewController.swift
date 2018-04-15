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

class ViewController: AbstractController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var microphoneImageView: UIImageView!
    @IBOutlet weak var tapButton: UIButton!
    @IBOutlet weak var logoBTN: UIButton!
    
    var channel:AVAudioNodeBus = 1
    private var listening = false
  //  private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    var commands:[Command] = []
    var selectedCommand:Command?
    var timer:Timer?
    
    @IBOutlet weak var testTextFeild: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commandsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showSettingNavCloseButton = true
        // Initialize SFSpeechRecognizer
        
   //     speechRecognizer?.delegate = self
        
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // self.speechRecognizer = nil
     //   speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: AppConfig.langCode))
    //    print(speechRecognizer?.isAvailable)
      //  print(speechRecognizer?.locale)
        
    }
    override func settingButtonAction() {
    //    self.stopListening()
      //  self.speechRecognizer = nil
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
                        //   self.tapButton.isEnabled = false
                        self.stopListening()
                        
                        self.startListening()
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
        
       // self.restartSpeechTimer()
        
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
                    self.invoke(words: msg)
                }
                self.audioEngine.stop()
                inputNode.removeTap(onBus: self.channel)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.noteLabel.text = "Tap to listen"
                //self.stopListening()
                
            }  else if error == nil{

                self.restartSpeechTimer()

            }
            
            if error != nil{
            
                
                print(error?.localizedDescription)
                self.audioEngine.stop()
                inputNode.removeTap(onBus: self.channel)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.noteLabel.text = "Tap to listen"
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
        self.audioEngine.stop()
        self.recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: channel)
        audioEngine.outputNode.removeTap(onBus: channel)
        self.view.isUserInteractionEnabled = true
        self.recognitionRequest = nil
        self.recognitionTask = nil
    }
    
    
    
     @objc func restartSpeechTimer() {
        timer?.invalidate()
     //   self.listening = true
     //self.listening = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: { (timer) in
//            if let msg = self.noteLabel.text{
//                self.invoke(words: msg)
//            }
//            self.audioEngine.stop()
//            self.audioEngine.inputNode.removeTap(onBus: 0)
//
//            self.recognitionRequest = nil
//            self.recognitionTask = nil
//
//            self.noteLabel.text = "Tap to listen"
//            self.stopListening()
            
         
            
            
            if self.audioEngine.isRunning{
                self.endlistening()
            }
            
            })

    }

    func endlistening(){
        
     //   self.tapButton.isEnabled = true
        self.listening = false
        self.audioEngine.stop()
        self.recognitionRequest?.endAudio()
        //                    self.microphoneImageView.image = UIImage(named: "Microphone")
        self.logoBTN.isSelected = false
        self.showSettingNavCloseButton = true
        
    }
    
    
    @IBAction func send(_ sender: UIButton) {
        if let word = testTextFeild.text{
            invoke(words:word)
        }
    }
    
    
    func getWords(word:String)->String{
        let letters = CharacterSet.letters
        var str = ""
        for c in word.unicodeScalars{
            
            if letters.contains(c){
                str.append(Character(c))
            }else{
                str.append(",")
            }
            
        }
        
        return str
        
    }
    
    
    func invoke(words:String){
        
        if !words.isEmpty,let id = DataStore.shared.me?.UID{
            
            self.showActivityLoader(true)
            
            var wordsarr = getWords(word: words)
        
            
            
            var newWords = wordsarr;
            
//            for word in wordsarr {
//                newWords.append(word)
//                newWords.append(",")
//            }
                //words.replacingOccurrences(of: " ", with: ",").lowercased()
            ApiManager.shared.invoke(userId: id, words: newWords, completionBlock: { (success, error, result) in
                self.showActivityLoader(false)
                
                if success{
                    
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
                    self.showMessage(message: "Done".localized, type: .success)
                    guard let data = client.read(1024*10) else { return }
                    
                    if let response = String(bytes: data, encoding: .utf8) {
                        print(response)
                    }
                    case .failure(let error):
                    print(error)
                    }
                }
                
                
                
                guard let data = client.read(1024*10) else { return }
                
                if let response = String(bytes: data, encoding: .utf8) {
                    print(response)
                }
            case .failure(let error):
                print(error)
            }
            case .failure(let error):
                print(error)
            }
        }else{
            self.showMessage(message: "make sure to enter server and port in the setting", type: .error)
            
        }
        
    }
    
    
    private func sendRequest(string: String, using client: TCPClient) -> String? {
        
        
        switch client.send(string: string) {
        case .success:
            return readResponse(from: client)
        case .failure(let error):
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

