(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-unauthorized (err u104))
(define-constant err-insufficient-pool-funds (err u105))
(define-constant err-pool-inactive (err u106))

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

(define-map matching-pools
    { pool-id: uint }
    {
        sponsor: principal,
        disaster-id: uint,
        multiplier: uint,
        total-fund: uint,
        remaining-fund: uint,
        active: bool
    }
)
(define-map volunteer-assignments
    { volunteer-id: uint, disaster-id: uint }
    { assigned: bool }
)

(define-map volunteer-addresses principal uint)

(define-data-var disaster-id-nonce uint u0)
(define-data-var recipient-id-nonce uint u0)
(define-data-var volunteer-id-nonce uint u0)
(define-data-var donation-id-nonce uint u0)
(define-data-var disbursement-id-nonce uint u0)
(define-data-var matching-pool-id-nonce uint u0)

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
                (map-set volunteer-addresses volunteer volunteer-id)
                (ok (map-insert volunteers
                    { volunteer-id: volunteer-id }
                    {
                        address: volunteer,
                        reputation: u0,
                        total-verifications: u0
                    })))
            err-owner-only)))

(define-public (create-matching-pool (disaster-id uint) (multiplier uint) (fund-amount uint))
    (let ((pool-id (+ (var-get matching-pool-id-nonce) u1)))
        (if (is-eq tx-sender contract-owner)
            (begin
                (var-set matching-pool-id-nonce pool-id)
                (ok (map-insert matching-pools
                    { pool-id: pool-id }
                    {
                        sponsor: tx-sender,
                        disaster-id: disaster-id,
                        multiplier: multiplier,
                        total-fund: fund-amount,
                        remaining-fund: fund-amount,
                        active: true
                    })))
            err-owner-only)))

(define-private (find-active-matching-pool (disaster-id uint))
    (let ((pool-id u1))
        (match (map-get? matching-pools { pool-id: pool-id })
            pool (if (and (is-eq (get disaster-id pool) disaster-id)
                         (get active pool)
                         (> (get remaining-fund pool) u0))
                     (some pool-id)
                     none)
            none)))

(define-private (apply-matching (disaster-id uint) (donation-amount uint))
    (match (find-active-matching-pool disaster-id)
        pool-id
        (match (map-get? matching-pools { pool-id: pool-id })
            pool
            (let ((matching-amount (* donation-amount (get multiplier pool))))
                (if (<= matching-amount (get remaining-fund pool))
                    (begin
                        (map-set matching-pools
                            { pool-id: pool-id }
                            (merge pool { remaining-fund: (- (get remaining-fund pool) matching-amount) }))
                        matching-amount)
                    u0))
            u0)
        u0))

(define-public (donate (disaster-id uint) (amount uint))
    (let ((donation-id (+ (var-get donation-id-nonce) u1))
          (matched-amount (apply-matching disaster-id amount))
          (total-amount (+ amount matched-amount)))
        (if (> amount u0)
            (begin
                (var-set donation-id-nonce donation-id)
                (var-set total-donations (+ (var-get total-donations) total-amount))
                (ok (map-insert donations
                    { donation-id: donation-id }
                    {
                        donor: tx-sender,
                        disaster-id: disaster-id,
                        amount: total-amount,
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

(define-public (deactivate-matching-pool (pool-id uint))
    (let ((pool (unwrap! (map-get? matching-pools { pool-id: pool-id }) err-not-found)))
        (if (is-eq tx-sender contract-owner)
            (ok (map-set matching-pools
                { pool-id: pool-id }
                (merge pool { active: false })))
            err-owner-only)))
(define-public (assign-volunteer-to-disaster (volunteer-id uint) (disaster-id uint))
    (if (is-eq tx-sender contract-owner)
        (ok (map-set volunteer-assignments { volunteer-id: volunteer-id, disaster-id: disaster-id } { assigned: true }))
        err-owner-only))

(define-public (unassign-volunteer-from-disaster (volunteer-id uint) (disaster-id uint))
    (if (is-eq tx-sender contract-owner)
        (ok (map-delete volunteer-assignments { volunteer-id: volunteer-id, disaster-id: disaster-id }))
        err-owner-only))

(define-public (verify-recipient (recipient-id uint))
    (let ((recipient (unwrap! (map-get? recipients { recipient-id: recipient-id }) err-not-found))
          (disaster-id (get disaster-id recipient))
          (volunteer-id (unwrap! (map-get? volunteer-addresses tx-sender) err-unauthorized)))
        (if (and (not (get verified recipient))
                 (is-volunteer-assigned volunteer-id disaster-id))
            (ok (map-set recipients
                { recipient-id: recipient-id }
                (merge recipient { verified: true })))
            err-unauthorized)))

(define-read-only (get-matching-pool-info (pool-id uint))
    (map-get? matching-pools { pool-id: pool-id }))

(define-read-only (get-matching-effectiveness (disaster-id uint) (donation-amount uint))
    (match (find-active-matching-pool disaster-id)
        pool-id
        (match (map-get? matching-pools { pool-id: pool-id })
            pool
            (let ((potential-match (* donation-amount (get multiplier pool))))
                (if (<= potential-match (get remaining-fund pool))
                    (some { original: donation-amount, matched: potential-match, total: (+ donation-amount potential-match) })
                    (some { original: donation-amount, matched: u0, total: donation-amount })))
            none)
        none))

(define-read-only (get-disaster-info (disaster-id uint))
    (map-get? disasters { disaster-id: disaster-id }))

(define-read-only (get-recipient-info (recipient-id uint))
    (map-get? recipients { recipient-id: recipient-id }))

(define-read-only (get-donation-info (donation-id uint))
    (map-get? donations { donation-id: donation-id }))

(define-read-only (get-total-donations)
    (ok (var-get total-donations)))
(define-read-only (is-volunteer-assigned (volunteer-id uint) (disaster-id uint))
    (default-to false (get assigned (map-get? volunteer-assignments { volunteer-id: volunteer-id, disaster-id: disaster-id }))))

(define-read-only (get-total-disbursements)
    (ok (var-get total-disbursements)))