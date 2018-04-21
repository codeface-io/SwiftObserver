import UIKit
import PureLayout

public class ActivityIndicatorOverlay: UIView
{
    override public func layoutSubviews()
    {
        super.layoutSubviews()
        
        backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        layoutIndicator()
        indicator.startAnimating()
        
        layoutDescriptionLabel()
    }
    
    // MARK: - Indicator
    
    private func layoutIndicator()
    {
        indicator.autoCenterInSuperview()
    }
    
    private lazy var indicator: UIActivityIndicatorView =
    {
        let view = UIActivityIndicatorView.newAutoLayout()
        self.addSubview(view)
        
        return view
    }()
    
    // MARK: - Description Label
    
    private func layoutDescriptionLabel()
    {
        descriptionLabel.autoPinEdge(.top,
                                     to: .bottom,
                                     of: indicator,
                                     withOffset: 10)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .left)
        descriptionLabel.autoPinEdge(toSuperviewEdge: .right)
    }
    
    private lazy var descriptionLabel: UILabel =
    {
        let label = UILabel.newAutoLayout()
        self.addSubview(label)
        
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.white
        
        return label
    }()
}
