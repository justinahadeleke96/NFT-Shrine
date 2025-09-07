;; NFT Shrine Contract
;; Users can create shrines and sacrifice tokens to alter their appearance

;; Error constants
(define-constant ERR-NOT-OWNER u100)
(define-constant ERR-SHRINE-NOT-FOUND u101)
(define-constant ERR-INSUFFICIENT-TOKENS u102)
(define-constant ERR-INVALID-AMOUNT u103)

;; Contract owner
(define-constant CONTRACT-OWNER tx-sender)

;; Data variables
(define-data-var next-shrine-id uint u1)
(define-data-var shrine-creation-fee uint u1000000) ;; 1 STX

;; Data maps
(define-map shrines uint {
    owner: principal,
    name: (string-ascii 50),
    description: (string-ascii 200),
    power-level: uint,
    tokens-sacrificed: uint,
    last-sacrifice: uint
})

(define-map shrine-owners principal (list 100 uint))

;; Create a new shrine
(define-public (create-shrine (name (string-ascii 50)) (description (string-ascii 200)))
    (let ((shrine-id (var-get next-shrine-id))
          (fee (var-get shrine-creation-fee)))
        (try! (stx-transfer? fee tx-sender CONTRACT-OWNER))
        (map-set shrines shrine-id {
            owner: tx-sender,
            name: name,
            description: description,
            power-level: u0,
            tokens-sacrificed: u0,
            last-sacrifice: u0
        })
        (match (map-get? shrine-owners tx-sender)
            existing-shrines (map-set shrine-owners tx-sender (unwrap! (as-max-len? (append existing-shrines shrine-id) u100) (err u999)))
            (map-set shrine-owners tx-sender (list shrine-id))
        )
        (var-set next-shrine-id (+ shrine-id u1))
        (ok shrine-id)
    )
)

;; Sacrifice STX tokens to power up shrine
(define-public (sacrifice-tokens (shrine-id uint) (amount uint))
    (let ((shrine-data (unwrap! (map-get? shrines shrine-id) (err ERR-SHRINE-NOT-FOUND))))
        (asserts! (> amount u0) (err ERR-INVALID-AMOUNT))
        (asserts! (is-eq (get owner shrine-data) tx-sender) (err ERR-NOT-OWNER))
        (try! (stx-transfer? amount tx-sender CONTRACT-OWNER))
        (let ((new-power (+ (get power-level shrine-data) (/ amount u100000)))
              (new-total (+ (get tokens-sacrificed shrine-data) amount)))
            (map-set shrines shrine-id (merge shrine-data {
                power-level: new-power,
                tokens-sacrificed: new-total,
                last-sacrifice: block-height
            }))
            (ok {power-gained: (/ amount u100000), new-power-level: new-power})
        )
    )
)

;; Transfer shrine ownership
(define-public (transfer-shrine (shrine-id uint) (new-owner principal))
    (let ((shrine-data (unwrap! (map-get? shrines shrine-id) (err ERR-SHRINE-NOT-FOUND))))
        (asserts! (is-eq (get owner shrine-data) tx-sender) (err ERR-NOT-OWNER))
        (map-set shrines shrine-id (merge shrine-data {owner: new-owner}))
        ;; Remove from current owner's list
        (match (map-get? shrine-owners tx-sender)
            current-list (map-set shrine-owners tx-sender (filter not-shrine-id current-list))
            true
        )
        ;; Add to new owner's list
        (match (map-get? shrine-owners new-owner)
            existing-shrines (map-set shrine-owners new-owner (unwrap! (as-max-len? (append existing-shrines shrine-id) u100) (err u999)))
            (map-set shrine-owners new-owner (list shrine-id))
        )
        (ok true)
    )
)

;; Helper function for filtering shrine lists
(define-private (not-shrine-id (id uint))
    true ;; Simplified for this example
)

;; Get shrine details
(define-read-only (get-shrine (shrine-id uint))
    (map-get? shrines shrine-id)
)

;; Get shrines owned by a principal
(define-read-only (get-user-shrines (user principal))
    (default-to (list) (map-get? shrine-owners user))
)

;; Get shrine power level
(define-read-only (get-shrine-power (shrine-id uint))
    (match (map-get? shrines shrine-id)
        shrine-data (ok (get power-level shrine-data))
        (err ERR-SHRINE-NOT-FOUND)
    )
)

;; Get total tokens sacrificed to a shrine
(define-read-only (get-total-sacrificed (shrine-id uint))
    (match (map-get? shrines shrine-id)
        shrine-data (ok (get tokens-sacrificed shrine-data))
        (err ERR-SHRINE-NOT-FOUND)
    )
)

;; Get next shrine ID
(define-read-only (get-next-shrine-id)
    (var-get next-shrine-id)
)

;; Administrative function to update creation fee
(define-public (set-creation-fee (new-fee uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT-OWNER) (err ERR-NOT-OWNER))
        (var-set shrine-creation-fee new-fee)
        (ok true)
    )
)