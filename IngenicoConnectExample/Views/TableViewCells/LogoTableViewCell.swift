//
//  LogoTableViewCell.swift
//  IngenicoConnectExample
//
//  Created for Ingenico ePayments on 07/07/2017.
//  Copyright © 2017 Ingenico. All rights reserved.
//

import UIKit

class LogoTableViewCell: ImageTableViewCell {
    override class var reuseIdentifier: String { return "logo-cell" }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    private static let imageWidth: CGFloat = 140
    static func cellSize(width: CGFloat, for row: FormRowSmallLogo) -> CGSize {
        return CGSize(width: LogoTableViewCell.imageWidth, height:size(transformedFrom: row.image.size, targetWidth: LogoTableViewCell.imageWidth).height)
    }
    override func layoutSubviews() {
        let width = LogoTableViewCell.imageWidth as CGFloat
        let leftMargin = self.frame.midX - width/2
        let height = LogoTableViewCell.size(transformedFrom: (displayImage?.size)!, targetWidth: LogoTableViewCell.imageWidth).height
            
        displayImageView.frame = CGRect(x: leftMargin, y: 0, width:width , height: height)
    }

}
