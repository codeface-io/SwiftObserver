import UIKit
import PureLayout

class BottomLineTextField: UITextField
{
    // MARK: - Layout
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        layoutBottomLine()
    }
    
    // MARK: - Bottom Line
    
    private func layoutBottomLine()
    {
        bottomLine.autoPinEdge(toSuperviewEdge: .left)
        bottomLine.autoPinEdge(toSuperviewEdge: .right)
        bottomLine.autoSetDimension(.height, toSize: 1.0)
        bottomLine.autoAlignAxis(.baseline, toSameAxisOf: self, withOffset: 8)
    }
    
    override var textColor: UIColor?
    {
        didSet
        {
            bottomLine.backgroundColor = textColor
        }
    }
    
    lazy var bottomLine: UIView =
    {
        let view = UIView.newAutoLayout()
        self.addSubview(view)
        
        view.backgroundColor = self.textColor
        
        return view
    }()
}
