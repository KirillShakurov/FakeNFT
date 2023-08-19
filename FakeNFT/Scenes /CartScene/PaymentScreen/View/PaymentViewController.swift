//
//  PaymentViewController.swift
//  FakeNFT
//
//  Created by Илья Тимченко on 27.06.2023.
//

import UIKit
import Kingfisher

final class PaymentViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel: PaymentViewModelProtocol?
    
    var paymentArray: [PaymentStruct] = []
    
    var isCellSelected: Int = -1
    
    let paymentCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.isScrollEnabled = true
        collection.register(PaymentCell.self, forCellWithReuseIdentifier: "paymentCell")
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    let paymentButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.addTarget(nil, action: #selector(payButtonTapped), for: .touchUpInside)
        button.setTitle("PAY".localized, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let cartInfo: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let userAgreementText: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.text = "AGREE_TO_THE_TERMS".localized
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let userAgreementLink: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.numberOfLines = 0
        label.textColor = .link
        label.textAlignment = .left
        label.text = "USER_AGREEMENT".localized
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProperties()
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
}

// MARK: - Private methods
extension PaymentViewController {
    
    // MARK: - Functions & Methods
    /// Appearance customisation
    private func setupView() {
        NSLayoutConstraint.activate([
            paymentCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            paymentCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            paymentCollection.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            paymentCollection.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cartInfo.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cartInfo.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cartInfo.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cartInfo.heightAnchor.constraint(equalToConstant: 186),
            paymentButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            paymentButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            paymentButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            paymentButton.heightAnchor.constraint(equalToConstant: 60),
            userAgreementText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userAgreementText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            userAgreementText.topAnchor.constraint(equalTo: cartInfo.topAnchor, constant: 16),
            userAgreementText.heightAnchor.constraint(equalToConstant: 18),
            userAgreementLink.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userAgreementLink.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            userAgreementLink.topAnchor.constraint(equalTo: userAgreementText.bottomAnchor),
            userAgreementLink.heightAnchor.constraint(equalToConstant: 18),
        ])
    }
    
    /// Setting properties
    private func setupProperties() {
        viewModel?.getСurrencies(completion: { payments in
            self.paymentArray = payments
            DispatchQueue.main.async {
                self.paymentCollection.reloadData()
            }
        })
        tabBarController?.tabBar.isHidden = true
        title = "CHOOSE_PAYMENT".localized
        view.backgroundColor = .white
        view.addSubview(paymentCollection)
        view.addSubview(cartInfo)
        view.addSubview(paymentButton)
        view.addSubview(userAgreementText)
        view.addSubview(userAgreementLink)
        paymentCollection.dataSource = self
        paymentCollection.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        userAgreementLink.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func payButtonTapped() {
        if isCellSelected != -1 {
            viewModel?.getPaymentResult(currencyID: String(isCellSelected), completion: { result in
                if result == true {
                    DispatchQueue.main.async {
                        let successVC = SuccessViewController()
                        successVC.modalPresentationStyle = .fullScreen
                        successVC.modalTransitionStyle = .crossDissolve
                        self.present(successVC, animated: false)
                    }
                } else {
                    DispatchQueue.main.async {
                        let successVC = UnsuccessViewController()
                        successVC.modalPresentationStyle = .fullScreen
                        successVC.modalTransitionStyle = .crossDissolve
                        self.present(successVC, animated: false)
                    }
                }
            })
        }
    }
    
    @objc
    func labelTapped() {
        guard let url = URL(string: "https://yandex.ru/legal/practicum_termsofuse/") else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
}

extension PaymentViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        paymentArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "paymentCell", for: indexPath) as? PaymentCell
            else { return UICollectionViewCell() }
        let imageURL = URL(string: paymentArray[indexPath.row].image)
        cell.image.kf.setImage(with: imageURL)
        let name = paymentArray[indexPath.row].title
        cell.name.text = name
        let shortName = paymentArray[indexPath.row].name
        cell.shortName.text = shortName
        return cell
    }
    
}

extension PaymentViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isCellSelected = indexPath.row + 1
    }
    
}

extension PaymentViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (view.bounds.width / 2) - 22
        return CGSize(width: size, height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
}

