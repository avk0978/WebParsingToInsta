//
//  WebBrowser.swift
//  WebParsingToInsta
//
//  Created by Andrey Kolpakov on 17.08.2018.
//  Copyright © 2018 Andrey Kolpakov. All rights reserved.
//

import UIKit
import WebKit

public var downloadLink = ""

class WebBrowser: UIViewController, CoreDataMethods {
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
 
    let selectButton: UIButton = {
        var button = UIButton(type: UIButton.ButtonType.system)
        button = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        button.layer.cornerRadius = 0.5 * button.bounds.width
        button.layer.borderWidth = 10
        button.layer.borderColor = #colorLiteral(red: 0, green: 0.8365168571, blue: 0.006623513065, alpha: 1)
        button.backgroundColor = .clear
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var bottomConstraint: NSLayoutConstraint!
    private var centerXConstraint: NSLayoutConstraint!
    private var rightConstraint: NSLayoutConstraint!
    private var centerYConstraint: NSLayoutConstraint!
    private var orientation: CGFloat!
    
    private var togglePopoverVC = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlTextField.delegate = self
        webView.navigationDelegate = self
        setSelectButton()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loadSiteByDownloadLink),
                                               name: Notification.Name("loadSiteByDownloadLink"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(activePopoverVC),
                                               name: Notification.Name("PopMenuOpen"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deactivatePopoverVC),
                                               name: Notification.Name("PopMenuClose"),
                                               object: nil)
    }
    
    @objc func loadSiteByDownloadLink() {
        loadSiteAt(http: downloadLink)
        urlTextField.text = downloadLink
    }
    
    @objc func activePopoverVC() {
        togglePopoverVC = true
    }
    
    @objc func deactivatePopoverVC() {
        togglePopoverVC = false
    }
    
    func setSelectButton() {
        bottomConstraint = selectButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        centerXConstraint =  selectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        rightConstraint = selectButton.rightAnchor.constraint(equalTo: view.rightAnchor)
        centerYConstraint = selectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        
        view.addSubview(selectButton)
        selectButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
        selectButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        selectButton.addTarget(self, action: #selector(didTapSelectButton), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Локализация текстовых сообщений
//        let enterTheAddressOfSite: String = NSLocalizedString("Enter the address of site", comment: "")
//        let siteAddressWithImages: String = NSLocalizedString("Site address with images", comment: "")
//        let nameOfTheSite: String = NSLocalizedString("Name of the site", comment: "")
//        let ok: String = NSLocalizedString("OK", comment: "")
        
        guard let entitiesSiteIsEmpty = entitiesSitesIsEmpty() else { return }
        
        if entitiesSiteIsEmpty {
            let defaultSiteName = "http://parsingforinsta.kv.in.ua/"
            self.loadSiteAt(http: defaultSiteName)
            self.addSiteNameToEntitiesSites(name: defaultSiteName, link: defaultSiteName, isActive: true)

//            let ac = UIAlertController(title: nil, message: enterTheAddressOfSite, preferredStyle: .alert)
//            ac.addTextField { (textField: UITextField!) in
//                textField.placeholder = siteAddressWithImages
//            }
//            ac.addTextField { (textField: UITextField!) in
//                textField.placeholder = nameOfTheSite
//            }
//
//            let oK = UIAlertAction(title: ok, style: .default) { (action) in
//                let siteLink = ac.textFields![0] as UITextField
//                let siteName = ac.textFields![1] as UITextField
//                if siteLink.text == "" { siteLink.text = "http://parsingforinsta.kv.in.ua/" }
//                if siteName.text == "" {siteName.text = siteLink.text}
//                self.loadSiteAt(http: siteLink.text!)
//                self.addSiteNameToEntitiesSites(name: siteName.text!, link: siteLink.text!, isActive: true)
//            }
//            ac.addAction(oK)
//            present(ac, animated: true)
        } else {
            let siteLink = fetchSiteLink()
            loadSiteAt(http: siteLink)
            urlTextField.text = siteLink
        }
    }

    override func viewDidLayoutSubviews() {
        
        if togglePopoverVC {
            NotificationCenter.default.post(name: NSNotification.Name("closePopopverVC"), object: nil)
        }
        
        orientation = view.bounds.size.height / view.bounds.size.width // >1 - портрет, <1 - альбом
        if orientation > 1 {
            view.removeConstraints([bottomConstraint, centerXConstraint, rightConstraint, centerYConstraint])
            view.addConstraints([bottomConstraint, centerXConstraint])
        } else {
            view.removeConstraints([bottomConstraint, centerXConstraint, rightConstraint, centerYConstraint])
            view.addConstraints([rightConstraint, centerYConstraint])
        }
    }
    
    func loadSiteAt(http: String) {
        guard let url = URL(string: http) else { return }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                guard let _ = data, let _ = response, error == nil else {
                    self.present(ErrorManager.noСonnectionToSite(), animated: true)
                    self.activityIndicator.stopAnimating()
                    return
                }
                self.webView.load(request)
            }
            }.resume()
    }
    
    
    @IBAction func backButton(_ sender: UIButton) {
        if webView.canGoBack {
            webView.goBack()
        }
        
    }

    @IBAction func forwardButton(_ sender: UIButton) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @objc func didTapSelectButton() {
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popTVC") as? PopMenuTVC else { return }
        NotificationCenter.default.post(name: NSNotification.Name("PopMenuOpen"), object: nil)
        
        selectButton.layer.borderColor = #colorLiteral(red: 0.7803921569, green: 0.8705882353, blue: 0.6509803922, alpha: 1)
        popVC.delegateChangeColor = self    // Подписываемся под протоколом делегирования
        popVC.url = urlTextField.text!      // Передаем адрес сайта в Popover TVC
        
        popVC.modalPresentationStyle = .popover
        
        let pop = popVC.popoverPresentationController
        pop?.delegate = self
        pop?.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        pop?.sourceView = selectButton
        preferredContentSize = CGSize(width: 300, height: 225)
        if orientation > 1 {
            pop?.sourceRect = CGRect(x: selectButton.bounds.midX,
                                     y: selectButton.bounds.minY,
                                     width: 0,
                                     height: 0)
        } else {
            pop?.sourceRect = CGRect(x: 0,
                                     y: selectButton.bounds.midY,
                                     width: 0,
                                     height: 0)
            
        }
        present(popVC, animated: true)
    }
    
}

extension WebBrowser: UITextFieldDelegate, WKNavigationDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let urlString = textField.text, let url = URL(string: urlString) else { return false}

        let request = URLRequest(url: url)
        webView.load(request)
        textField.resignFirstResponder()

        return true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { // Добавить тайм аут для selectButton!!!!!!

        urlTextField.text = webView.url?.absoluteString

        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
        selectButton.isHidden = false
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        activityIndicator.startAnimating()
        selectButton.isHidden = true
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        activityIndicator.stopAnimating()
        if urlTextField.text?.isEmpty == false {
            selectButton.isHidden = false
        }
    }

}

extension WebBrowser: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
}

// Изменение цвета кнопки SelectButton после закрытия PopoverVC через делегирование
extension WebBrowser: ChangeSelectButtonColorDelegate {
    func changeSelectButtonColor() {
        selectButton.layer.borderColor = #colorLiteral(red: 0, green: 0.8365168571, blue: 0.006623513065, alpha: 1)
    }
    
}
