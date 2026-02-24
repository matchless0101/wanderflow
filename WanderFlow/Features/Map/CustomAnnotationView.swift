import UIKit
import AMapNaviKit.MAMapKit

struct MapBubbleStyle {
    var size: CGFloat = 40
    var cornerRadius: CGFloat = 20
    var gradientColors: [UIColor] = [
        UIColor(red: 1.0, green: 0.29, blue: 0.56, alpha: 0.6),
        UIColor(red: 0.4, green: 0.2, blue: 0.9, alpha: 0.4)
    ]
    var blurStyle: UIBlurEffect.Style = .systemUltraThinMaterialDark
    var borderColor: UIColor = UIColor.white.withAlphaComponent(0.6)
    var borderWidth: CGFloat = 1.5
    var shadowColor: UIColor = .black
    var shadowOpacity: Float = 0.3
    var shadowRadius: CGFloat = 6
    var shadowOffset: CGSize = CGSize(width: 0, height: 4)
    var textColor: UIColor = .white
    var textFont: UIFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    var iconName: String? = nil
    var iconSystemName: String = "mappin.circle.fill"
    var iconTint: UIColor = .white
    var iconSize: CGFloat = 14
    var showsBreathing: Bool = true
    var showsEntryAnimation: Bool = true
}

struct MapClusterStyle {
    var size: CGFloat = 46
    var backgroundColor: UIColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.8)
    var textColor: UIColor = .white
    var textFont: UIFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    var borderColor: UIColor = UIColor.white.withAlphaComponent(0.6)
    var borderWidth: CGFloat = 1.5
    var shadowColor: UIColor = .black
    var shadowOpacity: Float = 0.25
    var shadowRadius: CGFloat = 6
    var shadowOffset: CGSize = CGSize(width: 0, height: 4)
}

class CustomAnnotationView: MAAnnotationView {
    
    private let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.layer.masksToBounds = true
        return view
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()
    
    private let iconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.tintColor = .white
        return view
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    var sequenceNumber: Int = 0 {
        didSet {
            numberLabel.text = "\(sequenceNumber)"
        }
    }
    
    private var style: MapBubbleStyle = MapBubbleStyle()
    
    override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        self.backgroundColor = .clear
        
        addSubview(bubbleView)
        
        bubbleView.addSubview(blurView)
        
        blurView.contentView.layer.insertSublayer(gradientLayer, at: 0)
        
        blurView.contentView.addSubview(iconImageView)
        blurView.contentView.addSubview(numberLabel)
        
        apply(style: style)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleView.frame = bounds
        blurView.frame = bubbleView.bounds
        gradientLayer.frame = blurView.bounds
        numberLabel.frame = blurView.bounds
        let iconSize = style.iconSize
        iconImageView.frame = CGRect(x: (bounds.width - iconSize) / 2, y: 6, width: iconSize, height: iconSize)
    }
    
    private func startEntryAnimation() {
        transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        alpha = 0.0
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.transform = .identity
            self.alpha = 1.0
        }, completion: nil)
    }
    
    private func startBreathingAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 1.0
        animation.toValue = 1.1
        animation.duration = 1.5
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        bubbleView.layer.add(animation, forKey: "breathing")
    }
    
    func apply(style: MapBubbleStyle) {
        self.style = style
        bounds = CGRect(x: 0, y: 0, width: style.size, height: style.size)
        bubbleView.layer.shadowColor = style.shadowColor.cgColor
        bubbleView.layer.shadowOffset = style.shadowOffset
        bubbleView.layer.shadowOpacity = style.shadowOpacity
        bubbleView.layer.shadowRadius = style.shadowRadius
        blurView.layer.cornerRadius = style.cornerRadius
        blurView.layer.borderWidth = style.borderWidth
        blurView.layer.borderColor = style.borderColor.cgColor
        blurView.effect = UIBlurEffect(style: style.blurStyle)
        gradientLayer.colors = style.gradientColors.map { $0.cgColor }
        numberLabel.textColor = style.textColor
        numberLabel.font = style.textFont
        if let iconName = style.iconName, let image = UIImage(named: iconName) {
            iconImageView.image = image.withRenderingMode(.alwaysTemplate)
        } else if let image = UIImage(systemName: style.iconSystemName) {
            iconImageView.image = image.withRenderingMode(.alwaysTemplate)
        } else {
            iconImageView.image = nil
        }
        iconImageView.tintColor = style.iconTint
        if style.showsEntryAnimation {
            startEntryAnimation()
        } else {
            transform = .identity
            alpha = 1.0
        }
        bubbleView.layer.removeAnimation(forKey: "breathing")
        if style.showsBreathing {
            startBreathingAnimation()
        }
        setNeedsLayout()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class ClusterAnnotationView: MAAnnotationView {
    private let backgroundView = UIView()
    private let countLabel = UILabel()
    private var style: MapClusterStyle = MapClusterStyle()
    
    override init!(annotation: MAAnnotation!, reuseIdentifier: String!) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(backgroundView)
        backgroundView.addSubview(countLabel)
        apply(style: style, count: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        countLabel.frame = bounds
    }
    
    func apply(style: MapClusterStyle, count: Int) {
        self.style = style
        bounds = CGRect(x: 0, y: 0, width: style.size, height: style.size)
        backgroundView.backgroundColor = style.backgroundColor
        backgroundView.layer.cornerRadius = style.size / 2
        backgroundView.layer.borderWidth = style.borderWidth
        backgroundView.layer.borderColor = style.borderColor.cgColor
        backgroundView.layer.shadowColor = style.shadowColor.cgColor
        backgroundView.layer.shadowOpacity = style.shadowOpacity
        backgroundView.layer.shadowRadius = style.shadowRadius
        backgroundView.layer.shadowOffset = style.shadowOffset
        countLabel.textColor = style.textColor
        countLabel.font = style.textFont
        countLabel.textAlignment = .center
        countLabel.text = "\(count)"
        setNeedsLayout()
    }
}
