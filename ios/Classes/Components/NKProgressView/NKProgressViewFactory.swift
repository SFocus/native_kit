import Flutter
import UIKit

/// Factory for creating NKProgressView platform views (iOS 18.0+).
@available(iOS 18.0, *)
@objc public class NKProgressViewFactory: NSObject, FlutterPlatformViewFactory {
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
        NKProgressViewPlatformView(
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
final class NKProgressViewPlatformView: NSObject, FlutterPlatformView {
    private let channel: FlutterMethodChannel
    private let container: UIView
    private var currentView: UIView?
    private var currentStyle: String = "bar"

    init(
        frame: CGRect,
        viewId: Int64,
        arguments args: Any?,
        registrar: FlutterPluginRegistrar
    ) {
        self.channel = FlutterMethodChannel(
            name: "native_kit/progress_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        self.container = UIView(frame: frame)
        super.init()

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }

        configure(with: args)
    }

    func view() -> UIView { container }

    // MARK: - Configuration

    private func configure(with args: Any?) {
        guard let arguments = args as? [String: Any] else { return }
        applyParams(arguments)
    }

    private func applyParams(_ params: [String: Any]) {
        let style = params["style"] as? String ?? "bar"

        // Rebuild view if style changed
        if style != currentStyle || currentView == nil {
            currentView?.removeFromSuperview()
            currentStyle = style

            if style == "spinner" {
                let spinner = createSpinner(params)
                container.addSubview(spinner)
                constrainToContainer(spinner)
                currentView = spinner
            } else {
                let bar = createProgressBar(params)
                container.addSubview(bar)
                constrainToContainer(bar)
                currentView = bar
            }
        } else {
            // Update existing view
            if style == "spinner" {
                updateSpinner(params)
            } else {
                updateProgressBar(params)
            }
        }
    }

    // MARK: - Progress Bar

    private func createProgressBar(_ params: [String: Any]) -> UIProgressView {
        let bar = UIProgressView(progressViewStyle: .default)
        bar.translatesAutoresizingMaskIntoConstraints = false

        let value = params["value"] as? Double ?? 0.0
        bar.progress = Float(value)

        if let tint = params["tintColor"] as? Int64 {
            bar.progressTintColor = UIColor.fromARGB(tint)
        }
        if let track = params["trackColor"] as? Int64 {
            bar.trackTintColor = UIColor.fromARGB(track)
        }

        applyCornerRadius(to: bar, params: params)

        return bar
    }

    private func updateProgressBar(_ params: [String: Any]) {
        guard let bar = currentView as? UIProgressView else { return }

        let value = params["value"] as? Double ?? 0.0
        bar.setProgress(Float(value), animated: true)

        if let tint = params["tintColor"] as? Int64 {
            bar.progressTintColor = UIColor.fromARGB(tint)
        }
        if let track = params["trackColor"] as? Int64 {
            bar.trackTintColor = UIColor.fromARGB(track)
        }

        applyCornerRadius(to: bar, params: params)
    }

    private func applyCornerRadius(to bar: UIProgressView, params: [String: Any]) {
        if let cornerRadius = params["cornerRadius"] as? CGFloat {
            bar.layer.cornerRadius = cornerRadius
            bar.clipsToBounds = true
            bar.subviews.forEach {
                $0.layer.cornerRadius = cornerRadius
                $0.clipsToBounds = true
            }
        }
    }

    // MARK: - Spinner

    private func createSpinner(_ params: [String: Any]) -> UIActivityIndicatorView {
        let size = spinnerStyle(from: params["spinnerSize"] as? String)
        let spinner = UIActivityIndicatorView(style: size)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = false

        if let tint = params["tintColor"] as? Int64 {
            spinner.color = UIColor.fromARGB(tint)
        }

        spinner.startAnimating()
        return spinner
    }

    private func updateSpinner(_ params: [String: Any]) {
        guard let spinner = currentView as? UIActivityIndicatorView else { return }

        if let tint = params["tintColor"] as? Int64 {
            spinner.color = UIColor.fromARGB(tint)
        }

        // Size change requires rebuilding the spinner
        let newStyle = spinnerStyle(from: params["spinnerSize"] as? String)
        if spinner.style != newStyle {
            spinner.removeFromSuperview()
            let newSpinner = createSpinner(params)
            container.addSubview(newSpinner)
            constrainToContainer(newSpinner)
            currentView = newSpinner
        }
    }

    private func spinnerStyle(from name: String?) -> UIActivityIndicatorView.Style {
        switch name {
        case "large": return .large
        case "small": return .medium // iOS medium ≈ our small (20pt)
        default: return .medium
        }
    }

    // MARK: - Layout

    private func constrainToContainer(_ subview: UIView) {
        NSLayoutConstraint.activate([
            subview.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            subview.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        ])

        // For progress bar, match container width
        if subview is UIProgressView {
            NSLayoutConstraint.activate([
                subview.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                subview.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            ])
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
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
