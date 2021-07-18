//
//  Cell.swift
//  Task-Aerologic
//
//  Created by Ravi Bastola on 18/07/2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct Cell: View {
    
    var viewModel: PersonListViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            WebImage(url: viewModel.imageURL, isAnimating: .constant(true))
                .resizable()
                .placeholder {
                       Rectangle().foregroundColor(.gray)
                   }
                .indicator(.activity) // Activity Indicator
                .transition(.fade(duration: 0.5)) // Fade Transition with duratio
                .aspectRatio(contentMode: .fill)
                .clipped()
                .frame(width: 100, height: 100, alignment: .center)
                .cornerRadius(20)
            
            
            VStack(alignment: .leading, spacing: 5) {
                Text(viewModel.name + ", " + viewModel.age)
                Text(viewModel.gender)
                Text(viewModel.education)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                Text(viewModel.jobs)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            
        }
        .padding(.horizontal, 30)
        
    }
}

struct Cell_Previews: PreviewProvider {
    static var previews: some View {
        Cell(viewModel: .init(person: .init(firstName: nil, lastName: nil, age: nil, gender: nil, pictureURL: nil, job: nil, education: nil))).previewLayout(.fixed(width: UIScreen.main.bounds.width, height: 120))
    }
}
