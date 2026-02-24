import UIKit
import CoreLocation

protocol CustomCalloutViewDelegate: AnyObject {
    func didTapDetailsButton(for identifier: String)
}

class CustomCalloutView: UIView {
    
    weak var delegate: CustomCalloutViewDelegate?
    private var identifier: String = ""
    
    private let backgroundView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark) // #F51A1A1A is dark
        let view = UIVisualEffectView(effect: blurEffect)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        // Assuming user wants a dark background with blur. UIVisualEffectView with dark style is good.
        // User specified background color #F51A1A1A. We can set backgroundColor on the effect view or a subview.
        // Setting backgroundColor on UIVisualEffectView might override the effect.
        // But for "frosted glass", usually we rely on the effect.
        // If we want exact color tint, we can add a subview with alpha.
        view.contentView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.8) 
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemYellow
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let coverImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = .gray
        return view
    }()
    
    private let detailsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("查看详情", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        self.frame = CGRect(x: 0, y: 0, width: 240, height: 120)
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        
        addSubview(backgroundView)
        backgroundView.frame = self.bounds
        
        let content = backgroundView.contentView
        
        content.addSubview(coverImageView)
        coverImageView.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
        
        content.addSubview(titleLabel)
        titleLabel.frame = CGRect(x: 80, y: 10, width: 150, height: 20)
        
        content.addSubview(subtitleLabel)
        subtitleLabel.frame = CGRect(x: 80, y: 35, width: 150, height: 16)
        
        content.addSubview(ratingLabel)
        ratingLabel.frame = CGRect(x: 80, y: 55, width: 150, height: 16)
        
        content.addSubview(detailsButton)
        detailsButton.frame = CGRect(x: 150, y: 85, width: 80, height: 25)
        detailsButton.addTarget(self, action: #selector(detailsTapped), for: .touchUpInside)
    }
    
    func configure(title: String, subtitle: String, rating: String, image: UIImage?, identifier: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        ratingLabel.text = rating
        coverImageView.image = image
        self.identifier = identifier
    }
    
    @objc private func detailsTapped() {
        delegate?.didTapDetailsButton(for: identifier)
    }
}
