//
//  LinkCellView.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 12/1/20.
//

import SwiftUI

struct LinkCell : View {
    
    @ObservedObject var imageLoader : ImageLoader
    
    @State var isBusy : Bool = false
    
    let link : Link
    let buttonAction : ()->()
    let doesLoadData : Bool
    let fontSize: CGFloat
    let viewed: Bool
    let viewModel : FrontPageViewModel
    
    init(link: Link,
         fontSize: CGFloat,
         viewed: Bool,
         viewModel: FrontPageViewModel,
         action: @escaping ()->()){
        self.link = link
        self.doesLoadData = false
        self.buttonAction = action
        self.fontSize = fontSize
        self.viewed = viewed
        self.viewModel = viewModel
        imageLoader = ImageLoader(urlString:link.imageURL)
    }
    
    var body: some View {
        
        Button(action: {
            if doesLoadData {
                isBusy = true
            }
            self.buttonAction()
        }) {
            
            if isBusy {
                
                HStack {
                    
                    Spacer()

                    Text("Loading...")
                        .font(.system(size: fontSize))
                        .foregroundColor(Color.gray.opacity(0.5))
                    
                    Spacer()
                }
                
            } else {
                
                VStack {
                
                    if let image = imageLoader.image,
                       link.imagePosition == LinkImagePosition.Top {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(3)
                    }
                                        
                    HStack(alignment: .center, spacing: 5) {
                        
                        if let image = imageLoader.image,
                           link.imagePosition == LinkImagePosition.Left {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(3)
                                .padding(.trailing, 4)
                                .frame(maxWidth: UIScreen.main.bounds.size.width * 0.30)
                        }

                        VStack(alignment: HorizontalAlignment.leading,
                               spacing: 2) {
                                                        
                            Text(link.isHeadline ? link.title.uppercased() : link.title)
                                .fontWeight(link.isHeadline || link.chomp > 0 ? .semibold : .light)
                                    .font(.custom("Courier", size: fontSize))
                                .minimumScaleFactor(0.25)
                                .foregroundColor(Color("BWForeground").opacity(viewed ? 0.40 : 1.0))
                                .lineLimit(10)
//                                    .frame(minWidth: 0,
//                                            maxWidth: .infinity,
//                                            minHeight: 20,
//                                            maxHeight: 400,
//                                            alignment: .center)
     
                        }
                        
                        if let image = imageLoader.image,
                           link.imagePosition == LinkImagePosition.Right {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(3)
                                .padding(.leading, 4)
                                .frame(maxWidth: UIScreen.main.bounds.size.width * 0.30)
                        }
                        
                    } // HStack

                }// VStack
                .padding(.top, 5)
                .padding(.bottom, 5)
                .padding(.horizontal, 10)
                .background(Color("BWBackground"))
                .frame(minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: 200,
                        alignment: .center)
            } // if/else
        }
        .onAppear(perform: {
            ImpressionService.shared.logHeadlineImpression(linkID: link.linkID)
        })
        .onDisappear(perform: {
            if isBusy {
                isBusy = false
            }
        }).contextMenu(ContextMenu(menuItems: {
            LinkMenu(link: link, viewModel: viewModel)
        }))
    }
    
    struct JustifiedText: UIViewRepresentable {
        var link: Link
        
        func makeUIView(context: Context) -> UITextView {
            let textView = UITextView()
            textView.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
            textView.textAlignment = .justified
            textView.minimumZoomScale = 0.25
            textView.translatesAutoresizingMaskIntoConstraints = true
            textView.sizeToFit()
            textView.isScrollEnabled = false
            return textView
        }
        
        func updateUIView(_ uiView: UITextView, context: Context) {
            uiView.text = link.title
        }
    }
}
