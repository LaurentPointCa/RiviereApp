//
//  ZoomableImageView.swift
//  Riviere
//

import SwiftUI

struct ZoomableImageView: View {
    let imageURL: URL
    let maxWidth: CGFloat

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var imageSize: CGSize = .zero

    private let zoomedScale: CGFloat = 2.5
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 4.0

    var body: some View {
        GeometryReader { geometry in
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: maxWidth)
                        .background(GeometryReader { imgGeo in
                            Color.clear.onAppear { imageSize = imgGeo.size }
                        })
                case .failure:
                    Image(systemName: "photo")
                        .frame(maxWidth: maxWidth, minHeight: 120)
                        .foregroundStyle(.secondary)
                case .empty:
                    ProgressView()
                        .frame(maxWidth: maxWidth, minHeight: 120)
                @unknown default:
                    EmptyView()
                }
            }
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        let delta = value / lastScale
                        lastScale = value
                        scale = min(max(scale * delta, minScale), maxScale)
                    }
                    .onEnded { _ in
                        lastScale = 1.0
                    }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        if scale > 1.0 {
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                    }
                    .onEnded { _ in
                        lastOffset = offset
                    }
            )
            .onTapGesture(count: 2) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if scale > 1.0 {
                        scale = 1.0
                        offset = .zero
                        lastOffset = .zero
                        lastScale = 1.0
                    } else {
                        scale = zoomedScale
                        lastScale = 1.0
                    }
                }
            }
        }
        .frame(height: 280)
        .clipped()
    }
}
