import UIKit

public let alertPresenter = AlertPresenter()

public class AlertPresenter
{
    fileprivate init() {}
    
    func present(title: String, text: String)
    {
        let alert = Alert(title: title,
                          message: text,
                          preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default)
        {
            action in
            
        }
        
        alert.addAction(okAction)
        
        DispatchQueue.main.async
        {
            alert.show()
        }
    }
}
