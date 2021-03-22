import Foundation
import WebKit
import JustBridge

public class SeatsioWebView: WKWebView {
    var region: String?
    var bridge: JustBridge!
    var seatsioConfig: SeatingChartConfig?

    public init(frame: CGRect, region: String) {
        self.region = region
        super.init(frame: frame, configuration: WKWebViewConfiguration())
        bridge = JustBridge(with: self)
    }

    public init(frame: CGRect, region: String, seatsioConfig: SeatingChartConfig) {
        self.seatsioConfig = seatsioConfig
        super.init(frame: frame, configuration: WKWebViewConfiguration())
        bridge = JustBridge(with: self)
        loadSeatingChart()
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    public func reloadSeatingChart(config: SeatingChartConfig) {
        self.seatsioConfig = config
        loadSeatingChart()
    }

    private func loadSeatingChart() {
        guard let region = self.region else {
            print("Region parameter is nil.")
            return
        }

        let callbacks = self.buildCallbacksConfiguration().joined(separator: ",")
        let config = self.buildConfiguration()
                .dropLast()
                + "," + callbacks + "}";
        let htmlString = HTML
                .replacingOccurrences(of: "%configAsJs%", with: config)
                .replacingOccurrences(of: "%region%", with: region)
        self.loadHTMLString(htmlString, baseURL: nil)
    }

    private func buildConfiguration() -> String {
        guard let seatsioConfig = self.seatsioConfig else {
            print("Seatsio config is nil.")
            return ""
        }
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(seatsioConfig)
        return String(decoding: jsonData, as: UTF8.self)
    }

    private func buildCallbacksConfiguration() -> [String] {
        guard let seatsioConfig = self.seatsioConfig else {
            print("Seatsio config is nil.")
            return []
        }
        var callbacks = [String]()

        if (seatsioConfig.priceFormatter != nil) {
            bridge.register("priceFormatter") { (data, callback) in
                callback(seatsioConfig.priceFormatter!(decodeFloat(firstArg(data))))
            }
            callbacks.append(buildCallbackConfigAsJS("priceFormatter"))
        }

        if (seatsioConfig.onSelectionValid != nil) {
            bridge.register("onSelectionValid") { (data, callback) in
                seatsioConfig.onSelectionValid!()
            }
            callbacks.append(buildCallbackConfigAsJS("onSelectionValid"))
        }

        if (seatsioConfig.onSelectionInvalid != nil) {
            bridge.register("onSelectionInvalid") { (data, callback) in
                return seatsioConfig.onSelectionInvalid!(decodeSelectionValidatorTypes(firstArg(data)))
            }
            callbacks.append(buildCallbackConfigAsJS("onSelectionInvalid"))
        }

        if (seatsioConfig.onObjectSelected != nil) {
            bridge.register("onObjectSelected") { (data, callback) in
                seatsioConfig.onObjectSelected!(decodeSeatsioObject(firstArg(data)), decodeTicketType(secondArg(data)))
            }
            callbacks.append(buildCallbackConfigAsJS("onObjectSelected"))
        }

        if (seatsioConfig.onObjectDeselected != nil) {
            bridge.register("onObjectDeselected") { (data, callback) in
                seatsioConfig.onObjectDeselected!(decodeSeatsioObject(firstArg(data)), decodeTicketType(secondArg(data)))
            }
            callbacks.append(buildCallbackConfigAsJS("onObjectDeselected"))
        }

        if (seatsioConfig.onObjectClicked != nil) {
            bridge.register("onObjectClicked") { (data, callback) in
                seatsioConfig.onObjectClicked!(decodeSeatsioObject(firstArg(data)))
            }
            callbacks.append(buildCallbackConfigAsJS("onObjectClicked"))
        }

        if (seatsioConfig.onBestAvailableSelected != nil) {
            bridge.register("onBestAvailableSelected") { (data, callback) in
                seatsioConfig.onBestAvailableSelected!(decodeSeatsioObjects(firstArg(data)), decodeBool(secondArg(data)))
            }
            callbacks.append(buildCallbackConfigAsJS("onBestAvailableSelected"))
        }

        if (seatsioConfig.onBestAvailableSelectionFailed != nil) {
            bridge.register("onBestAvailableSelectionFailed") { (data, callback) in
                seatsioConfig.onBestAvailableSelectionFailed!()
            }
            callbacks.append(buildCallbackConfigAsJS("onBestAvailableSelectionFailed"))
        }

        if (seatsioConfig.onHoldSucceeded != nil) {
            bridge.register("onHoldSucceeded") { (data, callback) in
                seatsioConfig.onHoldSucceeded!(decodeSeatsioObjects(firstArg(data)), decodeTicketTypes(secondArg(data)))
            }
            callbacks.append(buildCallbackConfigAsJS("onHoldSucceeded"))
        }

        if (seatsioConfig.onHoldFailed != nil) {
            bridge.register("onHoldFailed") { (data, callback) in
                seatsioConfig.onHoldFailed!(decodeSeatsioObjects(firstArg(data)), decodeTicketTypes(secondArg(data)))
            }
            callbacks.append(buildCallbackConfigAsJS("onHoldFailed"))
        }

        if (seatsioConfig.onReleaseHoldSucceeded != nil) {
            bridge.register("onReleaseHoldSucceeded") { (data, callback) in
                seatsioConfig.onReleaseHoldSucceeded!(decodeSeatsioObjects(firstArg(data)), decodeTicketTypes(secondArg(data)))
            }
            callbacks.append(buildCallbackConfigAsJS("onReleaseHoldSucceeded"))
        }

        if (seatsioConfig.onReleaseHoldFailed != nil) {
            bridge.register("onReleaseHoldFailed") { (data, callback) in
                seatsioConfig.onReleaseHoldFailed!(decodeSeatsioObjects(firstArg(data)), decodeTicketTypes(secondArg(data)))
            }
            callbacks.append(buildCallbackConfigAsJS("onReleaseHoldFailed"))
        }

        if (seatsioConfig.onSelectedObjectBooked != nil) {
            bridge.register("onSelectedObjectBooked") { (data, callback) in
                seatsioConfig.onSelectedObjectBooked!(decodeSeatsioObject(firstArg(data)))
            }
            callbacks.append(buildCallbackConfigAsJS("onSelectedObjectBooked"))
        }

        if (seatsioConfig.tooltipInfo != nil) {
            bridge.register("tooltipInfo") { (data, callback) in
                callback(seatsioConfig.tooltipInfo!(decodeSeatsioObject(firstArg(data))))
            }
            callbacks.append(buildCallbackConfigAsJS("tooltipInfo"))
        }

        if (seatsioConfig.onChartRendered != nil) {
            bridge.register("onChartRendered") { (data, callback) in
                seatsioConfig.onChartRendered!(SeatingChart(self))
            }
            callbacks.append(buildCallbackConfigAsJS("onChartRendered"))
        }

        if (seatsioConfig.onChartRenderingFailed != nil) {
            bridge.register("onChartRenderingFailed") { (data, callback) in
                seatsioConfig.onChartRenderingFailed!()
            }
            callbacks.append(buildCallbackConfigAsJS("onChartRenderingFailed"))
        }

        return callbacks
    }

    private func buildCallbackConfigAsJS(_ name: String) -> String {
        return """
               \(name): (arg1, arg2) => (
                   new Promise((resolve, reject) => {
                       window.bridge.call("\(name)", [JSON.stringify(arg1), JSON.stringify(arg2)], data => resolve(data), error => reject(error))
                   })
               )
               """
    }

}

private func firstArg(_ data: Any?) -> Any {
    return (data as! [Any])[0]
}

private func secondArg(_ data: Any?) -> Any {
    return (data as! [Any])[1]
}

func decodeSeatsioObject(_ data: Any) -> SeatsioObject {
    let dataToDecode = (data as! String).data(using: .utf8)!
    return try! JSONDecoder().decode(SeatsioObject.self, from: dataToDecode)
}

func decodeSeatsioObjects(_ data: Any) -> [SeatsioObject] {
    let dataToDecode = (data as! String).data(using: .utf8)!
    return try! JSONDecoder().decode([SeatsioObject].self, from: dataToDecode)
}

func decodeCategories(_ data: Any) -> [Category] {
    let dataToDecode = (data as! String).data(using: .utf8)!
    return try! JSONDecoder().decode([Category].self, from: dataToDecode)
}

func decodeFloat(_ data: Any) -> Float {
    return (data as! NSString).floatValue
}

func decodeBool(_ data: Any) -> Bool {
    return (data as! NSString).boolValue
}

func decodeTicketType(_ data: Any) -> TicketType? {
    if (data is NSNull) {
        return nil
    }

    let dataAsString = data as! String

    if (dataAsString == "null") {
        return nil
    }

    let dataToDecode = dataAsString.data(using: .utf8)!
    return try! JSONDecoder().decode(TicketType.self, from: dataToDecode)
}

func decodeTicketTypes(_ data: Any) -> [TicketType]? {
    let dataToDecode = (data as! String).data(using: .utf8)!
    do {
        return try JSONDecoder().decode([TicketType].self, from: dataToDecode)
    } catch {
        return nil
    }
}

func decodeSelectionValidatorTypes(_ data: Any) -> [SelectionValidatorType] {
    let data = (data as! String).data(using: .utf8)
    return try! JSONDecoder().decode([SelectionValidatorType].self, from: data!)
}