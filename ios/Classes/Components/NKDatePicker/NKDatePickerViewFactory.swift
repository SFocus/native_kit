import Flutter
import UIKit

/// Factory for creating NKDatePicker platform views (iOS 18.0+).
@available(iOS 18.0, *)
@objc public class NKDatePickerViewFactory: NSObject, FlutterPlatformViewFactory {
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
        NKDatePickerPlatformView(
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
final class NKDatePickerPlatformView: NSObject, FlutterPlatformView {
    private let channel: FlutterMethodChannel
    private let container: UIView
    private let datePicker: UIDatePicker

    init(
        frame: CGRect,
        viewId: Int64,
        arguments args: Any?,
        registrar: FlutterPluginRegistrar
    ) {
        self.channel = FlutterMethodChannel(
            name: "native_kit/date_picker_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        self.container = UIView(frame: frame)
        self.datePicker = UIDatePicker()
        super.init()

        datePicker.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: container.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        datePicker.addTarget(self, action: #selector(valueChanged), for: .valueChanged)

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }

        configure(with: args)

        if let arguments = args as? [String: Any],
           let isDark = arguments["isDark"] as? Bool {
            container.overrideUserInterfaceStyle = isDark ? .dark : .light
        }
    }

    func view() -> UIView { container }

    // MARK: - Configuration

    private func configure(with args: Any?) {
        guard let arguments = args as? [String: Any] else { return }
        applyParams(arguments)
    }

    private func applyParams(_ params: [String: Any]) {
        // Mode
        let modeName = params["mode"] as? String ?? "date"
        switch modeName {
        case "time":
            datePicker.datePickerMode = .time
        case "dateAndTime":
            datePicker.datePickerMode = .dateAndTime
        case "countdownTimer":
            datePicker.datePickerMode = .countDownTimer
        default:
            datePicker.datePickerMode = .date
        }

        // Style
        let styleName = params["style"] as? String ?? "inline"
        switch styleName {
        case "compact":
            datePicker.preferredDatePickerStyle = .compact
        case "wheels":
            datePicker.preferredDatePickerStyle = .wheels
        default:
            datePicker.preferredDatePickerStyle = .inline
        }

        // Initial date
        if let ms = params["initialDate"] as? Double {
            datePicker.date = Date(timeIntervalSince1970: ms / 1000.0)
        }

        // Min/max dates
        if let minMs = params["minimumDate"] as? Double {
            datePicker.minimumDate = Date(timeIntervalSince1970: minMs / 1000.0)
        }
        if let maxMs = params["maximumDate"] as? Double {
            datePicker.maximumDate = Date(timeIntervalSince1970: maxMs / 1000.0)
        }

        // Countdown duration
        if let seconds = params["countdownDuration"] as? Double {
            datePicker.countDownDuration = seconds
        }

        // Minute interval
        if let interval = params["minuteInterval"] as? Int {
            datePicker.minuteInterval = max(1, min(30, interval))
        }

        // Tint
        if let tint = params["tintColor"] as? Int64 {
            datePicker.tintColor = UIColor.fromARGB(tint)
        }
    }

    // MARK: - Actions

    @objc private func valueChanged() {
        if datePicker.datePickerMode == .countDownTimer {
            channel.invokeMethod("onCountdownChanged", arguments: datePicker.countDownDuration)
        } else {
            let ms = datePicker.date.timeIntervalSince1970 * 1000.0
            channel.invokeMethod("onDateChanged", arguments: ms)
        }
    }

    // MARK: - Method Channel Handler

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "update":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS",
                       message: "Expected dictionary", details: nil))
                return
            }
            applyParams(args)
            result(nil)
        case "setDate":
            guard let ms = call.arguments as? Double else {
                result(FlutterError(code: "INVALID_ARGS",
                       message: "Expected double (milliseconds)", details: nil))
                return
            }
            datePicker.setDate(
                Date(timeIntervalSince1970: ms / 1000.0),
                animated: true
            )
            result(nil)

        case "setBrightness":
            if let args = call.arguments as? [String: Any],
               let isDark = args["isDark"] as? Bool {
                container.overrideUserInterfaceStyle = isDark ? .dark : .light
            }
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
