import Foundation
import UIKit

public class TheTellerCheckout {
    var config: [String: Any]
    let tag = 2045
    // theteller api endpoints
        var LiveEndPoint: String = "https://checkout.theteller.net/initiate"
        var TestEndpoint: String = "https://test.theteller.net/checkout/initiate"
        
        // constructor
        public init(config: [String: Any]){
            self.config = config
        }

    // send http request
    private func showView(url : String,handleDone: ((_ json: [String: Any]?, _ error: Error?)->Void)?) {
        
        let vc = PopupModal(urlRequest: URL(string: url)!,redirectUrl: self.config["redirect_url"] as! String, finish: handleDone!)
            vc.tag = tag
            if let rootViewController = UIApplication.topViewController() {
                rootViewController.view.addSubview(vc)
            }
        }
    
    private func makeRequest (session: URLSession = URLSession.shared, request: URLRequest, closure: ((_ json: [String: Any]?, _ error: Error?)->Void)?) {
            let task = session.dataTask(with: request) { data, response,
                error in
                    let complete: (_ json: [String: Any]?, _ error: Error?) ->() = { json, error in DispatchQueue.main.async {
                        func callback(_ json: [String: Any]?, _ error: Error?) -> Void{
                            closure?(json, error)
                            self.closeModal()
                        }
                        if let checkout_url: String  = json!["checkout_url"] as? String {
                            self.showView(url: checkout_url, handleDone: callback)
                        }
                        else {
                            closure?(json, error)
                        }
                        }
                        
                }
                if let data = data {
                    do {
                        
                        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                            complete(json, error)
                             return
                        }
                        }
                }
                    complete(nil, error)
                
                }
            

            task.resume()
        }
        
        // send request to API to generate checkout url and token
        
        private func doCheckout(transId transaction_id: Int,amount: String, desc: String,customerEmail customer_email: String,paymentMethod: String?, paymentCurrency: String?,callback : ((_ json: [String: Any]?, _ error: Error?) -> Void)? = nil) {
            
            let basicAuth = String(format: "%@:%@", self.config["apiuser"] as! CVarArg, self.config["isProduction"] as AnyObject? === true as AnyObject ?self.config["API_Key_Prod"] as! CVarArg : self.config["API_Key_Test"] as! CVarArg).data(using: .utf8)?.base64EncodedString(options: .init(rawValue: 0))
            let endPoint = self.config["isProduction"] as AnyObject? === true as AnyObject ? self.LiveEndPoint : self.TestEndpoint

            let url = URL(string: "\(String(describing: endPoint))")
            var  request1 = URLRequest(url: url!,timeoutInterval: 60)
            request1.httpMethod = "POST"
            request1.allHTTPHeaderFields = [
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": "Basic " + basicAuth!
            ]
            
            var
            postData=["transaction_id":"\(transaction_id)","amount":amount,"desc":desc,"email":customer_email,"redirect_url":self.config["redirect_url"],"merchant_id":self.config["merchantID"]]
            if paymentCurrency != nil {
                postData["currency"] = paymentCurrency
            }
            if paymentCurrency != nil {
                           postData["payment_method"] = paymentMethod
                       }

            if let sdata  =  try? JSONSerialization.data(
            withJSONObject: postData,
            options: .prettyPrinted) {
            request1.httpBody=sdata
            request1.httpShouldHandleCookies=false
            self.makeRequest(request: request1,closure: callback)
            
            }
        }
        
        // initialize checkout
        public func initCheckout(transId transaction_id: Int, amount: String, desc: String,customerEmail customer_email: String, paymentMethod: String?, paymentCurrency: String?, callback : ((_ json: [String: Any]?, _ error: Error?) -> Void)? = nil){
            self.doCheckout(transId:transaction_id,amount:amount,desc:desc, customerEmail:customer_email,paymentMethod: paymentMethod,paymentCurrency: paymentCurrency,callback:callback)
        }
    func closeModal(){
       if let rootViewController = UIApplication.topViewController() {
            if let viewWithTag = rootViewController.view.viewWithTag(tag) {
                viewWithTag.removeFromSuperview()
            }
        }
        
    }
    
}
extension UIApplication {

    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController

            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
