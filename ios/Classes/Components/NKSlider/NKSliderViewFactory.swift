import Flutter
import UIKit

/// Factory for creating NKSlider platform views (iOS 18.0+)
@available(iOS 18.0, *)
@objc public class NKSliderViewFactory: NSObject, FlutterPlatformViewFactory {
    private let registrar: FlutterPluginRegistrar

    @objc public init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
    }

    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        NKSliderPlatformView(
            frame: frame,
            viewId: viewId,
            arguments: args,
            registrar: registrar
        )
    }

    @objc public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }
}

// MARK: - Platform View

@available(iOS 18.0, *)
final class NKSliderPlatformView: NSObject, FlutterPlatformView {
    private let channel: FlutterMethodChannel
    private let container: UIView
    private let slider: UISlider
    private var step: Float?

    init(
        frame: CGRect,
        viewId: Int64,
        arguments args: Any?,
        registrar: FlutterPluginRegistrar
    ) {
        self.channel = FlutterMethodChannel(
            name: "native_kit/slider_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        self.container = UIView(frame: frame)
        self.slider = UISlider()
        super.init()

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }

        configure(with: args)
        setupSlider()
    }

    func view() -> UIView { container }

    private func configure(with args: Any?) {
        guard let arguments = args as? [String: Any] else { return }

        let min = (arguments["min"] as? Double) ?? 0.0
        let max = (arguments["max"] as? Double) ?? 1.0
        let value = (arguments["value"] as? Double) ?? min

        slider.minimumValue = Float(min)
        slider.maximumValue = Float(max)
        slider.value = Float(value)
        slider.isEnabled = arguments["enabled"] as? Bool ?? true

        applyStep(arguments)
        applyColors(arguments)

        if #available(iOS 26.0, *) {
            configureTrack(from: arguments)
        }
    }

    private func applyColors(_ arguments: [String: Any]) {
        slider.minimumTrackTintColor = nil
        slider.maximumTrackTintColor = nil
        slider.thumbTintColor = nil

        if let color = arguments["activeColor"] as? Int64 {
            slider.minimumTrackTintColor = UIColor.fromARGB(color)
        }
        if let color = arguments["inactiveColor"] as? Int64 {
            slider.maximumTrackTintColor = UIColor.fromARGB(color)
        }
        if let color = arguments["thumbColor"] as? Int64 {
            slider.thumbTintColor = UIColor.fromARGB(color)
        }
    }

    private func applyStep(_ arguments: [String: Any]) {
        if let stepValue = arguments["step"] as? Double {
            self.step = Float(stepValue)
        } else {
            self.step = nil
        }
    }

    private func setupSlider() {
        slider.translatesAutoresizingMaskIntoConstraints = false

        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderTouchUp), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderTouchUp), for: .touchUpOutside)

        container.addSubview(slider)
        NSLayoutConstraint.activate([
            slider.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            slider.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            slider.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])
    }

    private func snappedValue(_ value: Float) -> Float {
        guard let step = step, step > 0 else { return value }
        let min = slider.minimumValue
        return (((value - min) / step).rounded()) * step + min
    }

    @available(iOS 26.0, *)
    private func configureTrack(from arguments: [String: Any]) {
        // Parse ticks
        var trackConfig: UISlider.TrackConfiguration?
        if let ticksData = arguments["ticks"] as? [[String: Any]] {
            let ticks = ticksData.map { data -> UISlider.TrackConfiguration.Tick in
                let position = Float(data["position"] as? Double ?? 0.0)
                var tick = UISlider.TrackConfiguration.Tick(position: position)
                tick.title = data["title"] as? String
                if let iconDict = data["icon"] as? [String: Any],
                   let image = NKSymbolUtils.createImageFromSource(iconDict) {
                    tick.image = image
                }
                return tick
            }
            trackConfig = UISlider.TrackConfiguration(ticks: ticks)
        } else if let numberOfTicks = arguments["numberOfTicks"] as? Int {
            trackConfig = UISlider.TrackConfiguration(numberOfTicks: numberOfTicks)
        }

        if var config = trackConfig {
            config.allowsTickValuesOnly = arguments["allowsTickValuesOnly"] as? Bool ?? false
            if let neutral = arguments["neutralValue"] as? Double {
                config.neutralValue = Float(neutral)
            }
            if let enabledMin = arguments["enabledRangeMin"] as? Double,
               let enabledMax = arguments["enabledRangeMax"] as? Double {
                config.enabledRange = Float(enabledMin)...Float(enabledMax)
            }
            slider.trackConfiguration = config
        }
    }

    @objc private func sliderValueChanged() {
        let snapped = snappedValue(slider.value)
        if step != nil {
            slider.value = snapped
        }
        channel.invokeMethod("onValueChanged", arguments: Double(snapped))
    }

    @objc private func sliderTouchDown() {
        let snapped = snappedValue(slider.value)
        channel.invokeMethod("onChangeStart", arguments: Double(snapped))
    }

    @objc private func sliderTouchUp() {
        let snapped = snappedValue(slider.value)
        channel.invokeMethod("onChangeEnd", arguments: Double(snapped))
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Expected dictionary", details: nil))
            return
        }

        switch call.method {
        case "update":
            let min = Float(args["min"] as? Double ?? Double(slider.minimumValue))
            let max = Float(args["max"] as? Double ?? Double(slider.maximumValue))
            slider.minimumValue = min
            slider.maximumValue = max
            let value = Float(args["value"] as? Double ?? Double(slider.value))
            slider.setValue(snappedValue(value), animated: false)
            slider.isEnabled = args["enabled"] as? Bool ?? slider.isEnabled
            applyColors(args)
            applyStep(args)
            if #available(iOS 26.0, *) {
                configureTrack(from: args)
            }
            result(nil)

        case "setValue":
            let value = Float(args["value"] as? Double ?? 0.0)
            let animated = args["animated"] as? Bool ?? true
            let snapped = snappedValue(value)
            slider.setValue(snapped, animated: animated)
            result(nil)

        case "setEnabled":
            let enabled = args["enabled"] as? Bool ?? true
            slider.isEnabled = enabled
            result(nil)

        case "setRange":
            let min = Float(args["min"] as? Double ?? 0.0)
            let max = Float(args["max"] as? Double ?? 1.0)
            slider.minimumValue = min
            slider.maximumValue = max
            result(nil)

        case "setTrackConfiguration":
            if #available(iOS 26.0, *) {
                configureTrack(from: args)
            }
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
