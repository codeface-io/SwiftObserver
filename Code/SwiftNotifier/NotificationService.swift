import SwiftyToolz

// MARK: - Sender Protocol

public protocol Sender
{
    func send(_ notification: String)
    func send(_ notification: String, parameters: JSON)
}

public extension Sender
{
    func send(_ notification: String)
    {
        notificationService.send(notification,
                                 from: self)
    }
    
    func send(_ notification: String, parameters: JSON)
    {
        notificationService.send(notification,
                                 from: self,
                                 parameters: parameters)
    }
}

// MARK: - Subscriber Protocol

public protocol Subscriber
{
    func subscribe(to notification: String, action: @escaping Action)
    func subscribe(to notification: String, action: @escaping (Any) -> Void)
    func subscribe(to notification: String, action: @escaping (Any, JSON?) -> Void)
    func subscribe(_ action: @escaping (String) -> Void)
    func subscribe(_ action: @escaping (String, Any) -> Void)
    func subscribe(_ action: @escaping (String, Any, JSON?) -> Void)
}

public extension Subscriber
{
    func subscribe(to notification: String,
                   action: @escaping Action)
    {
        notificationService.subscribe(to: notification, action: action)
    }
    
    func subscribe(to notification: String,
                   action: @escaping (Any) -> Void)
    {
        notificationService.subscribe(to: notification, action: action)
    }
    
    func subscribe(to notification: String,
                   action: @escaping (Any, JSON?) -> Void)
    {
        notificationService.subscribe(to: notification, action: action)
    }
    
    func subscribe(_ action: @escaping (String) -> Void)
    {
        notificationService.subscribe(action: action)
    }
    
    func subscribe(_ action: @escaping (String, Any) -> Void)
    {
        notificationService.subscribe(action: action)
    }
    
    func subscribe(_ action: @escaping (String, Any, JSON?) -> Void)
    {
        notificationService.subscribe(action: action)
    }
}

// MARK: - Notification Service Singleton

let notificationService = NotificationService()

class NotificationService
{
    fileprivate init() {}

    // MARK: Sending
    
    func send(_ notification: String,
              from sender: Any,
              parameters: JSON? = nil)
    {
        for action in universalActions
        {
            action.send(notification: notification,
                        from: sender,
                        parameters: parameters)
        }
        
        guard let actions = actionsByNotification[notification] else
        {
            return
        }
        
        for action in actions
        {
            action.send(notification: notification,
                        from: sender,
                        parameters: parameters)
        }
    }
    
    // MARK: Subscribing
    
    func subscribe(to notification: String, action: @escaping Action)
    {
        subscribe(SubscribedAction(with: action), to: notification)
    }
    
    func subscribe(to notification: String, action: @escaping (Any) -> Void)
    {
        subscribe(SubscribedAction(with: action), to: notification)
    }
    
    func subscribe(to notification: String, action: @escaping (Any, [String : Any]?) -> Void)
    {
        subscribe(SubscribedAction(with: action), to: notification)
    }
    
    func subscribe(action: @escaping (String) -> Void)
    {
        subscribe(SubscribedAction(with: action))
    }
    
    func subscribe(action: @escaping (String, Any) -> Void)
    {
        subscribe(SubscribedAction(with: action))
    }
    
    func subscribe(action: @escaping (String, Any, JSON?) -> Void)
    {
        subscribe(SubscribedAction(with: action))
    }
    
    private func subscribe(_ action: SubscribedAction,
                           to notification: String? = nil)
    {
        guard let notification = notification else
        {
            universalActions.append(action)
            return
        }
        
        if actionsByNotification[notification] == nil
        {
            actionsByNotification[notification] = [SubscribedAction]()
        }
        
        actionsByNotification[notification]?.append(action)
    }
    
    // MARK: Subscriptions
    
    private var actionsByNotification = [String : [SubscribedAction]]()
    private var universalActions = [SubscribedAction]()
}

// MARK: - Subscribed Actions

struct SubscribedAction
{
    init(with action: @escaping Action)
    {
        self.action = action
    }
    
    init(with action: @escaping (Any) -> Void)
    {
        actionWithAny = action
    }
    
    init(with action: @escaping (Any, JSON?) -> Void)
    {
        actionWithAnyAndJson = action
    }
    
    init(with action: @escaping (String) -> Void)
    {
        actionWithString = action
    }
    
    init(with action: @escaping (String, Any) -> Void)
    {
        actionWithStringAndAny = action
    }
    
    init(with action: @escaping (String, Any, JSON?) -> Void)
    {
        actionWithStringAndAnyAndJson = action
    }
    
    func send(notification: String,
              from sender: Any,
              parameters: JSON? = nil)
    {
        // notification based subscriptions
        if action != nil
        {
            action?()
        }
        else if actionWithAny != nil
        {
            actionWithAny?(sender)
        }
        else if actionWithAnyAndJson != nil
        {
            actionWithAnyAndJson?(sender, parameters)
        }
        // universal subscription
        else if actionWithString != nil
        {
            actionWithString?(notification)
        }
        else if actionWithStringAndAny != nil
        {
            actionWithStringAndAny?(notification, sender)
        }
        else if actionWithStringAndAnyAndJson != nil
        {
            actionWithStringAndAnyAndJson?(notification, sender, parameters)
        }
    }
    
    // for subscribing to one specific notification
    var action: Action?
    var actionWithAny: ((Any) -> Void)?
    var actionWithAnyAndJson: ((Any, JSON?) -> Void)?
    
    // for subscribing to all notifications (universal actions)
    var actionWithString: ((String) -> Void)?
    var actionWithStringAndAny: ((String, Any) -> Void)?
    var actionWithStringAndAnyAndJson: ((String, Any, JSON?) -> Void)?
}
