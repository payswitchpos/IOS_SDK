# TheTellerCheckout - Swift for IOS

A Framework for calling TheTellerCheckout built on swift for IOS.

## Getting Started

- Add the the blug in to your project
    Right-click on the root KnobShowcase node in the project navigator. Click Add Files to “YOURPROJECTNAME”. In the file chooser, navigate to and select TheTellerCheckout.xcodeproj. Click Add to add TheTellerCheckout.xcodeproj as a sub-project.

Usage:
- import TheTellerCheckout
    ```swift
        import TheTellerCheckout
    ```
- initiate checkout
    ```swift
    let checkout = TheTellerCheckout(
        /* */
        data: [
                    "merchantID":"YOUR MERCHANT ID",
                    "API_Key_Prod" : "YOUR API PRODUCTION KEY",
                    "API_Key_Test" : "YOUR API TEST KEY",
                    "apiuser" : "YOUR API USER",
                    "redirect_url" : "YOUR REDIRECT URL",
                    "isProduction" :true /*  if true  "API_Key_Prod" will be used to initiate checkout, set it  to false during test  */
        ],VC: self)
        checkout.initCheckout(transId:121212213257, amount: "000000000010", desc: "Test transaction",customerEmail: "someone@gmail.com",paymentMethod: "momo", paymentCurrency: "GHS", callback: callback)
    ```
