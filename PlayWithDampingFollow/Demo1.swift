import RealityKit
import SwiftUI
import DampingFollow

public
struct Demo1ImmersiveView: View {
    public init() { }
    private
    let floatingPanelId:UUID = UUID()
    @State
    private var followManager = FollowManager()
    
    public
    var body: some View {
        
        RealityView {
            realityViewContent,
            attachments in
            if let floatingPanelEntity:ViewAttachmentEntity = attachments.entity(for: floatingPanelId) {
                floatingPanelEntity
                    .components[DampingFollowComponent.self] = DampingFollowComponent(
                        followManager: followManager
                    )
                realityViewContent.add(floatingPanelEntity)
            }
        } attachments: {
            Attachment(id: floatingPanelId) {
                FloatingViewWithPin(followManager: followManager)
            }
        }
        .modifier(EnableDampingFollow())
    }
}

struct FloatingViewWithPin: View {
    @State
    var followManager:FollowManager
    var isPin:Binding<Bool> {
        Binding {
            !followManager.isFollow
        } set: { newValue in
            followManager.isFollow = !newValue
        }
        
    }
    var body: some View {
        VStack {
            NavigationStack {
                VStack {
                    List {
                        Text("您可以点击下方工具栏的大头针图标来固定该面板")
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Toggle(isOn: isPin) {
                            Image(systemName: "mappin")
                        }
                        .buttonBorderShape(.circle)
                        .buttonStyle(.bordered)
                    }
                }
                .navigationTitle("悬浮面板")
            }
        }
        // Note: You need to provide a fixed size, as the window size does not support user drag-resizing.
        .frame(width: 300, height: 400, alignment: .bottom)
    }
}


