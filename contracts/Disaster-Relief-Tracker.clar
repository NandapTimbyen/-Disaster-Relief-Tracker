(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-unauthorized (err u104))

(define-data-var total-donations uint u0)
(define-data-var total-disbursements uint u0)

(define-map disasters 
    { disaster-id: uint }
    {
        name: (string-ascii 50),
        location: (string-ascii 50),
        status: (string-ascii 20),
        total-needed: uint,
        total-received: uint
    }
)

(define-map recipients
    { recipient-id: uint }
    {
        address: principal,
        disaster-id: uint,
        verified: bool,
        aid-received: uint
    }
)

(define-map volunteers
    { volunteer-id: uint }
    {
        address: principal,
        reputation: uint,
        total-verifications: uint
    }
)

(define-map donations
    { donation-id: uint }
    {
        donor: principal,
        disaster-id: uint,
        amount: uint,
        timestamp: uint
    }
)

(define-map disbursements
    { disbursement-id: uint }
    {
        recipient-id: uint,
        amount: uint,
        verified-by: (optional principal),
        status: (string-ascii 20)
    }
)

(define-data-var disaster-id-nonce uint u0)
(define-data-var recipient-id-nonce uint u0)
(define-data-var volunteer-id-nonce uint u0)
(define-data-var donation-id-nonce uint u0)
(define-data-var disbursement-id-nonce uint u0)

(define-public (register-disaster (name (string-ascii 50)) (location (string-ascii 50)) (amount-needed uint))
    (let ((disaster-id (+ (var-get disaster-id-nonce) u1)))
        (if (is-eq tx-sender contract-owner)
            (begin
                (var-set disaster-id-nonce disaster-id)
                (ok (map-insert disasters
                    { disaster-id: disaster-id }
                    {
                        name: name,
                        location: location,
                        status: "active",
                        total-needed: amount-needed,
                        total-received: u0
                    })))
            err-owner-only)))

(define-public (register-recipient (disaster-id uint) (recipient principal))
    (let ((recipient-id (+ (var-get recipient-id-nonce) u1)))
        (begin
            (var-set recipient-id-nonce recipient-id)
            (ok (map-insert recipients
                { recipient-id: recipient-id }
                {
                    address: recipient,
                    disaster-id: disaster-id,
                    verified: false,
                    aid-received: u0
                })))))
(define-public (register-volunteer (volunteer principal))
    (let ((volunteer-id (+ (var-get volunteer-id-nonce) u1)))
        (if (is-eq tx-sender contract-owner)
            (begin
                (var-set volunteer-id-nonce volunteer-id)
                (ok (map-insert volunteers
                    { volunteer-id: volunteer-id }
                    {
                        address: volunteer,
                        reputation: u0,
                        total-verifications: u0
                    })))
            err-owner-only)))

(define-public (donate (disaster-id uint) (amount uint))
    (let ((donation-id (+ (var-get donation-id-nonce) u1)))
        (if (> amount u0)
            (begin
                (var-set donation-id-nonce donation-id)
                (var-set total-donations (+ (var-get total-donations) amount))
                (ok (map-insert donations
                    { donation-id: donation-id }
                    {
                        donor: tx-sender,
                        disaster-id: disaster-id,
                        amount: amount,
                        timestamp: stacks-block-height
                    })))
            err-invalid-amount)))

(define-public (create-disbursement (recipient-id uint) (amount uint))
    (let ((disbursement-id (+ (var-get disbursement-id-nonce) u1)))
        (if (is-eq tx-sender contract-owner)
            (begin
                (var-set disbursement-id-nonce disbursement-id)
                (ok (map-insert disbursements
                    { disbursement-id: disbursement-id }
                    {
                        recipient-id: recipient-id,
                        amount: amount,
                        verified-by: none,
                        status: "pending"
                    })))
            err-owner-only)))

(define-public (verify-disbursement (disbursement-id uint))
    (let ((disbursement (unwrap! (map-get? disbursements { disbursement-id: disbursement-id }) err-not-found)))
        (if (is-some (get verified-by disbursement))
            err-already-exists
            (ok (map-set disbursements
                { disbursement-id: disbursement-id }
                (merge disbursement {
                    verified-by: (some tx-sender),
                    status: "verified"
                }))))))

(define-read-only (get-disaster-info (disaster-id uint))
    (map-get? disasters { disaster-id: disaster-id }))

(define-read-only (get-recipient-info (recipient-id uint))
    (map-get? recipients { recipient-id: recipient-id }))

(define-read-only (get-donation-info (donation-id uint))
    (map-get? donations { donation-id: donation-id }))

(define-read-only (get-total-donations)
    (ok (var-get total-donations)))

(define-read-only (get-total-disbursements)
    (ok (var-get total-disbursements)))