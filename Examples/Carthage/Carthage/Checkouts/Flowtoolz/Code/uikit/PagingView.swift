import UIKit
import PureLayout

class PagingView: UIView, UIScrollViewDelegate
{
    // MARK: - Layout
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        layoutScrollView()
        layoutScrollContentView()
        layoutPageViews()
        layoutPageIndicator()
        
        bringSubview(toFront: pageIndicator)
    }
    
    // MARK: - Page Views
    
    func add(page: UIView)
    {
        scrollContentView.addSubview(page)
    }
    
    private func layoutPageViews()
    {
        let lastPageIndex = numberOfPages - 1
        
        guard lastPageIndex >= 0 else
        {
            return
        }
        
        for pageIndex in 0 ... lastPageIndex
        {
            let page = scrollContentView.subviews[pageIndex]
            
            page.autoPinEdge(toSuperviewEdge: .top)
            page.autoPinEdge(toSuperviewEdge: .bottom)
            
            if pageIndex > 0
            {
                let previousPage = scrollContentView.subviews[pageIndex - 1]
                
                page.autoPinEdge(.left, to: .right, of: previousPage)
                page.autoConstrainAttribute(.width, to: .width, of: previousPage)
            }
            else
            {
                page.autoPinEdge(toSuperviewEdge: .left)
            }
            
            if pageIndex == lastPageIndex
            {
                page.autoPinEdge(toSuperviewEdge: .right)
            }
        }
    }
    
    // MARK: - Navigation
    
    func scrollToNextPage()
    {
        guard pageIndicator.currentPage + 1 < numberOfPages else
        {
            return
        }
        
        var rect = scrollView.bounds
        rect.origin.x += rect.width
        
        scrollView.scrollRectToVisible(rect, animated: true)
    }
    
    var isOnLastPage: Bool
    {
        return pageIndicator.currentPage == numberOfPages - 1
    }
    
    // MARK: - Page Indicator
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView)
    {
        didScroll()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        didScroll()
    }
    
    private func didScroll()
    {
        guard numberOfPages > 0 else { return }
        
        let newPageIndex = pageIndex(fromScrollOffset: scrollView.contentOffset.x)
        
        if newPageIndex != pageIndicator.currentPage {
            pageIndicator.currentPage = newPageIndex
            delegate?.pagingViewDidTurnPage()
        }
    }
    
    var presentedView: UIView
    {
        return scrollContentView.subviews[pageIndicator.currentPage]
    }
    
    private func pageIndex(fromScrollOffset offset: CGFloat) -> Int
    {
        let pageWidth = scrollView.bounds.width
        
        return Int(offset / pageWidth)
    }
    
    private func layoutPageIndicator()
    {
        pageIndicator.numberOfPages = numberOfPages
        pageIndicator.autoAlignAxis(toSuperviewAxis: .vertical)
        pageIndicator.autoConstrainAttribute(.horizontal,
                                             to: .bottom,
                                             of: self,
                                             withMultiplier: relativeVerticalPositionOfPageIndicator)
    }
    
    var relativeVerticalPositionOfPageIndicator: CGFloat = 0.94
    
    lazy var pageIndicator: UIPageControl =
    {
        let indicator = UIPageControl.newAutoLayout()
        self.addSubview(indicator)
        
        indicator.currentPage = 0
        indicator.currentPageIndicatorTintColor = UIColor.white
        
        return indicator
    }()
    
    // MARK: - Scroll Content View
    
    private func layoutScrollContentView()
    {
        scrollContentView.autoConstrainAttribute(.width,
                                                 to: .width,
                                                 of: self,
                                                 withMultiplier: CGFloat(numberOfPages))
        scrollContentView.autoConstrainAttribute(.height,
                                                 to: .height,
                                                 of: scrollView,
                                                 withOffset: -0.2) // to disable vertical scrolling
        scrollContentView.autoPinEdge(toSuperviewEdge: .top)
        scrollContentView.autoPinEdge(toSuperviewEdge: .bottom)
        scrollContentView.autoConstrainAttribute(.leading, to: .leading, of: scrollView)
        scrollContentView.autoConstrainAttribute(.trailing, to: .trailing, of: scrollView)
    }
    
    private var numberOfPages: Int
    {
        return scrollContentView.subviews.count
    }
    
    lazy var scrollContentView: UIView =
    {
        let view = UIView.newAutoLayout()
        self.scrollView.addSubview(view)
        
        return view
    }()
    
    // MARK: - Scroll View
    
    private func layoutScrollView()
    {
        scrollView.autoPinEdgesToSuperviewEdges()
    }

    private lazy var scrollView: UIScrollView =
    {
        let view = UIScrollView.newAutoLayout()
        self.addSubview(view)
        
        view.delegate = self

        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        
        return view
    }()
    
    var delegate: PagingViewDelegate?
}

protocol PagingViewDelegate
{
    func pagingViewDidTurnPage()
}
