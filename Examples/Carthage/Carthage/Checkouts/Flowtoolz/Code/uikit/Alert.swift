import UIKit

public class Alert: UIAlertController
{
    public func show()
    {
        self.alertWindow = UIWindow(frame: UIScreen.main.bounds)
        
        guard let alertWindow = self.alertWindow else
        {
            return
        }
        
        let presentingController = UIViewController()
        alertWindow.rootViewController = presentingController
        
        if let topWindow = UIApplication.shared.windows.last
        {
            alertWindow.windowLevel = topWindow.windowLevel + 1
        }
        
        alertWindow.makeKeyAndVisible()
        
        presentingController.present(self, animated: true, completion: nil)
    }
    
    public override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        alertWindow?.isHidden = true
        alertWindow = nil
    }
    
    private var alertWindow: UIWindow?
}
