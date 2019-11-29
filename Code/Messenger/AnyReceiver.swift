func key(_ receiver: AnyReceiver) -> ReceiverKey { ReceiverKey(receiver) }
typealias ReceiverKey = ObjectIdentifier
typealias AnyReceiver = AnyObject
