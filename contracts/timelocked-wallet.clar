;; A 'Wallet contract' that contains a number of STX tokens.
;; After a certain amount of time, the wallet contract will release these tokens
;; to specific beneficary specified by the contract deployer

(define-constant contract-deployer tx-sender)

(define-constant err-owner-only (err u100))
(define-constant err-unlock-in-past (err u101))
(define-constant err-no-value (err u102))
(define-constant err-already-locked (err u103))
(define-constant err-beneficiary-only (err u104))
(define-constant err-unlock-not-reached (err u105))

(define-data-var beneficiary principal tx-sender)
(define-data-var unlock-height uint u0)


(define-public (lock (new-beneficiary principal) (unlock-at uint) (amount uint)) 
   (begin 
      (asserts! (is-eq tx-sender contract-deployer) err-owner-only)
      (asserts! (> unlock-at block-height) err-unlock-in-past)
      (asserts! (> amount u0) err-no-value)
      (asserts! (is-eq (var-get unlock-height) u0) err-already-locked)
      (var-set beneficiary new-beneficiary)
      (var-set unlock-height unlock-at)
      (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
      (ok true)
   )
)

(define-public (claim) 
   (begin 
       (asserts! (is-eq (var-get beneficiary) tx-sender) err-beneficiary-only)
       (asserts! (>= block-height (var-get unlock-height))  err-unlock-not-reached)
       (as-contract (stx-transfer? (stx-get-balance tx-sender) tx-sender (var-get beneficiary)))
   
   )
)