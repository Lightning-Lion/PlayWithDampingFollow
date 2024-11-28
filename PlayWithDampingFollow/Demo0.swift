import SwiftUI
import RealityKit
import RealityKitContent
import DampingFollow

struct Demo0ImmersiveView: View {
    private
    let floatingPanelId:UUID = UUID()
    @State
    private var followManager = FollowManager()
    
    public
    var body: some View {
        RealityView { realityViewContent, attachments in
            if let floatingPanelEntity:ViewAttachmentEntity = attachments.entity(for: floatingPanelId) {
                floatingPanelEntity
                    .components[DampingFollowComponent.self] = DampingFollowComponent(direction: [-0.3,-0.2,-1])
                realityViewContent.add(floatingPanelEntity)
            }
        } attachments: {
            Attachment(id: floatingPanelId) {
                SpeedGauge()
            }
        }
        .modifier(EnableDampingFollow())
    }
}

//提供速度表的示例
//无障碍适配是不是仍然存在问题？
struct FloatingView: View {
    var body: some View {
        Text("欢迎使用我们的App👏")
            .font(.largeTitle)
            .minimumScaleFactor(0.1)
            .scaledToFit()
            .padding(30)
            .glassBackgroundEffect()//注意需要使用glassBackgroundEffect，不然没有底色
        //注意需要提供确定的尺寸，因为窗口尺寸是不支持被用户拖曳调整的
            .frame(width: 300, height: 100, alignment: .center)
    }
}

struct SpeedGauge: View {
    @State
    var currentSpeed = 5.0
    @State
    private var speedUpdateTimer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    var body: some View {
        Gauge(value: currentSpeed, in: 0...10) {} currentValueLabel: {
            VStack {
                Text(currentSpeed.formatted(.number.precision(.fractionLength(1))))
                    .contentTransition(.numericText(value: currentSpeed))
            }
        }
        .gaugeStyle(AccessoryCircularGaugeStyle {
            Text("m/s")
                .font(.system(size: 45))
        })
        .padding(22)
        // Note: You need to use glassBackgroundEffect, otherwise there will be no background.
        .glassBackgroundEffect(in: .circle)
        .onReceive(speedUpdateTimer) { _ in
            fetchNewSpeed()
        }
    }
    private
    func fetchNewSpeed() {
        withAnimation(.easeInOut(duration: 1)) {
            currentSpeed = Double.random(in: 0...10)
        }
    }
}


/// The `GaugeStyle` of the `OverallView`.
/// https://medium.com/@giulio.caggegi/swiftui-gauge-view-7225d7247ca0
struct AccessoryCircularGaugeStyle<Content: View>: GaugeStyle {
  // MARK: - Properties
  
  /// The `View` contained by the gauge.
  var content: Content
  
  /// The `LinearGradient` used to style the gauge.
  private var gradient = LinearGradient(
    colors:
      [
        Color.primary,
        Color.primary,
        Color.blue
      ],
    startPoint: .trailing,
    endPoint: .leading
  )
  
  // MARK: - Init
  
  /// The `init` of the `OverallGaugeStyle`.
  /// - Parameter content: The `View` contained by the gauge.
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
    @State var phase: CGFloat = 0
  func makeBody(configuration: Configuration) -> some View {
      ZStack {
          configuration.currentValueLabel
              
              .fontWeight(.bold)
              .font(.system(size: 88))
              .foregroundColor(Color.primary)
       
          
          .frame(width: 200, height: 200, alignment: .center)
        Circle()
          
          .trim(from: 0, to: configuration.value * 0.75)
          
          .stroke(gradient, style: StrokeStyle(lineWidth: 20, lineCap: .round))
          
          
          .rotationEffect(.degrees(135))
          .overlay(alignment: .bottom) {
              content
          }
          .frame(width: 200, height: 200, alignment: .center)
          
          Circle()
              .strokeBorder(Color.primary, style: .init(lineWidth: 25, lineCap: .round, lineJoin: .round, miterLimit: 3, dash: [0,700], dashPhase: 0))
              .rotationEffect(.degrees(135+(360*(configuration.value * 0.75))))
          .frame(width: 225, height: 225, alignment: .center)
      }
  }
}


// Reference
fileprivate
struct SpeedGaugeSystem: View {
    @State
    var currentSpeed = 5.0
    @State
    private var speedUpdateTimer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    var body: some View {
        
        Gauge(value: currentSpeed, in: 0...10) {
            Text("m/s")
        } currentValueLabel: {
            Text(currentSpeed.formatted(.number.precision(.fractionLength(1))))
                .contentTransition(.numericText(value: currentSpeed))
        }
        .gaugeStyle(.accessoryCircular)
        .offset(z: 1)
        .scaleEffect(3.7)
        .frame(width: 300, height: 300, alignment: .center)
        .glassBackgroundEffect(in: .circle)
        .onReceive(speedUpdateTimer) { _ in
            fetchNewSpeed()
        }
    }
    private
    func fetchNewSpeed() {
        withAnimation(.easeInOut(duration: 1)) {
            currentSpeed = Double.random(in: 0...10)
        }
    }
}
